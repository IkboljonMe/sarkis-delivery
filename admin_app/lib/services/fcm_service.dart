import 'package:firebase_messaging/firebase_messaging.dart';

import 'user_service.dart';

/// Admin-side FCM: registers this device's token (so admins receive pushes for
/// new customer messages) and exposes the foreground/opened message streams.
///
/// Sending is done server-side by Cloud Functions, so no service-account key
/// ships inside the app.
class FcmService {
  FcmService._();
  static final FcmService instance = FcmService._();

  final FirebaseMessaging _fm = FirebaseMessaging.instance;

  /// Requests permission and saves the admin's FCM token under their user doc.
  Future<void> registerToken(String adminUid) async {
    try {
      await _fm.requestPermission();
      final token = await _fm.getToken();
      if (token != null) {
        await UserService.instance.updateFcmToken(adminUid, token);
      }
      _fm.onTokenRefresh.listen((t) {
        UserService.instance.updateFcmToken(adminUid, t);
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
