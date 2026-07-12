import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/coupon_model.dart';

class CouponService {
  CouponService._();
  static final CouponService instance = CouponService._();

  final FirebaseFirestore _db = FirebaseFirestore.instance;
  CollectionReference<Map<String, dynamic>> get _coupons =>
      _db.collection('coupons');

  /// Fetches a coupon by its (case-insensitive) code, or null if it doesn't
  /// exist. The doc id is the normalized code, so this is a single get.
  Future<CouponModel?> getByCode(String code) async {
    final id = CouponModel.normalize(code);
    if (id.isEmpty) return null;
    try {
      final doc = await _coupons.doc(id).get();
      if (!doc.exists) return null;
      return CouponModel.fromJson({...doc.data()!, 'id': doc.id});
    } catch (_) {
      return null;
    }
  }

  /// Best-effort increment of redemption count after an order is placed.
  Future<void> incrementUsage(String id) async {
    try {
      await _coupons.doc(id).update({'usedCount': FieldValue.increment(1)});
    } catch (_) {}
  }
}
