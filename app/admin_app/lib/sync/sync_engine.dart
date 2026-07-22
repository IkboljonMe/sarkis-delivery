import 'dart:async';
import 'dart:convert';

import 'package:drift/drift.dart';

import '../local_db/app_database.dart';
import '../realtime/socket_service.dart';
import '../services/api_client.dart';
import 'mutation_queue.dart';

/// Single source of truth for keeping the local Drift cache current — see
/// customer_app's `lib/sync/sync_engine.dart` for the full rationale; this
/// is the same pattern scoped to staff-wide data (all orders, all chat
/// topics, all approvals) instead of one customer's own records.
class SyncEngine {
  SyncEngine._(this._db, this._api, this._socket);
  static final SyncEngine instance = SyncEngine._(AppDatabase.instance, ApiClient.instance, SocketService.instance);

  final AppDatabase _db;
  final ApiClient _api;
  final SocketService _socket;
  StreamSubscription? _eventsSub;
  StreamSubscription? _connectSub;

  void start() {
    _eventsSub?.cancel();
    _connectSub?.cancel();
    _eventsSub = _socket.events.listen(_handleEvent);
    // On every (re)connect, pull anything missed while disconnected. The very
    // first connect overlaps the login fullSync — harmless since every sync is
    // an idempotent upsert.
    _connectSub = _socket.onConnect.listen((_) {
      fullSync().catchError((_) {});
    });
    _socket.connect();
    MutationQueue.instance.start();
    MutationQueue.instance.drain();
  }

  Future<void> stop() async {
    await _eventsSub?.cancel();
    await _connectSub?.cancel();
    _eventsSub = null;
    _connectSub = null;
    _socket.disconnect();
    await MutationQueue.instance.stop();
  }

  Future<void> fullSync() async {
    await Future.wait([
      syncOrders(),
      syncTopics(),
      syncNotifications(),
      syncApprovals(),
      syncCatalog(),
      syncCoupons(),
      syncShifts(),
      syncZones(),
    ]);
  }

