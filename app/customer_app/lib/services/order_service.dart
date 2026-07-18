import 'package:drift/drift.dart' as drift;
import '../local_db/app_database.dart';
import '../models/order_item_model.dart';
import '../models/order_model.dart';
import '../sync/mutation_queue.dart';

class OrderService {
  OrderService._();
  static final OrderService instance = OrderService._();

  Stream<List<OrderModel>> userOrdersStream(String userId) {
    final db = AppDatabase.instance;
    return (db.select(db.orders)
          ..where((t) => t.userId.equals(userId))
          ..orderBy([(t) => drift.OrderingTerm.desc(t.createdAt)]))
        .watch()
        .asyncMap((rows) async {
      final out = <OrderModel>[];
      for (final r in rows) {
        final items = await (db.select(db.orderItemRows)..where((t) => t.orderId.equals(r.id))).get();
        final sRow = r.shiftId.isNotEmpty
            ? await (db.select(db.shifts)..where((t) => t.id.equals(r.shiftId))).getSingleOrNull()
            : null;
        out.add(OrderModel(
          id: r.id,
          userId: r.userId,
          userName: r.userName,
          userPhone: '',
          userAddress: r.userAddress,
          userCity: r.userCity,
          userGroup: '',
          shiftId: r.shiftId,
          shiftDate: r.shiftDate ?? DateTime.now(),
          shiftLabel: r.shiftLabel,
          items: items
              .map((i) => OrderItemModel(
                    productId: i.productId,
                    categoryId: '',
                    name: i.name,
                    qty: i.qty,
                    unitPrice: i.unitPrice,
                  ))
              .toList(),
          subtotal: r.subtotal,
          discount: r.discount,
          couponCode: r.couponCode,
          totalPrice: r.totalPrice,
          status: r.status,
          adminNote: r.adminNote,
          cancelDaysBefore: sRow?.cancelDaysBefore ?? 3,
          editDaysBefore: sRow?.editDaysBefore ?? 4,
          pendingApproval: r.pendingApproval,
          awaitingSchedule: r.awaitingSchedule,
          createdAt: r.createdAt,
          updatedAt: r.updatedAt,
        ));
      }
      return out;
    });
  }

  Stream<OrderModel?> orderStream(String orderId) {
    final db = AppDatabase.instance;
    return (db.select(db.orders)..where((t) => t.id.equals(orderId)))
        .watchSingleOrNull()
        .asyncMap((r) async {
      if (r == null) return null;
      final items = await (db.select(db.orderItemRows)..where((t) => t.orderId.equals(r.id))).get();
      final sRow = r.shiftId.isNotEmpty
          ? await (db.select(db.shifts)..where((t) => t.id.equals(r.shiftId))).getSingleOrNull()
          : null;
      return OrderModel(
        id: r.id,
        userId: r.userId,
        userName: r.userName,
        userPhone: '',
        userAddress: r.userAddress,
        userCity: r.userCity,
        userGroup: '',
        shiftId: r.shiftId,
        shiftDate: r.shiftDate ?? DateTime.now(),
        shiftLabel: r.shiftLabel,
        items: items
            .map((i) => OrderItemModel(
                  productId: i.productId,
                  categoryId: '',
                  name: i.name,
                  qty: i.qty,
                  unitPrice: i.unitPrice,
                ))
            .toList(),
        subtotal: r.subtotal,
        discount: r.discount,
        couponCode: r.couponCode,
        totalPrice: r.totalPrice,
        status: r.status,
        adminNote: r.adminNote,
        cancelDaysBefore: sRow?.cancelDaysBefore ?? 3,
        editDaysBefore: sRow?.editDaysBefore ?? 4,
        pendingApproval: r.pendingApproval,
        awaitingSchedule: r.awaitingSchedule,
        createdAt: r.createdAt,
        updatedAt: r.updatedAt,
      );
    });
  }

