import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Replaces the plaintext `SharedPreferences` token storage that used to
/// live directly in [ApiClient] — access/refresh JWTs are now Keychain
/// (iOS) / Keystore (Android) backed instead of a plain string in prefs.
class SecureSessionStore {
  SecureSessionStore._();
  static final SecureSessionStore instance = SecureSessionStore._();

  static const _storage = FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
  );

  static const _kAccess = 'api_access';
  static const _kRefresh = 'api_refresh';
  static const _kUser = 'api_user';

  Future<String?> readAccessToken() => _storage.read(key: _kAccess);
  Future<String?> readRefreshToken() => _storage.read(key: _kRefresh);

  /// The cached current-user JSON, so the app knows *who* is logged in on a
  /// cold start (before any network call) — this is what keeps the session
  /// from looking logged-out after a restart.
  Future<Map<String, dynamic>?> readUser() async {
    final raw = await _storage.read(key: _kUser);
    if (raw == null || raw.isEmpty) return null;
    try {
      return Map<String, dynamic>.from(jsonDecode(raw) as Map);
    } catch (_) {
      return null;
    }
  }

  Future<void> save({
    String? accessToken,
    String? refreshToken,
    Map<String, dynamic>? user,
  }) async {
    if (accessToken != null) await _storage.write(key: _kAccess, value: accessToken);
    if (refreshToken != null) await _storage.write(key: _kRefresh, value: refreshToken);
    if (user != null) await _storage.write(key: _kUser, value: jsonEncode(user));
  }

  Future<void> clear() async {
    await _storage.delete(key: _kAccess);
    await _storage.delete(key: _kRefresh);
    await _storage.delete(key: _kUser);
  }
}
