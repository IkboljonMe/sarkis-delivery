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

  Future<String?> readAccessToken() => _storage.read(key: _kAccess);
  Future<String?> readRefreshToken() => _storage.read(key: _kRefresh);

  Future<void> save({String? accessToken, String? refreshToken}) async {
    if (accessToken != null) await _storage.write(key: _kAccess, value: accessToken);
    if (refreshToken != null) await _storage.write(key: _kRefresh, value: refreshToken);
  }

  Future<void> clear() async {
    await _storage.delete(key: _kAccess);
    await _storage.delete(key: _kRefresh);
  }
}
