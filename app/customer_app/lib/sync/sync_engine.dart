import 'dart:async';
import 'dart:convert';

import 'package:drift/drift.dart';

import '../local_db/app_database.dart';
import '../realtime/socket_service.dart';
import '../services/api_client.dart';

/// Single source of truth for keeping the local Drift cache current.
///
/// Three inputs feed it:
///  1. Socket events (live, while connected) — upserted straight into Drift.
///  2. `since=` REST delta pulls — called on login, app-resume, and socket
///     reconnect, as the safety net for anything missed while disconnected.
///  3. [MutationQueue] optimistic writes (place order, send message, ...) —
///     written directly to Drift by the queue itself; SyncEngine just
///     reconciles them once the server ack / socket echo arrives.
///
/// Every screen reads Drift via `.watch()` instead of polling the network —
/// this is what replaces `ApiClient.poll()` everywhere.
class SyncEngine {
  SyncEngine(this._db, this._api, this._socket);

  final AppDatabase _db;
  final ApiClient _api;
  final SocketService _socket;
  StreamSubscription? _eventsSub;

  void start(String userId) {
    _eventsSub?.cancel();
    _eventsSub = _socket.events.listen((e) => _handleEvent(e, userId));
    _socket.connect();
    _socket.joinChat(userId);
  }

  Future<void> stop() async {
    await _eventsSub?.cancel();
    _eventsSub = null;
    _socket.disconnect();
  }

  /// Full seed on login + safety-net catch-up on resume/reconnect.
  Future<void> fullSync(String userId) async {
    await Future.wait([
      syncOrders(),
      syncMessages(userId),
      syncNotifications(),
      syncApprovals(),
      syncCatalog(),
      syncShifts(),
      syncZones(),
    ]);
  }

  void _handleEvent(RealtimeEvent e, String userId) {
    switch (e.name) {
      case 'order:created':
      case 'order:updated':
        _upsertOrder(e.payload as Map);
        break;
      case 'message:created':
      case 'message:updated':
        _upsertMessage(e.payload as Map);
        break;
      case 'topic:updated':
        _upsertTopic(e.payload as Map);
        break;
      case 'notification:created':
        _upsertNotification(e.payload as Map);
        break;
      case 'approval:created':
      case 'approval:updated':
        _upsertApproval(e.payload as Map);
        break;
    }
  }

  // ---------- orders ----------

  Future<void> syncOrders() async {
    final since = await _cursor('orders');
    final path = since == null ? '/v1/orders/mine' : '/v1/orders/mine?since=${Uri.encodeComponent(since.toIso8601String())}';
    final rows = await _api.get(path) as List;
    for (final row in rows) {
      await _upsertOrder(row as Map);
    }
    await _setCursor('orders', DateTime.now());
  }

  Future<void> _upsertOrder(Map json) async {
    final id = json['id'] as String;
    await _db.into(_db.orders).insertOnConflictUpdate(OrdersCompanion.insert(
          id: id,
          userId: json['userId'] as String,
          status: json['status'] as String,
          driverId: Value(json['driverId'] as String? ?? ''),
          shiftId: Value(json['shiftId'] as String? ?? ''),
          shiftDate: Value(_parseDate(json['shiftDate'])),
          shiftLabel: Value(json['shiftLabel'] as String? ?? ''),
          subtotal: Value((json['subtotal'] as num?)?.toDouble() ?? 0),
          discount: Value((json['discount'] as num?)?.toDouble() ?? 0),
          couponCode: Value(json['couponCode'] as String? ?? ''),
          totalPrice: Value((json['totalPrice'] as num?)?.toDouble() ?? 0),
          userName: Value(json['userName'] as String? ?? ''),
          userAddress: Value(json['userAddress'] as String? ?? ''),
          userCity: Value(json['userCity'] as String? ?? ''),
          adminNote: Value(json['adminNote'] as String? ?? ''),
          pendingApproval: Value(json['pendingApproval'] as bool? ?? false),
          awaitingSchedule: Value(json['awaitingSchedule'] as bool? ?? false),
          createdAt: _parseDate(json['createdAt']) ?? DateTime.now(),
          updatedAt: _parseDate(json['updatedAt']) ?? DateTime.now(),
          pendingSync: const Value(false),
        ));

    await (_db.delete(_db.orderItemRows)..where((t) => t.orderId.equals(id))).go();
    final items = (json['items'] as List?) ?? const [];
    for (var i = 0; i < items.length; i++) {
      final item = items[i] as Map;
      await _db.into(_db.orderItemRows).insertOnConflictUpdate(OrderItemRowsCompanion.insert(
            id: '${id}_$i',
            orderId: id,
            productId: Value(item['productId'] as String? ?? ''),
            name: Value(item['name'] as String? ?? ''),
            qty: item['qty'] as int? ?? 0,
            unitPrice: (item['unitPrice'] as num?)?.toDouble() ?? 0,
          ));
    }
  }