  Future<String> createOrder(OrderModel order) async {
    final localId = 'local_${DateTime.now().millisecondsSinceEpoch}';
    final db = AppDatabase.instance;

    await db.transaction(() async {
      await db.into(db.orders).insert(OrdersCompanion.insert(
            id: localId,
            userId: order.userId,
            status: order.status,
            driverId: const drift.Value(''),
            shiftId: drift.Value(order.shiftId),
            shiftDate: drift.Value(order.shiftDate),
            shiftLabel: drift.Value(order.shiftLabel),
            subtotal: drift.Value(order.subtotal),
            discount: drift.Value(order.discount),
            couponCode: drift.Value(order.couponCode),
            totalPrice: drift.Value(order.totalPrice),
            userName: drift.Value(order.userName),
            userAddress: drift.Value(order.userAddress),
            userCity: drift.Value(order.userCity),
            adminNote: drift.Value(order.adminNote),
            pendingApproval: drift.Value(order.pendingApproval),
            awaitingSchedule: drift.Value(order.awaitingSchedule),
            createdAt: order.createdAt ?? DateTime.now(),
            updatedAt: order.createdAt ?? DateTime.now(),
            pendingSync: const drift.Value(true),
          ));
      for (var i = 0; i < order.items.length; i++) {
        final it = order.items[i];
        await db.into(db.orderItemRows).insert(OrderItemRowsCompanion.insert(
              id: '${localId}_$i',
              orderId: localId,
              productId: drift.Value(it.productId),
              name: drift.Value(it.name),
              qty: it.qty,
              unitPrice: it.unitPrice,
            ));
      }
    });

    final body = {
      if (order.shiftId.isNotEmpty) 'shiftId': order.shiftId,
      if (order.couponCode.isNotEmpty) 'couponCode': order.couponCode,
      'items': order.items.map((i) => {'productId': i.productId, 'qty': i.qty}).toList(),
    };

    final res = await MutationQueue.instance.run(
      entityType: 'order',
      method: 'POST',
      path: '/v1/orders',
      body: body,
      localRefId: localId,
    );

    if (res != null) {
      await db.transaction(() async {
        await (db.delete(db.orders)..where((t) => t.id.equals(localId))).go();
        await (db.delete(db.orderItemRows)..where((t) => t.orderId.equals(localId))).go();
      });
      return (res as Map)['id'] as String;
    }
    return localId;
  }

  Future<void> updateStatus(String orderId, String status) async {
    if (status == 'cancelled') {
      final db = AppDatabase.instance;
      await (db.update(db.orders)..where((t) => t.id.equals(orderId)))
          .write(const OrdersCompanion(status: drift.Value('cancelled'), pendingSync: drift.Value(true)));

      final res = await MutationQueue.instance.run(
        entityType: 'order',
        method: 'POST',
        path: '/v1/orders/$orderId/cancel',
      );
      if (res != null) {
        await (db.update(db.orders)..where((t) => t.id.equals(orderId)))
            .write(const OrdersCompanion(pendingSync: drift.Value(false)));
      }
    } else {
      throw Exception('Only cancelling is allowed');
    }
  }

  Future<void> updateOrder(String orderId, Map<String, dynamic> data) async {
    final db = AppDatabase.instance;
    await (db.update(db.orders)..where((t) => t.id.equals(orderId))).write(OrdersCompanion(
      pendingSync: const drift.Value(true),
      subtotal: data['subtotal'] != null ? drift.Value((data['subtotal'] as num).toDouble()) : const drift.Value.absent(),
      discount: data['discount'] != null ? drift.Value((data['discount'] as num).toDouble()) : const drift.Value.absent(),
      couponCode: data['couponCode'] != null ? drift.Value(data['couponCode'] as String) : const drift.Value.absent(),
      totalPrice: data['totalPrice'] != null ? drift.Value((data['totalPrice'] as num).toDouble()) : const drift.Value.absent(),
    ));

    final body = <String, dynamic>{};
    if (data['items'] is List) {
      await db.transaction(() async {
        await (db.delete(db.orderItemRows)..where((t) => t.orderId.equals(orderId))).go();
        final list = data['items'] as List;
        for (var i = 0; i < list.length; i++) {
          final pt = list[i] as Map;
          await db.into(db.orderItemRows).insert(OrderItemRowsCompanion.insert(
                id: '${orderId}_$i',
                orderId: orderId,
                productId: drift.Value(pt['productId'] as String? ?? ''),
                name: drift.Value(pt['name'] as String? ?? ''),
                qty: pt['qty'] as int? ?? 0,
                unitPrice: (pt['unitPrice'] as num?)?.toDouble() ?? 0,
              ));
        }
      });
      body['items'] = (data['items'] as List)
          .map((i) => {'productId': i['productId'], 'qty': i['qty']})
          .toList();
    }
    if (data['shiftId'] is String && (data['shiftId'] as String).isNotEmpty) {
      body['shiftId'] = data['shiftId'];
    }

    final res = await MutationQueue.instance.run(
      entityType: 'order',
      method: 'PATCH',
      path: '/v1/orders/$orderId',
      body: body,
    );
    if (res != null) {
      await (db.update(db.orders)..where((t) => t.id.equals(orderId)))
          .write(const OrdersCompanion(pendingSync: drift.Value(false)));
    }
  }
}
