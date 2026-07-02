import 'dart:convert';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

/// Displays real Android notifications (including foreground, which FCM does
/// not auto-display), groups them per chat, and routes taps back to the app.
class LocalNotifications {
  LocalNotifications._();

  static final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  /// Set by the app to route a tapped notification (data payload) to a screen.
  static void Function(Map<String, dynamic> data)? onSelect;

  static const AndroidNotificationChannel channel = AndroidNotificationChannel(
    'sarkis_bread_admin_channel',
    'Сообщения и заказы',
    description: 'Новые сообщения и обновления заказов',
    importance: Importance.high,
  );

  static Future<void> init() async {
    if (kIsWeb) return;
    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    await _plugin.initialize(
      const InitializationSettings(android: android),
      onDidReceiveNotificationResponse: (resp) {
        final p = resp.payload;
        if (p == null || p.isEmpty) return;
        try {
          final data = (jsonDecode(p) as Map).cast<String, dynamic>();
          onSelect?.call(data);
        } catch (_) {}
      },
    );
    await _plugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);
  }

  /// Shows a heads-up notification for a foreground FCM message. Messages from
  /// the same chat share a tag/id so they replace (not stack).
  static Future<void> showFromMessage(RemoteMessage m) async {
    if (kIsWeb) return;
    final n = m.notification;
    final data = m.data;
    final title = n?.title ?? (data['title'] as String?) ?? 'Sarkis Delivery';
    final body = n?.body ?? (data['body'] as String?) ?? '';
    if (title.isEmpty && body.isEmpty) return;

    final type = (data['type'] as String?) ?? '';
    final topicId = (data['topicId'] as String?) ?? '';
    final tag = type == 'chat' && topicId.isNotEmpty ? 'chat_$topicId' : null;
    final id = tag != null
        ? tag.hashCode & 0x7fffffff
        : DateTime.now().millisecondsSinceEpoch ~/ 1000;

    await _plugin.show(
      id,
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
          tag: tag,
        ),
      ),
      payload: jsonEncode(data),
    );
  }
}
