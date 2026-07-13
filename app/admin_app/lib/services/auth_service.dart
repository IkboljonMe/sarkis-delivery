import 'api_client.dart';

/// Staff authentication (email/password — credentials are created by the
/// superadmin on the backend).
class AuthService {
  AuthService._();
  static final AuthService instance = AuthService._();

  final ApiClient _api = ApiClient.instance;

  bool get isLoggedIn => _api.isLoggedIn;
  String? get uid => _api.uid;
  Map<String, dynamic>? get currentUser => _api.currentUser;

  /// Logs in and stores the session. Returns the auth payload ({user, ...}).
  Future<Map<String, dynamic>> signInWithEmail({
    required String email,
    required String password,
  }) async {
    final res = await _api
        .post('/v1/auth/email/login', {'email': email.trim(), 'password': password});
    final body = Map<String, dynamic>.from(res as Map);
    await _api.saveSession(body);
    return body;
  }

  Future<void> signOut() async {
    try {
      await _api.post('/v1/auth/logout', {'refreshToken': _api.refreshToken});
    } catch (_) {}
    await _api.clearSession();
  }
}
