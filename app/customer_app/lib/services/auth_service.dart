import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../utils/constants.dart';
import 'api_client.dart';

/// Raised when native Google Sign-In could not produce an idToken — almost
/// always a console misconfiguration (missing Android OAuth client / SHA-1, or
/// a wrong server client id).
class GoogleAuthException implements Exception {
  final String message;
  GoogleAuthException(this.message);
  @override
  String toString() => message;
}

/// Authentication against the backend (phone OTP + email/password + Google).
class AuthService {
  AuthService._();
  static final AuthService instance = AuthService._();

  final ApiClient _api = ApiClient.instance;

  /// serverClientId makes Google return an idToken whose audience is our
  /// backend's Web client id (see [AppConstants.googleServerClientId]).
  final GoogleSignIn _google = GoogleSignIn(
    scopes: const ['email', 'profile'],
    serverClientId: AppConstants.googleServerClientId,
  );

  bool get isLoggedIn => _api.isLoggedIn;
  String? get uid => _api.uid;
  String? get phone => _api.currentUser?['phone'] as String?;

  /// Requests an SMS code. Returns the dev-mode code when the backend runs
  /// with the dev SMS provider (so testing needs no real SMS), else null.
  Future<String?> requestOtp(String phoneNumber) async {
    final res = await _api.post('/v1/auth/otp/request', {'phone': phoneNumber});
    return (res as Map)['devCode'] as String?;
  }

  /// Verifies the code; on success the session is stored. Returns the auth
  /// payload ({user, isNewUser, ...}).
  Future<Map<String, dynamic>> verifyOtp(String phoneNumber, String code) async {
    final res = await _api.post('/v1/auth/otp/verify', {'phone': phoneNumber, 'code': code});
    final body = Map<String, dynamic>.from(res as Map);
    await _api.saveSession(body);
    return body;
  }

  /// Runs the native Google account picker, exchanges the resulting idToken for
  /// a backend session. Returns the auth payload ({user, isNewUser, ...}), or
  /// null if the user dismissed the picker.
  Future<Map<String, dynamic>?> signInWithGoogle() async {
    // Force a fresh account choice rather than silently reusing the last one.
    await _google.signOut();
    GoogleSignInAccount? account;
    try {
      account = await _google.signIn();
    } on PlatformException catch (e) {
      // The GMS layer failed before/at the picker — surface the real code
      // (10 = DEVELOPER_ERROR → SHA-1 / package / serverClientId mismatch).
      debugPrint('[GOOGLE] signIn PlatformException '
          'code=${e.code} message=${e.message} details=${e.details}');
      throw GoogleAuthException('Google sign-in error [${e.code}]: ${e.message ?? ''}');
    }
    if (account == null) return null; // user cancelled
    final tokens = await account.authentication;
    final idToken = tokens.idToken;
    debugPrint('[GOOGLE] signed in as ${account.email}; '
        'idToken=${idToken == null ? "NULL" : "len ${idToken.length}"}');
    if (idToken == null || idToken.isEmpty) {
      throw GoogleAuthException(
          'Google sign-in failed to return a token — check the Android OAuth client / SHA-1.');
    }
    final res = await _api.post('/v1/auth/google', {'idToken': idToken});
    final body = Map<String, dynamic>.from(res as Map);
    await _api.saveSession(body);
    return body;
  }

  Future<Map<String, dynamic>> signInWithEmail({
    required String email,
    required String password,
  }) async {
    final res = await _api.post('/v1/auth/email/login', {'email': email.trim(), 'password': password});
    final body = Map<String, dynamic>.from(res as Map);
    await _api.saveSession(body);
    return body;
  }

  Future<void> signOut() async {
    try {
      await _api.post('/v1/auth/logout', {'refreshToken': _api.refreshToken});
    } catch (_) {
      // Best effort — the local session is cleared regardless.
    }
    try {
      await _google.signOut();
    } catch (_) {
      // Google may not have been used this session; ignore.
    }
    await _api.clearSession();
  }

  /// Deletes (anonymizes + deactivates) the account server-side.
  Future<void> deleteCurrentUser() async {
    await _api.delete('/v1/users/me');
    await _api.clearSession();
  }
}
