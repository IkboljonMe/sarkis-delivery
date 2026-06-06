import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';

import '../models/user_model.dart';
import '../services/auth_service.dart';
import '../services/firebase_service.dart';

enum AuthStatus { unknown, codeSent, verifying, authenticated, error }

/// Holds the authenticated user and drives the phone-auth flow.
class AuthProvider extends ChangeNotifier {
  final AuthService _auth = AuthService.instance;
  final FirebaseService _db = FirebaseService.instance;

  UserModel? _user;
  String? _verificationId;
  int? _resendToken;
  AuthStatus _status = AuthStatus.unknown;
  String? _errorMessage;
  bool _busy = false;

  UserModel? get user => _user;
  String? get verificationId => _verificationId;
  int? get resendToken => _resendToken;
  AuthStatus get status => _status;
  String? get errorMessage => _errorMessage;
  bool get busy => _busy;
  bool get isLoggedIn => _auth.isLoggedIn;
  String? get uid => _auth.currentUser?.uid;
  String? get phone => _auth.currentUser?.phoneNumber;

  void _setBusy(bool value) {
    _busy = value;
    notifyListeners();
  }

  /// Loads the Firestore user doc for the signed-in account (if any).
  Future<UserModel?> loadCurrentUser() async {
    final id = _auth.currentUser?.uid;
    if (id == null) return null;
    try {
      _user = await _db.getUser(id);
      await _saveFcmToken();
      notifyListeners();
      return _user;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return null;
    }
  }

  Future<void> startPhoneVerification(String phoneNumber) async {
    _setBusy(true);
    _errorMessage = null;
    try {
      await _auth.verifyPhoneNumber(
        phoneNumber: phoneNumber,
        forceResendingToken: _resendToken,
        codeSent: (verificationId, resendToken) {
          _verificationId = verificationId;
          _resendToken = resendToken;
          _status = AuthStatus.codeSent;
          _setBusy(false);
        },
        verificationCompleted: (credential) async {
          // Android auto-retrieval — sign in directly.
          try {
            await _auth.signInWithCredential(credential);
            _status = AuthStatus.authenticated;
          } catch (_) {}
          _setBusy(false);
        },
        verificationFailed: (e) {
          _errorMessage = e.message ?? 'Verification failed';
          _status = AuthStatus.error;
          _setBusy(false);
        },
        codeAutoRetrievalTimeout: (verificationId) {
          _verificationId = verificationId;
        },
      );
    } catch (e) {
      _errorMessage = e.toString();
      _status = AuthStatus.error;
      _setBusy(false);
    }
  }

  /// Verifies the entered SMS code. Returns true on success.
  Future<bool> verifyOtp(String smsCode) async {
    if (_verificationId == null) return false;
    _setBusy(true);
    _errorMessage = null;
    try {
      await _auth.signInWithSmsCode(
        verificationId: _verificationId!,
        smsCode: smsCode,
      );
      _status = AuthStatus.authenticated;
      await loadCurrentUser();
      _setBusy(false);
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _status = AuthStatus.error;
      _setBusy(false);
      return false;
    }
  }

  /// Persists the profile created during setup.
  Future<bool> saveProfile({
    required String name,
    required String address,
    required String city,
    required String postalCode,
    required String group,
    required String language,
  }) async {
    final id = _auth.currentUser?.uid;
    if (id == null) return false;
    _setBusy(true);
    try {
      final user = UserModel(
        id: id,
        phone: _auth.currentUser?.phoneNumber ?? '',
        name: name,
        address: address,
        city: city,
        postalCode: postalCode,
        group: group,
        language: language,
        fcmToken: '',
        createdAt: null,
      );
      await _db.saveUser(user);
      _user = user;
      await _saveFcmToken();
      _setBusy(false);
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _setBusy(false);
      return false;
    }
  }

  Future<void> updateProfileFields(Map<String, dynamic> data) async {
    final id = _auth.currentUser?.uid;
    if (id == null) return;
    try {
      await _db.updateUserFields(id, data);
      await loadCurrentUser();
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
    }
  }

  Future<void> _saveFcmToken() async {
    final id = _auth.currentUser?.uid;
    if (id == null) return;
    try {
      final token = await FirebaseMessaging.instance.getToken();
      if (token != null) {
        await _db.updateFcmToken(id, token);
        _user = _user?.copyWith(fcmToken: token);
      }
    } catch (_) {
      // FCM token retrieval is best-effort.
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
    _errorMessage = null;
    notifyListeners();
  }
}
