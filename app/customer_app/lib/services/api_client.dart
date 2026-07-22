import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:http/http.dart' as http;

import '../session/secure_session_store.dart';
import '../utils/constants.dart';

class ApiException implements Exception {
  final int statusCode;
  final String message;
  ApiException(this.statusCode, this.message);

  @override
  String toString() => message;
}

/// HTTP client for the Sarko Delivery backend.
///
/// Owns the JWT session (access + refresh token in SharedPreferences),
/// transparently refreshes on 401, and sends the device-identification
/// headers the backend uses for per-platform routing and audit
/// (X-Client-Platform / X-App-Version / X-Device-Model / X-OS-Version).
class ApiClient {
  ApiClient._();
  static final ApiClient instance = ApiClient._();

  static String get baseUrl => AppConstants.apiBaseUrl;

  String? _accessToken;
  String? _refreshToken;
  Map<String, dynamic>? currentUser;

  bool get isLoggedIn => _refreshToken != null;
  String? get uid => currentUser?['id'] as String?;
  String? get accessToken => _accessToken;

  final _secureSession = SecureSessionStore.instance;

  /// Must be awaited once in main() before the first screen builds.
  Future<void> init() async {
    _accessToken = await _secureSession.readAccessToken();
    _refreshToken = await _secureSession.readRefreshToken();
    // Restore *who* is logged in, so uid is known before the first network
    // call — otherwise the profile lookup keys off an empty id and a
    // perfectly valid session looks logged-out.
    currentUser = await _secureSession.readUser();
  }

  Future<void> saveSession(Map<String, dynamic> auth) async {
    _accessToken = auth['accessToken'] as String?;
    _refreshToken = auth['refreshToken'] as String? ?? _refreshToken;
    if (auth['user'] is Map) {
      currentUser = Map<String, dynamic>.from(auth['user'] as Map);
    }
    await _secureSession.save(
      accessToken: _accessToken,
      refreshToken: _refreshToken,
      user: currentUser,
    );
  }

  /// Updates the cached current-user (e.g. after a profile sync) and persists
  /// it so a cold start still knows the logged-in identity.
  Future<void> setCurrentUser(Map<String, dynamic> user) async {
    currentUser = Map<String, dynamic>.from(user);
    await _secureSession.save(user: currentUser);
  }

  Future<void> clearSession() async {
    _accessToken = null;
    _refreshToken = null;
    currentUser = null;
    await _secureSession.clear();
  }

  String? get refreshToken => _refreshToken;

  Map<String, String> headers({bool json = true}) => {
        if (json) 'Content-Type': 'application/json',
        if (_accessToken != null) 'Authorization': 'Bearer $_accessToken',
        'X-Client-Platform': Platform.isIOS ? 'ios' : 'android',
        'X-App-Version': AppConstants.appVersion,
        'X-Device-Model': Platform.localHostname,
        'X-OS-Version': Platform.operatingSystemVersion,
      };

  Future<dynamic> get(String path) => _send('GET', path);
  Future<dynamic> post(String path, [Object? body]) => _send('POST', path, body ?? {});
  Future<dynamic> patch(String path, [Object? body]) => _send('PATCH', path, body ?? {});
  Future<dynamic> put(String path, [Object? body]) => _send('PUT', path, body ?? {});
  Future<dynamic> delete(String path) => _send('DELETE', path);

  Future<dynamic> _send(String method, String path, [Object? body, bool canRetry = true]) async {
    final cleanBase = baseUrl.endsWith('/') ? baseUrl.substring(0, baseUrl.length - 1) : baseUrl;
    final cleanPath = path.startsWith('/') ? path : '/$path';
    final uri = Uri.parse('$cleanBase$cleanPath');
    http.Response res;
    try {
      final req = http.Request(method, uri)..headers.addAll(headers());
      if (body != null) req.body = jsonEncode(body);
      res = await http.Response.fromStream(
          await req.send().timeout(const Duration(seconds: 25)));
    } on SocketException {
      throw ApiException(0, 'No connection to the server');
    } on TimeoutException {
      throw ApiException(0, 'Server did not respond, try again');
    }

    if (res.statusCode == 401 && canRetry && _refreshToken != null && path != '/v1/auth/refresh') {
      if (await _tryRefresh()) return _send(method, path, body, false);
      await clearSession();
    }
    return _decode(res);
  }

  Future<bool> _tryRefresh() async {
    try {
      final cleanBase = baseUrl.endsWith('/') ? baseUrl.substring(0, baseUrl.length - 1) : baseUrl;
      final res = await http.post(
        Uri.parse('$cleanBase/v1/auth/refresh'),
        headers: headers(),
        body: jsonEncode({'refreshToken': _refreshToken}),
      );
      if (res.statusCode != 200) return false;
      await saveSession(jsonDecode(res.body) as Map<String, dynamic>);
      return true;
    } catch (_) {
      return false;
    }
  }

  dynamic _decode(http.Response res) {
    dynamic body;
    try {
      body = res.body.isEmpty ? {} : jsonDecode(res.body);
    } catch (_) {
      body = {};
    }
    if (res.statusCode >= 200 && res.statusCode < 300) return body;
    var message = 'Request failed (${res.statusCode})';
    if (body is Map && body['message'] != null) {
      final m = body['message'];
      message = m is List ? m.join('\n') : m.toString();
    }
    throw ApiException(res.statusCode, message);
  }

  Future<List<String>> _upload(
    String path, {
    required String field,
    List<http.MultipartFile> files = const [],
  }) async {
    final cleanBase = baseUrl.endsWith('/') ? baseUrl.substring(0, baseUrl.length - 1) : baseUrl;
    final cleanPath = path.startsWith('/') ? path : '/$path';
    final req = http.MultipartRequest('POST', Uri.parse('$cleanBase$cleanPath'))
      ..headers.addAll(headers(json: false))
      ..files.addAll(files);
    final res = await http.Response.fromStream(await req.send());
    final body = _decode(res);
    if (body is Map && body['urls'] is List) return List<String>.from(body['urls'] as List);
    if (body is Map && body['url'] is String) return [body['url'] as String];
    return [];
  }

  Future<String> uploadBytes(String path, Uint8List bytes,
      {required String filename, String field = 'files'}) async {
    final urls = await _upload(path, field: field, files: [
      http.MultipartFile.fromBytes(field, bytes, filename: filename),
    ]);
    if (urls.isEmpty) throw ApiException(0, 'Upload failed');
    return urls.first;
  }

  Future<String> uploadFilePath(String path, String filePath,
      {String field = 'files'}) async {
    final urls = await _upload(path, field: field, files: [
      await http.MultipartFile.fromPath(field, filePath),
    ]);
    if (urls.isEmpty) throw ApiException(0, 'Upload failed');
    return urls.first;
  }

  /// Turns a fetch into a periodic stream: emits immediately, then
  /// re-fetches every [interval]. Errors after the first emission are
  /// swallowed so a flaky connection doesn't kill open StreamBuilders.
  static Stream<T> poll<T>(Duration interval, Future<T> Function() fetch) async* {
    var first = true;
    while (true) {
      try {
        yield await fetch();
      } catch (e) {
        if (first) yield* Stream<T>.error(e);
      }
      first = false;
      await Future<void>.delayed(interval);
    }
  }
}
