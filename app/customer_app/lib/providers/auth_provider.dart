import 'package:flutter/foundation.dart';

import '../models/user_model.dart';
import '../services/api_client.dart';
import '../services/auth_service.dart';
import '../services/fcm_service.dart';
import '../services/message_service.dart';
import '../services/region_group_service.dart';
import '../services/user_service.dart';
import '../utils/constants.dart';
import '../utils/welcome_message.dart';

enum AuthStatus { unknown, codeSent, authenticated, error }

/// Profile details collected during the 3-step registration BEFORE the phone
/// is verified. Saved once phone verification yields a session.
class RegistrationDraft {
  String name = '';
  String lastName = '';
  String referredBy = '';
  String address = '';
  String city = '';
  String postalCode = '';
  String group = '';
  double? lat;
  double? lng;
  String language = 'en';
}

class AuthProvider extends ChangeNotifier {
  final AuthService _auth = AuthService.instance;
  final UserService _users = UserService.instance;

  UserModel? _user;
  String? _pendingPhone; // phone currently going through OTP
  AuthStatus _status = AuthStatus.unknown;
  String? _error;
  bool _busy = false;
  bool _isNewUser = false;

  // 'login' or 'register' — set before opening the phone screen so the OTP
  // screen knows what to do on success.
  String authMode = 'login';
  // Pending profile during a registration (phone verified last).
  RegistrationDraft? draft;

  UserModel? get user => _user;

  /// The phone number the current OTP was sent to (kept under the old name
  /// for compatibility with the OTP screen).
  String? get verificationId => _pendingPhone;
  AuthStatus get status => _status;
  String? get error => _error;
  bool get busy => _busy;
  bool get isLoggedIn => _auth.isLoggedIn;
  String? get uid => _auth.uid;
  String? get phone => _auth.phone ?? _pendingPhone;
  bool get isNewUser => _isNewUser;

  void _setBusy(bool v) {
    _busy = v;
    notifyListeners();
  }

  Future<UserModel?> loadCurrentUser() async {
    if (!_auth.isLoggedIn) return null;
    try {
      final fetched = await _users.getUser(_auth.uid ?? '');
      // A profile without a name has not completed registration yet — callers
      // treat a null user as "needs registration".
      _user = (fetched != null && fetched.name.trim().isNotEmpty) ? fetched : null;
      if (_user != null) {
        await FcmService.instance.init(_user!.id);
      }
      notifyListeners();
      return _user;
    } on ApiException catch (e) {
      if (e.statusCode == 401) {
        _user = null;
      } else {
        _error = e.message;
      }
      notifyListeners();
      return null;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return null;
    }
  }

  /// Requests the OTP SMS for [phoneNumber]. Completes when the code has been
  /// sent (status → codeSent) or on failure (status → error).
  Future<bool> startPhoneVerification(String phoneNumber) async {
    _setBusy(true);
    _error = null;
    _status = AuthStatus.unknown;
    try {
      final devCode = await _auth.requestOtp(phoneNumber);
      _pendingPhone = phoneNumber;
      _status = AuthStatus.codeSent;
      if (devCode != null) {
        debugPrint('[DEV] OTP for $phoneNumber: $devCode');
      }
      _setBusy(false);
      return true;
    } on ApiException catch (e) {
      _error = e.message;
      _status = AuthStatus.error;
      _setBusy(false);
      return false;
    } catch (e) {
      _error = e.toString();
      _status = AuthStatus.error;
      _setBusy(false);
      return false;
    }
  }

  Future<bool> verifyOtp(String smsCode) async {
    final phoneNumber = _pendingPhone;
    if (phoneNumber == null) return false;
    _setBusy(true);
    _error = null;
    try {
      final res = await _auth.verifyOtp(phoneNumber, smsCode);
      _isNewUser = res['isNewUser'] == true;
      _status = AuthStatus.authenticated;
      await loadCurrentUser();
      _setBusy(false);
      return true;
    } on ApiException catch (e) {
      _error = e.message;
      _status = AuthStatus.error;
      _setBusy(false);
      return false;
    } catch (e) {
      _error = e.toString().replaceFirst('Exception: ', '');
      _status = AuthStatus.error;
      _setBusy(false);
      return false;
    }
  }

  Future<bool> saveProfile({
    required String name,
    String lastName = '',
    required String address,
    required String city,
    required String postalCode,
    required String group,
    double? lat,
    double? lng,
    required String language,
    String referredBy = '',
  }) async {
    final id = _auth.uid;
    if (id == null) return false;
    _setBusy(true);
    try {
      final user = UserModel(
        id: id,
        name: name,
        lastName: lastName,
        phone: _auth.phone ?? '',
        address: address,
        city: city,
        postalCode: postalCode,
        group: group,
        lat: lat,
        lng: lng,
        language: language,
        isAdmin: false,
        referredBy: referredBy,
      );
      await _users.saveUser(user);
      _user = user;
      await FcmService.instance.init(id);
      // Greet the new customer with an automated admin message in their language.
      await MessageService.instance.sendWelcomeIfNew(
        topicId: id,
        userName: user.fullName.isEmpty ? user.name : user.fullName,
        userGroup: group,
        text: WelcomeMessage.forLang(language),
        adminUid: AppConstants.adminUid,
        senderName: WelcomeMessage.senderName,
      );
      _setBusy(false);
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      _setBusy(false);
      return false;
    }
  }

  /// Saves the collected [draft] once the phone is verified. The delivery
  /// group is resolved from the geocoded point; empty means out of coverage.
  Future<bool> completeRegistration() async {
    final d = draft;
    if (d == null) return false;
    var group = d.group;
    if (group.isEmpty && d.lat != null && d.lng != null) {
      try {
        group = await RegionGroupService.instance
                .resolveGroupName(d.lat!, d.lng!) ??
            '';
      } catch (_) {
        group = '';
      }
    }
    final ok = await saveProfile(
      name: d.name,
      lastName: d.lastName,
      address: d.address,
      city: d.city,
      postalCode: d.postalCode,
      group: group,
      lat: d.lat,
      lng: d.lng,
      language: d.language,
      referredBy: d.referredBy,
    );
    if (ok) draft = null;
    return ok;
  }

  Future<void> updateFields(Map<String, dynamic> data) async {
    final id = _auth.uid;
    if (id == null) return;
    try {
      await _users.updateFields(id, data);
      await loadCurrentUser();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> signOut() async {
    await _auth.signOut();
    _user = null;
    _pendingPhone = null;
    _status = AuthStatus.unknown;
    notifyListeners();
  }

  /// Permanently deletes the account server-side (anonymize + deactivate),
  /// then clears the local session.
  Future<void> deleteAccount() async {
    try {
      await _auth.deleteCurrentUser();
    } catch (e) {
      debugPrint('deleteAccount: $e');
      await _auth.signOut();
    }
    _user = null;
    _pendingPhone = null;
    _status = AuthStatus.unknown;
    notifyListeners();
  }

  void resetError() {
    _error = null;
    notifyListeners();
  }

  // Helper to build E.164 number, leaving all-zero test numbers intact.
  static String buildE164(String countryCode, String raw) {
    final digits = raw.replaceAll(RegExp(r'\D'), '');
    final hasNonZero = digits.replaceAll('0', '').isNotEmpty;
    final trimmed =
        (digits.startsWith('0') && hasNonZero) ? digits.substring(1) : digits;
    return '$countryCode$trimmed';
  }
}
