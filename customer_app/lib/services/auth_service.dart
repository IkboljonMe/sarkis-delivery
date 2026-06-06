import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

/// Wraps Firebase Phone Authentication for the customer app.
class AuthService {
  AuthService._();
  static final AuthService instance = AuthService._();

  final FirebaseAuth _auth = FirebaseAuth.instance;

  User? get currentUser => _auth.currentUser;
  bool get isLoggedIn => _auth.currentUser != null;
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  /// Starts phone verification. Callbacks bubble up to the provider/UI.
  Future<void> verifyPhoneNumber({
    required String phoneNumber,
    required void Function(String verificationId, int? resendToken) codeSent,
    required void Function(PhoneAuthCredential credential)
        verificationCompleted,
    required void Function(FirebaseAuthException e) verificationFailed,
    required void Function(String verificationId) codeAutoRetrievalTimeout,
    int? forceResendingToken,
  }) async {
    try {
      // In debug/testing, disable app verification (reCAPTCHA/SMS) so that
      // registered test phone numbers work with their fixed codes — no captcha.
      if (kDebugMode) {
        try {
          await _auth.setSettings(appVerificationDisabledForTesting: true);
        } catch (_) {
          // Not supported on every platform; safe to ignore.
        }
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
    } catch (e) {
      throw Exception('Failed to start phone verification: $e');
    }
  }

  /// Signs in with the SMS code the user entered.
  Future<UserCredential> signInWithSmsCode({
    required String verificationId,
    required String smsCode,
  }) async {
    try {
      final credential = PhoneAuthProvider.credential(
        verificationId: verificationId,
        smsCode: smsCode,
      );
      return await _auth.signInWithCredential(credential);
    } catch (e) {
      throw Exception('Invalid code. Please try again.');
    }
  }

  Future<UserCredential> signInWithCredential(
      PhoneAuthCredential credential) async {
    try {
      return await _auth.signInWithCredential(credential);
    } catch (e) {
      throw Exception('Sign-in failed: $e');
    }
  }

  Future<void> signOut() async {
    try {
      await _auth.signOut();
    } catch (e) {
      throw Exception('Failed to sign out: $e');
    }
  }
}
