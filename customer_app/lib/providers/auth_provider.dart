import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

import '../models/user_model.dart';
import '../services/auth_service.dart';
import '../services/fcm_service.dart';
import '../services/message_service.dart';
import '../services/user_service.dart';
import '../utils/constants.dart';
import '../utils/welcome_message.dart';

enum AuthStatus { unknown, codeSent, authenticated, error }

class AuthProvider extends ChangeNotifier {
  final AuthService _auth = AuthService.instance;
  final UserService _users = UserService.instance;

  UserModel? _user;
  String? _verificationId;
  int? _resendToken;
  AuthStatus _status = AuthStatus.unknown;
  String? _error;
  bool _busy = false;

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

  Future<void> startPhoneVerification(String phoneNumber) async {
    _setBusy(true);
    _error = null;
    try {
      await _auth.verifyPhoneNumber(
        phoneNumber: phoneNumber,
        forceResendingToken: _resendToken,
        codeSent: (vid, token) {
          _verificationId = vid;
          _resendToken = token;
          _status = AuthStatus.codeSent;
          _setBusy(false);
        },
        verificationCompleted: (cred) async {
          try {
            await _auth.signInWithCredential(cred);
            _status = AuthStatus.authenticated;
          } catch (_) {}
          _setBusy(false);
        },
        verificationFailed: (e) {
          _error = e.message ?? 'Verification failed';
          _status = AuthStatus.error;
          _setBusy(false);
        },
        codeAutoRetrievalTimeout: (vid) => _verificationId = vid,
      );
    } catch (e) {
      _error = e.toString();
      _status = AuthStatus.error;
      _setBusy(false);
    }
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