  // ---------- chat ----------

  Future<void> syncMessages(String topicId) async {
    final since = await _cursor('messages:$topicId');
    final path = since == null
        ? '/v1/messages/$topicId'
        : '/v1/messages/$topicId?after=${Uri.encodeComponent(since.toIso8601String())}';
    final rows = await _api.get(path) as List;
    for (final row in rows) {
      await _upsertMessage(row as Map, topicId: topicId);
    }
    if (rows.isNotEmpty) await _setCursor('messages:$topicId', DateTime.now());

    final topic = await _api.get('/v1/messages/topics/$topicId') as Map;
    await _upsertTopic(topic);
  }

  Future<void> _upsertMessage(Map json, {String? topicId}) async {
    await _db.into(_db.messages).insertOnConflictUpdate(MessagesCompanion.insert(
          id: json['id'] as String,
          topicId: topicId ?? (json['topicId'] as String? ?? ''),
          senderId: json['senderId'] as String,
          senderName: Value(json['senderName'] as String? ?? ''),
          isFromAdmin: Value(json['isFromAdmin'] as bool? ?? false),
          isRead: Value(json['isRead'] as bool? ?? false),
          type: Value(json['type'] as String? ?? 'text'),
          content: Value(json['text'] as String? ?? ''),
          deleted: Value(json['deleted'] as bool? ?? false),
          extraJson: Value(_encodeExtra(json)),
          createdAt: _parseDate(json['createdAt']) ?? DateTime.now(),
          updatedAt: DateTime.now(),
          pendingSync: const Value(false),
        ));
  }

  Future<void> _upsertTopic(Map json) async {
    final id = json['topicId'] as String? ?? json['id'] as String;
    await _db.into(_db.chatTopics).insertOnConflictUpdate(ChatTopicsCompanion.insert(
          id: id,
          userName: Value(json['userName'] as String? ?? ''),
          lastMessage: Value(json['lastMessage'] as String? ?? ''),
          lastAt: Value(_parseDate(json['lastAt'])),
          lastFromAdmin: Value(json['lastFromAdmin'] as bool? ?? false),
          customerUnread: Value(json['customerUnread'] as int? ?? 0),
        ));
  }

  // ---------- notifications ----------

  Future<void> syncNotifications() async {
    final since = await _cursor('notifications');
    final path = since == null ? '/v1/notifications' : '/v1/notifications?since=${Uri.encodeComponent(since.toIso8601String())}';
    final rows = await _api.get(path) as List;
    for (final row in rows) {
      await _upsertNotification(row as Map);
    }
    await _setCursor('notifications', DateTime.now());
  }

  Future<void> _upsertNotification(Map json) async {
    await _db.into(_db.notificationRows).insertOnConflictUpdate(NotificationRowsCompanion.insert(
          id: json['id'] as String,
          type: Value(json['type'] as String? ?? 'system'),
          title: Value(json['title'] as String? ?? ''),
          body: Value(json['body'] as String? ?? ''),
          dataJson: Value(_encodeMap(json['data'])),
          orderId: Value(json['orderId'] as String? ?? ''),
          topicId: Value(json['topicId'] as String? ?? ''),
          read: Value(json['read'] as bool? ?? false),
          createdAt: _parseDate(json['createdAt']) ?? DateTime.now(),
        ));
  }

  // ---------- approvals (small, low-volume — always full refresh) ----------

  Future<void> syncApprovals() async {
    final rows = await _api.get('/v1/approvals/mine') as List;
    await _db.delete(_db.approvals).go();
    for (final row in rows) {
      await _upsertApproval(row as Map);
    }
  }

  Future<void> _upsertApproval(Map json) async {
    await _db.into(_db.approvals).insertOnConflictUpdate(ApprovalsCompanion.insert(
          id: json['id'] as String,
          type: Value(json['type'] as String? ?? 'profile'),
          changesJson: Value(_encodeMap(json['changes'])),
          status: Value(json['status'] as String? ?? 'pending'),
          createdAt: _parseDate(json['createdAt']) ?? DateTime.now(),
        ));
  }

  // ---------- catalog / shifts / zones (low-frequency, since=-based) ----------

