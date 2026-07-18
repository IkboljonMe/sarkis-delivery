import 'package:drift/drift.dart' as drift;

import '../local_db/app_database.dart';
import '../models/order_model.dart';
import '../models/order_item_model.dart';
import '../sync/mutation_queue.dart';

class OrderService {
  OrderService._();
  static final OrderService instance = OrderService._();

  Stream<List<OrderModel>> _watchQuery(drift.Selectable<Order> query) {
    final db = AppDatabase.instance;
    return query.watch().asyncMap((rows) async {
      final list = <OrderModel>[];
      for (final r in rows) {
        final items = await (db.select(db.orderItemRows)..where((t) => t.orderId.equals(r.id))).get();
        list.add(OrderModel(
          id: r.id,
          userId: r.userId,
          status: r.status,
          
          shiftId: r.shiftId,
          shiftDate: r.shiftDate ?? DateTime.now(),
          shiftLabel: r.shiftLabel,
          subtotal: r.subtotal,
          discount: r.discount,
          couponCode: r.couponCode,
          totalPrice: r.totalPrice,
          items: items.map((i) => OrderItemModel(
            productId: i.productId,
            name: i.name,
            qty: i.qty,
            unitPrice: i.unitPrice,
          )).toList(),
          createdAt: r.createdAt,
          updatedAt: r.updatedAt,
          pendingApproval: r.pendingApproval,
          awaitingSchedule: r.awaitingSchedule,
          adminNote: r.adminNote,
          userName: r.userName,
          userPhone: r.userPhone,
          userAddress: r.userAddress,
          userCity: r.userCity,
          userGroup: r.userGroup,
        ));
      }
      return list;
    });
  }

  Stream<List<OrderModel>> userOrdersStream(String userId) {
    final db = AppDatabase.instance;
    return _watchQuery(db.select(db.orders)
      ..where((t) => t.userId.equals(userId))
      ..orderBy([(t) => drift.OrderingTerm.desc(t.createdAt)]));
  }

  Stream<List<OrderModel>> ordersByGroupStream(String group) {
    final db = AppDatabase.instance;
    return _watchQuery(db.select(db.orders)
      ..where((t) => t.userGroup.equals(group))
      ..orderBy([(t) => drift.OrderingTerm.desc(t.createdAt)]));
  }

  Stream<List<OrderModel>> allOrdersStream() {
    final db = AppDatabase.instance;
    return _watchQuery(db.select(db.orders)
      ..orderBy([(t) => drift.OrderingTerm.desc(t.createdAt)]));
  }

  Stream<List<OrderModel>> ordersStream(String group) =>
      group.isEmpty ? allOrdersStream() : ordersByGroupStream(group);

  Stream<List<OrderModel>> ordersByShiftStream(String shiftId) {
    final db = AppDatabase.instance;
    return _watchQuery(db.select(db.orders)
      ..where((t) => t.shiftId.equals(shiftId))
      ..orderBy([(t) => drift.OrderingTerm.desc(t.createdAt)]));
  }

  Stream<OrderModel?> orderStream(String orderId) {
    final db = AppDatabase.instance;
    return _watchQuery(db.select(db.orders)..where((t) => t.id.equals(orderId)))
        .map((list) => list.isEmpty ? null : list.first);
  }

  Future<void> updateStatus(String orderId, String status) async {
    final db = AppDatabase.instance;
    await (db.update(db.orders)..where((t) => t.id.equals(orderId))).write(
      OrdersCompanion(
        status: drift.Value(status),
        pendingSync: const drift.Value(true),
      ),
    );

    await MutationQueue.instance.run(
      entityType: 'order',
      method: 'PATCH',
      path: '/v1/admin/orders/$orderId',
      body: {'status': status},
    );
  }

  Future<void> updateOrder(String orderId, Map<String, dynamic> data) async {
    final allowed = <String, dynamic>{};
    for (final k in ['status', 'adminNote', 'pendingApproval', 'awaitingSchedule', 'cashCollected', 'shiftId']) {
      if (data.containsKey(k)) allowed[k] = data[k];
    }
    
    if (allowed.isNotEmpty) {
      final db = AppDatabase.instance;
      var c = const OrdersCompanion();
      
      if (allowed.containsKey('status')) c = c.copyWith(status: drift.Value(allowed['status'] as String));
      if (allowed.containsKey('adminNote')) c = c.copyWith(adminNote: drift.Value(allowed['adminNote'] as String));
      if (allowed.containsKey('pendingApproval')) c = c.copyWith(pendingApproval: drift.Value(allowed['pendingApproval'] as bool));
      if (allowed.containsKey('awaitingSchedule')) c = c.copyWith(awaitingSchedule: drift.Value(allowed['awaitingSchedule'] as bool));
      if (allowed.containsKey('cashCollected')) c = c.copyWith(cashCollected: drift.Value(allowed['cashCollected'] as bool));
      if (allowed.containsKey('shiftId')) c = c.copyWith(shiftId: drift.Value(allowed['shiftId'] as String));
      
      c = c.copyWith(pendingSync: const drift.Value(true));
      await (db.update(db.orders)..where((t) => t.id.equals(orderId))).write(c);

      await MutationQueue.instance.run(
        entityType: 'order',
        method: 'PATCH',
        path: '/v1/admin/orders/$orderId',
        body: allowed,
      );
    }
  }

  Future<void> assignDriver(String orderId, String driverId) async {
    final db = AppDatabase.instance;
    await (db.update(db.orders)..where((t) => t.id.equals(orderId))).write(
      OrdersCompanion(
        driverId: drift.Value(driverId),
        pendingSync: const drift.Value(true),
      ),
    );

    await MutationQueue.instance.run(
      entityType: 'order',
      method: 'POST',
      path: '/v1/admin/orders/$orderId/assign',
      body: {'driverId': driverId},
    );
  }
}
