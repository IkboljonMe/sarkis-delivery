import 'dart:convert';

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

/// Displays real Android notifications (including foreground) in reaction to
/// the realtime `notification:created` socket event, groups them per chat,
/// and routes taps back to the app.
class LocalNotifications {
  LocalNotifications._();

  static final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  /// Set by the app to route a tapped notification (data payload) to a screen.
  static void Function(Map<String, dynamic> data)? onSelect;

  static const AndroidNotificationChannel channel = AndroidNotificationChannel(
    'app_notifications_channel',
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

  /// Shows a heads-up notification for a `notification:created` socket event
  /// payload. Notifications from the same chat share a tag/id so they replace
  /// (not stack).
  static Future<void> showFromPayload(Map<String, dynamic> payload) async {
    if (kIsWeb) return;
    final data = (payload['data'] as Map?)?.cast<String, dynamic>() ?? const {};
    final title = (payload['title'] as String?) ?? 'Sarko Delivery';
    final body = (payload['body'] as String?) ?? '';
    if (title.isEmpty && body.isEmpty) return;

    final type = (payload['type'] as String?) ?? (data['type'] as String?) ?? '';
    final topicId =
        (payload['topicId'] as String?) ?? (data['topicId'] as String?) ?? '';
    final tag = type == 'chat' && topicId.isNotEmpty ? 'chat_$topicId' : null;
    final id = tag != null
        ? tag.hashCode & 0x7fffffff
        : DateTime.now().millisecondsSinceEpoch ~/ 1000;

    // Tap routing (see `routeNotification`) only needs `type`/`topicId`, so
    // carry those alongside whatever extra fields `data` already has.
    final tapPayload = {...data, 'type': type, 'topicId': topicId};

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
      payload: jsonEncode(tapPayload),
    );
  }
}
