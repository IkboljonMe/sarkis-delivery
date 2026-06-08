import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

/// Displays real Android notifications, including when the app is in the
/// foreground (FCM does not auto-display those). Also defines the channel used
/// by background FCM notifications (referenced from AndroidManifest).
class LocalNotifications {
  LocalNotifications._();

  static final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  static const AndroidNotificationChannel channel = AndroidNotificationChannel(
    'sarkis_bread_admin_channel',
    'Сообщения и заказы',
    description: 'Новые сообщения и обновления заказов',
    importance: Importance.high,
  );

  static Future<void> init() async {
    if (kIsWeb) return;
    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    await _plugin.initialize(const InitializationSettings(android: android));
    await _plugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);
  }

  /// Shows a heads-up notification for a foreground FCM message.
  static Future<void> showFromMessage(RemoteMessage m) async {
    if (kIsWeb) return;
    final n = m.notification;
    final title =
        n?.title ?? (m.data['title'] as String?) ?? 'Sarkis Bread';
    final body = n?.body ?? (m.data['body'] as String?) ?? '';
    if (title.isEmpty && body.isEmpty) return;
    await _plugin.show(
      DateTime.now().millisecondsSinceEpoch ~/ 1000,
      title,
      body,
      NotificationDetails(
        android: AndroidNotificationDetails(
          channel.id,
          channel.name,
          channelDescription: channel.description,
          importance: Importance.high,
          priority: Priority.high,
          icon: '@mipmap/ic_launcher',
        ),
      ),
    );
  }
}
