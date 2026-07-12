import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

/// Handles both phone auth (customer) and email/password auth (admin).
class AuthService {
  AuthService._();
  static final AuthService instance = AuthService._();

  final FirebaseAuth _auth = FirebaseAuth.instance;

  User? get currentUser => _auth.currentUser;
  String? get uid => _auth.currentUser?.uid;
  bool get isLoggedIn => _auth.currentUser != null;
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // ---- Phone (customer) ----
  Future<void> verifyPhoneNumber({
    required String phoneNumber,
    required void Function(String, int?) codeSent,
    required void Function(PhoneAuthCredential) verificationCompleted,
    required void Function(FirebaseAuthException) verificationFailed,
    required void Function(String) codeAutoRetrievalTimeout,
    int? forceResendingToken,
  }) async {
    // Allow registered test numbers to bypass reCAPTCHA in debug builds.
    if (kDebugMode) {
      try {
        await _auth.setSettings(appVerificationDisabledForTesting: true);
      } catch (_) {}
    }
    await _auth.verifyPhoneNumber(
      phoneNumber: phoneNumber,
      timeout: const Duration(seconds: 60),
      forceResendingToken: forceResendingToken,
      verificationCompleted: verificationCompleted,
      verificationFailed: verificationFailed,
      codeSent: codeSent,
      codeAutoRetrievalTimeout: codeAutoRetrievalTimeout,
    );
  }

  Future<UserCredential> signInWithSmsCode({
    required String verificationId,
    required String smsCode,
  }) async {
    try {
      final cred = PhoneAuthProvider.credential(
        verificationId: verificationId,
        smsCode: smsCode,
      );
      return await _auth.signInWithCredential(cred);
    } catch (e) {
      throw Exception('Invalid code. Please try again.');
    }
  }

  Future<UserCredential> signInWithCredential(PhoneAuthCredential c) =>
      _auth.signInWithCredential(c);

  // ---- Email (admin) ----
  Future<UserCredential> signInWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      return await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
    } on FirebaseAuthException catch (e) {
      throw Exception(_emailError(e.code));
    }
  }

  Future<void> signOut() => _auth.signOut();

  /// Deletes the Firebase Auth user. May throw `requires-recent-login`.
  Future<void> deleteCurrentUser() => _auth.currentUser?.delete() ?? Future.value();

  String _emailError(String code) {
    switch (code) {
      case 'invalid-email':
        return 'Неверный email / Invalid email';
      case 'user-not-found':
      case 'wrong-password':
      case 'invalid-credential':
        return 'Неверный логин или пароль / Wrong credentials';
      case 'too-many-requests':
        return 'Слишком много попыток / Too many attempts';
      default:
        return 'Ошибка входа / Login error';
    }
  }
}
