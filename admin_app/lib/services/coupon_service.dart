import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/coupon_model.dart';

class CouponService {
  CouponService._();
  static final CouponService instance = CouponService._();

  final FirebaseFirestore _db = FirebaseFirestore.instance;
  CollectionReference<Map<String, dynamic>> get _coupons =>
      _db.collection('coupons');

  Stream<List<CouponModel>> couponsStream() {
    return _coupons.snapshots().map((s) {
      final list = s.docs
          .map((d) => CouponModel.fromJson({...d.data(), 'id': d.id}))
          .toList();
      list.sort((a, b) => a.code.compareTo(b.code));
      return list;
    });
  }

  /// Saves a coupon using the normalized code as the document id. When editing
  /// a coupon whose code changed, the old document is removed.
  Future<void> saveCoupon(CouponModel c, {String? previousId}) async {
    final id = CouponModel.normalize(c.code);
    if (id.isEmpty) throw Exception('Coupon code is required');
    try {
      await _coupons.doc(id).set(c.copyWith(id: id, code: id).toJson());
      if (previousId != null && previousId.isNotEmpty && previousId != id) {
        await _coupons.doc(previousId).delete();
      }
    } catch (e) {
      throw Exception('Failed to save coupon: $e');
    }
  }

  Future<void> setActive(String id, bool active) =>
      _coupons.doc(id).update({'isActive': active});

  Future<void> deleteCoupon(String id) => _coupons.doc(id).delete();
}
