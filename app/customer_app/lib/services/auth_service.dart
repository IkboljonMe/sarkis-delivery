import 'api_client.dart';

/// Authentication against the Sarkis backend (phone OTP + email/password).
class AuthService {
  AuthService._();
  static final AuthService instance = AuthService._();

  final ApiClient _api = ApiClient.instance;

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
    await _api.clearSession();
  }

  /// Deletes (anonymizes + deactivates) the account server-side.
  Future<void> deleteCurrentUser() async {
    await _api.delete('/v1/users/me');
    await _api.clearSession();
  }
}