  Future<void> syncCatalog() async {
    final since = await _cursor('categories');
    final catPath = since == null ? '/v1/categories' : '/v1/categories?since=${Uri.encodeComponent(since.toIso8601String())}';
    for (final row in await _api.get(catPath) as List) {
      final c = row as Map;
      await _db.into(_db.categories).insertOnConflictUpdate(CategoriesCompanion.insert(
            id: c['id'] as String,
            nameJson: Value(_encodeMap(c['name'])),
            imageUrl: Value(c['imageUrl'] as String? ?? ''),
            sortOrder: Value(c['sortOrder'] as int? ?? 0),
            isActive: Value(c['isActive'] as bool? ?? true),
            updatedAt: _parseDate(c['updatedAt']) ?? DateTime.now(),
          ));
    }
    await _setCursor('categories', DateTime.now());

    final prodSince = await _cursor('products');
    final prodPath = prodSince == null ? '/v1/products' : '/v1/products?since=${Uri.encodeComponent(prodSince.toIso8601String())}';
    for (final row in await _api.get(prodPath) as List) {
      final p = row as Map;
      await _db.into(_db.products).insertOnConflictUpdate(ProductsCompanion.insert(
            id: p['id'] as String,
            categoryId: p['categoryId'] as String,
            nameJson: Value(_encodeMap(p['name'])),
            descriptionJson: Value(_encodeMap(p['description'])),
            price: (p['price'] as num?)?.toDouble() ?? 0,
            unit: Value(p['unit'] as String? ?? ''),
            maxQty: Value(p['maxQty'] as int? ?? 0),
            imageUrl: Value(p['imageUrl'] as String? ?? ''),
            imagesJson: Value(_encodeMap(p['images'])),
            isActive: Value(p['isActive'] as bool? ?? true),
            sortOrder: Value(p['sortOrder'] as int? ?? 0),
            discountType: Value(p['discountType'] as String? ?? 'none'),
            discountValue: Value((p['discountValue'] as num?)?.toDouble() ?? 0),
            updatedAt: _parseDate(p['updatedAt']) ?? DateTime.now(),
          ));
    }
    await _setCursor('products', DateTime.now());
  }

  Future<void> syncShifts() async {
    final since = await _cursor('shifts');
    final path = since == null ? '/v1/shifts' : '/v1/shifts?since=${Uri.encodeComponent(since.toIso8601String())}';
    for (final row in await _api.get(path) as List) {
      final s = row as Map;
      await _db.into(_db.shifts).insertOnConflictUpdate(ShiftsCompanion.insert(
            id: s['id'] as String,
            group: s['group'] as String,
            date: _parseDate(s['date']) ?? DateTime.now(),
            label: Value(s['label'] as String? ?? ''),
            isOpen: Value(s['isOpen'] as bool? ?? true),
            cancelDaysBefore: Value(s['cancelDaysBefore'] as int? ?? 1),
            editDaysBefore: Value(s['editDaysBefore'] as int? ?? 1),
            updatedAt: _parseDate(s['updatedAt']) ?? DateTime.now(),
          ));
    }
    await _setCursor('shifts', DateTime.now());
  }

  Future<void> syncZones() async {
    final since = await _cursor('zones');
    final path = since == null ? '/v1/zones' : '/v1/zones?since=${Uri.encodeComponent(since.toIso8601String())}';
    for (final row in await _api.get(path) as List) {
      final z = row as Map;
      await _db.into(_db.regionZones).insertOnConflictUpdate(RegionZonesCompanion.insert(
            id: z['id'] as String,
            name: z['name'] as String,
            colorValue: Value(z['colorValue'] as int? ?? 0),
            polygonsJson: Value(_encodeMap(z['polygons'])),
            updatedAt: _parseDate(z['updatedAt']) ?? DateTime.now(),
          ));
    }
    await _setCursor('zones', DateTime.now());
  }

  // ---------- cursors ----------

  Future<DateTime?> _cursor(String entity) async {
    final row = await (_db.select(_db.syncCursors)..where((t) => t.entity.equals(entity))).getSingleOrNull();
    return row?.since;
  }

  Future<void> _setCursor(String entity, DateTime since) async {
    await _db.into(_db.syncCursors).insertOnConflictUpdate(SyncCursorsCompanion.insert(entity: entity, since: since));
  }

  DateTime? _parseDate(dynamic v) => v == null ? null : DateTime.tryParse(v as String);
  String _encodeMap(dynamic v) => v == null ? '{}' : jsonEncode(v);
  String _encodeExtra(Map json) {
    final extra = <String, dynamic>{
      for (final k in ['replyToId', 'replyToText', 'replyToSender', 'reactions', 'mediaUrl', 'mediaUrls', 'durationMs', 'orderId', 'waveform', 'sizeBytes', 'uploadCount'])
        if (json[k] != null) k: json[k],
    };
    return jsonEncode(extra);
  }
}
