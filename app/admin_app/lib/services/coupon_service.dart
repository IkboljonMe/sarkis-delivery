import 'package:drift/drift.dart' as drift;

import '../local_db/app_database.dart';
import '../models/coupon_model.dart';
import '../sync/mutation_queue.dart';

class CouponService {
  CouponService._();
  static final CouponService instance = CouponService._();

  Stream<List<CouponModel>> couponsStream() {
    final db = AppDatabase.instance;
    return (db.select(db.coupons)
          ..orderBy([(t) => drift.OrderingTerm.desc(t.createdAt)]))
        .watch()
        .map((rows) => rows.map((r) => CouponModel(
              id: r.id,
              code: r.code,
              type: r.type,
              value: r.value,
              minOrder: r.minOrder,
              isActive: r.isActive,
              expiresAt: r.expiresAt,
              usageLimit: r.usageLimit,
            )).toList());
  }

  Future<void> saveCoupon(CouponModel c, {String? previousId}) async {
    final body = {
      'code': c.code,
      'type': c.type,
      'value': c.value,
      'minOrder': c.minOrder,
      'isActive': c.isActive,
      if (c.expiresAt != null) 'expiresAt': c.expiresAt!.toIso8601String(),
      'usageLimit': c.usageLimit,
    };
    final existingId = await _resolveId(previousId ?? c.id) ?? await _resolveId(c.code);
    final isNew = existingId == null;
    final method = isNew ? 'POST' : 'PATCH';
    final path = isNew ? '/v1/admin/coupons' : '/v1/admin/coupons/$existingId';

    final id = existingId ?? 'local_${DateTime.now().millisecondsSinceEpoch}';

    final db = AppDatabase.instance;
    await db.into(db.coupons).insertOnConflictUpdate(CouponsCompanion.insert(
      id: id,
      code: c.code,
      type: drift.Value(c.type),
      value: drift.Value(c.value),
      minOrder: drift.Value(c.minOrder),
      isActive: drift.Value(c.isActive),
      expiresAt: drift.Value(c.expiresAt),
      usageLimit: drift.Value(c.usageLimit),
      createdAt: drift.Value(DateTime.now()),
      updatedAt: DateTime.now(),
    ));

    await MutationQueue.instance.run(
      entityType: 'coupon',
      method: method,
      path: path,
      body: body,
      localRefId: isNew ? id : '',
    );
  }

  Future<void> setActive(String id, bool active) async {
    final backendId = await _resolveId(id);
    if (backendId != null) {
      final db = AppDatabase.instance;
      await (db.update(db.coupons)..where((t) => t.id.equals(backendId))).write(CouponsCompanion(isActive: drift.Value(active)));

      await MutationQueue.instance.run(
        entityType: 'coupon',
        method: 'PATCH',
        path: '/v1/admin/coupons/$backendId',
        body: {'isActive': active},
      );
    }
  }

  Future<void> deleteCoupon(String id) async {
    final backendId = await _resolveId(id);
    if (backendId != null) {
      final db = AppDatabase.instance;
      await (db.delete(db.coupons)..where((t) => t.id.equals(backendId))).go();

      await MutationQueue.instance.run(
        entityType: 'coupon',
        method: 'DELETE',
        path: '/v1/admin/coupons/$backendId',
      );
    }
  }

  Future<String?> _resolveId(String idOrCode) async {
    if (idOrCode.isEmpty) return null;
    final db = AppDatabase.instance;
    final res = await (db.select(db.coupons)..where((t) => t.id.equals(idOrCode) | t.code.equals(CouponModel.normalize(idOrCode)))).getSingleOrNull();
    return res?.id;
  }
}
