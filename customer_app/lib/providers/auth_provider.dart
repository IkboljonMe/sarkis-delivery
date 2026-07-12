import 'dart:async';

import 'package:flutter/foundation.dart';

import '../models/user_model.dart';
import '../services/auth_service.dart';
import '../services/fcm_service.dart';
import '../services/message_service.dart';
import '../services/region_group_service.dart';
import '../services/user_service.dart';
import '../utils/constants.dart';
import '../utils/welcome_message.dart';

enum AuthStatus { unknown, codeSent, authenticated, error }

/// Profile details collected during the new 3-step registration BEFORE the
/// phone is verified. Saved once phone verification yields a uid.
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
  String? _verificationId;
  int? _resendToken;
  AuthStatus _status = AuthStatus.unknown;
  String? _error;
  bool _busy = false;

  // 'login' or 'register' — set before opening the phone screen so the OTP
  // screen knows what to do on success.
  String authMode = 'login';
  // Pending profile during a registration (phone verified last).
  RegistrationDraft? draft;

  UserModel? get user => _user;
  String? get verificationId => _verificationId;
  AuthStatus get status => _status;
  String? get error => _error;
  bool get busy => _busy;
  bool get isLoggedIn => _auth.isLoggedIn;
  String? get uid => _auth.uid;
  String? get phone => _auth.currentUser?.phoneNumber;

  void _setBusy(bool v) {
    _busy = v;
    notifyListeners();
  }

  Future<UserModel?> loadCurrentUser() async {
    final id = _auth.uid;
    if (id == null) return null;
    try {
      _user = await _users.getUser(id);
      if (_user != null) {
        await FcmService.instance.init(id);
      }
      notifyListeners();
      return _user;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return null;
    }
  }

  /// Starts phone verification and completes ONLY when the SMS code has been
  /// sent (or verification finished/failed). The Future from `verifyPhoneNumber`
  /// resolves before the `codeSent` callback fires, so we drive completion off
  /// the callbacks via a Completer — otherwise the caller would see a stale
  /// status and need a second tap to navigate.
  Future<bool> startPhoneVerification(String phoneNumber) {
    _setBusy(true);
    _error = null;
    _status = AuthStatus.unknown;
    final completer = Completer<bool>();
    void finish(bool ok) {
      _setBusy(false);
      if (!completer.isCompleted) completer.complete(ok);
    }

    _auth
        .verifyPhoneNumber(
          phoneNumber: phoneNumber,
          forceResendingToken: _resendToken,
          codeSent: (vid, token) {
            _verificationId = vid;
            _resendToken = token;
            _status = AuthStatus.codeSent;
            finish(true);
          },
          verificationCompleted: (cred) async {
            // Instant verification (some Android devices): sign in directly.
            try {
              await _auth.signInWithCredential(cred);
              _status = AuthStatus.authenticated;
              await loadCurrentUser();
            } catch (_) {}
            finish(true);
          },
          verificationFailed: (e) {
            _error = e.message ?? 'Verification failed';
            _status = AuthStatus.error;
            finish(false);
          },
          codeAutoRetrievalTimeout: (vid) => _verificationId = vid,
        )
        .catchError((e) {
      _error = e.toString();
      _status = AuthStatus.error;
      finish(false);
    });
    return completer.future;
  }

  Future<bool> verifyOtp(String smsCode) async {
    if (_verificationId == null) return false;
    _setBusy(true);
    _error = null;
    try {
      await _auth.signInWithSmsCode(
          verificationId: _verificationId!, smsCode: smsCode);
      _status = AuthStatus.authenticated;
      await loadCurrentUser();
      _setBusy(false);
      return true;
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
        phone: _auth.currentUser?.phoneNumber ?? '',
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
      return true;
    } catch (e) {
      _error = e.toString();
      _setBusy(false);
      return false;
    }
  }

  /// Saves the collected [draft] once the phone is verified. The delivery
  /// group is resolved here (now that we're authenticated and may read
  /// `regionGroups`) from the geocoded point; empty means out of coverage.
  /// Returns false if there's no draft or no signed-in uid.
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
    _verificationId = null;
    _status = AuthStatus.unknown;
    notifyListeners();
  }

  /// Permanently deletes the account: removes the Firestore profile, then the
  /// Firebase Auth user (best-effort — may need recent login), then signs out.
  /// The profile doc is always removed so the account can't be used again.
  Future<void> deleteAccount() async {
    final id = _auth.uid;
    try {
      if (id != null) await _users.deleteUser(id);
    } catch (e) {
      debugPrint('deleteAccount (profile): $e');
    }
    try {
      await _auth.deleteCurrentUser();
    } catch (e) {
      debugPrint('deleteAccount (auth): $e');
    }
    await _auth.signOut();
    _user = null;
    _verificationId = null;
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