  void _handleEvent(RealtimeEvent e) {
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

  // ---------- orders (staff-wide) ----------

  Future<void> syncOrders() async {
    final since = await _cursor('orders');
    final path = since == null ? '/v1/admin/orders' : '/v1/admin/orders?since=${Uri.encodeComponent(since.toIso8601String())}';
    for (final row in await _api.get(path) as List) {
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
          driverName: Value(json['driverName'] as String? ?? ''),
          shiftId: Value(json['shiftId'] as String? ?? ''),
          shiftDate: Value(_parseDate(json['shiftDate'])),
          shiftLabel: Value(json['shiftLabel'] as String? ?? ''),
          subtotal: Value((json['subtotal'] as num?)?.toDouble() ?? 0),
          discount: Value((json['discount'] as num?)?.toDouble() ?? 0),
          couponCode: Value(json['couponCode'] as String? ?? ''),
          totalPrice: Value((json['totalPrice'] as num?)?.toDouble() ?? 0),
          userName: Value(json['userName'] as String? ?? ''),
          userPhone: Value(json['userPhone'] as String? ?? ''),
          userAddress: Value(json['userAddress'] as String? ?? ''),
          userCity: Value(json['userCity'] as String? ?? ''),
          userGroup: Value(json['userGroup'] as String? ?? ''),
          adminNote: Value(json['adminNote'] as String? ?? ''),
          pendingApproval: Value(json['pendingApproval'] as bool? ?? false),
          awaitingSchedule: Value(json['awaitingSchedule'] as bool? ?? false),
          cashCollected: Value(json['cashCollected'] as bool? ?? false),
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

  // ---------- chat (all topics; per-topic messages fetched on demand) ----------

  /// Topic list has no `since=` cursor server-side (low-volume, one row per
  /// customer) so this is always a full refresh — same treatment as
  /// approvals below.
  Future<void> syncTopics() async {
    for (final row in await _api.get('/v1/messages/topics') as List) {
      await _upsertTopic(row as Map);
    }
  }

  Future<void> syncMessages(String topicId) async {
    final since = await _cursor('messages:$topicId');
    // First load pulls recent history; catch-up uses `updatedSince` so edits,
    // deletes, reactions and read-state that changed while offline are pulled
    // too (not just brand-new messages, which is all `after`/createdAt saw).
    final path = since == null
        ? '/v1/messages/$topicId'
        : '/v1/messages/$topicId?updatedSince=${Uri.encodeComponent(since.toIso8601String())}';
    final rows = await _api.get(path) as List;
    var maxUpdated = since ?? DateTime.fromMillisecondsSinceEpoch(0);
    for (final row in rows) {
      final map = row as Map;
      await _upsertMessage(map, topicId: topicId);
      final u = _parseDate(map['updatedAt']);
      if (u != null && u.isAfter(maxUpdated)) maxUpdated = u;
    }
    if (rows.isNotEmpty) await _setCursor('messages:$topicId', maxUpdated);
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
          userGroup: Value(json['userGroup'] as String? ?? ''),
          lastMessage: Value(json['lastMessage'] as String? ?? ''),
          lastAt: Value(_parseDate(json['lastAt'])),
          lastFromAdmin: Value(json['lastFromAdmin'] as bool? ?? false),
          adminUnread: Value(json['unread'] as int? ?? 0),
        ));
  }

  // ---------- notifications ----------

  Future<void> syncNotifications() async {
    final since = await _cursor('notifications');
    final path = since == null ? '/v1/notifications' : '/v1/notifications?since=${Uri.encodeComponent(since.toIso8601String())}';
    for (final row in await _api.get(path) as List) {
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

  // ---------- approvals (all requests, staff-wide — always full refresh) ----------

  Future<void> syncApprovals() async {
    final rows = await _api.get('/v1/admin/approvals') as List;
    await _db.delete(_db.approvals).go();
    for (final row in rows) {
      await _upsertApproval(row as Map);
    }
  }

  Future<void> _upsertApproval(Map json) async {
    await _db.into(_db.approvals).insertOnConflictUpdate(ApprovalsCompanion.insert(
          id: json['id'] as String,
          type: Value(json['type'] as String? ?? 'profile'),
          userId: json['userId'] as String,
          userName: Value(json['userName'] as String? ?? ''),
          changesJson: Value(_encodeMap(json['changes'])),
          status: Value(json['status'] as String? ?? 'pending'),
          createdAt: _parseDate(json['createdAt']) ?? DateTime.now(),
        ));
  }

  // ---------- catalog / coupons / shifts / zones ----------

  Future<void> syncCatalog() async {
    final catSince = await _cursor('categories');
    final catPath = catSince == null ? '/v1/categories?all=true' : '/v1/categories?all=true&since=${Uri.encodeComponent(catSince.toIso8601String())}';
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
    final prodPath = prodSince == null ? '/v1/products?all=true' : '/v1/products?all=true&since=${Uri.encodeComponent(prodSince.toIso8601String())}';
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
            photosJson: Value(_encodeMap(p['photos'])),
            isActive: Value(p['isActive'] as bool? ?? true),
            sortOrder: Value(p['sortOrder'] as int? ?? 0),
            discountType: Value(p['discountType'] as String? ?? 'none'),
            discountValue: Value((p['discountValue'] as num?)?.toDouble() ?? 0),
            updatedAt: _parseDate(p['updatedAt']) ?? DateTime.now(),
          ));
    }
    await _setCursor('products', DateTime.now());
  }

  Future<void> syncCoupons() async {
    final since = await _cursor('coupons');
    final path = since == null ? '/v1/admin/coupons' : '/v1/admin/coupons?since=${Uri.encodeComponent(since.toIso8601String())}';
    for (final row in await _api.get(path) as List) {
      final c = row as Map;
      await _db.into(_db.coupons).insertOnConflictUpdate(CouponsCompanion.insert(
            id: c['id'] as String,
            code: c['code'] as String,
            type: Value(c['type'] as String? ?? 'percent'),
            value: Value((c['value'] as num?)?.toDouble() ?? 0),
            minOrder: Value((c['minOrder'] as num?)?.toDouble() ?? 0),
            isActive: Value(c['isActive'] as bool? ?? true),
            usageLimit: Value(c['usageLimit'] as int? ?? 0),
            usedCount: Value(c['usedCount'] as int? ?? 0),
            updatedAt: _parseDate(c['updatedAt']) ?? DateTime.now(),
          ));
    }
    await _setCursor('coupons', DateTime.now());
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
