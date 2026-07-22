import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'api_client.dart';

/// Registers this device's push token with the backend so the server can send
/// FCM (Android) / APNs (iOS) notifications while the app is backgrounded or
/// closed — the socket only covers the foreground.
///
/// The native token is obtained over a platform channel (`sarko/push`) rather
/// than the Firebase Dart SDK. Until the native side is wired up (google-services
/// config on Android, APNs entitlement on iOS), [getToken] simply returns null
/// and registration is skipped — no crash, no dead push rows. The backend
/// endpoint and delivery pipeline already exist (`POST /v1/users/me/fcm-token`,
/// `PushService`), so enabling push is purely a native-config step.
class PushService {
  PushService._();
  static final PushService instance = PushService._();

  static const _channel = MethodChannel('sarko/push');
  final ApiClient _api = ApiClient.instance;

  /// Fetches the platform push token, or null if push isn't wired up natively.
  Future<String?> getToken() async {
    try {
      final token = await _channel.invokeMethod<String>('getToken');
      return (token != null && token.isNotEmpty) ? token : null;
    } on MissingPluginException {
      return null; // native side not implemented yet
    } catch (e) {
      debugPrint('PushService.getToken failed: $e');
      return null;
    }
  }

  /// Called after login: registers the current token (if any) and keeps the
  /// backend in sync when the OS rotates it.
  Future<void> register() async {
    final token = await getToken();
    if (token != null) await _sendToken(token);
    // Token rotations arrive on the same channel as a `tokenRefresh` call.
    _channel.setMethodCallHandler((call) async {
      if (call.method == 'tokenRefresh' && call.arguments is String) {
        await _sendToken(call.arguments as String);
      }
    });
  }

  Future<void> _sendToken(String token) async {
    try {
      await _api.post('/v1/users/me/fcm-token', {'token': token});
    } catch (e) {
      debugPrint('PushService.register failed: $e');
    }
  }
}
