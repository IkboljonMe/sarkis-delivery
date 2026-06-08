import 'package:firebase_messaging/firebase_messaging.dart';

import 'user_service.dart';

/// Customer-side FCM: request permission, save token, listen for messages.
class FcmService {
  FcmService._();
  static final FcmService instance = FcmService._();

  final FirebaseMessaging _fm = FirebaseMessaging.instance;

  Future<void> init(String uid) async {
    try {
      await _fm.requestPermission();
      final token = await _fm.getToken();
      if (token != null) {
        await UserService.instance.updateFcmToken(uid, token);
      }
      _fm.onTokenRefresh.listen((t) {
        UserService.instance.updateFcmToken(uid, t);
      });
    } catch (_) {
      // Best-effort; messaging is not available on every platform/run.
    }
  }

  /// Fires while the app is in the foreground.
  Stream<RemoteMessage> get onForegroundMessage => FirebaseMessaging.onMessage;

  /// Fires when the user taps a notification that opened/resumed the app.
  Stream<RemoteMessage> get onMessageOpened =>
      FirebaseMessaging.onMessageOpenedApp;
}
