import '../models/coupon_model.dart';
import 'api_client.dart';

class CouponService {
  CouponService._();
  static final CouponService instance = CouponService._();

  final ApiClient _api = ApiClient.instance;

  List<CouponModel> _parse(dynamic res) => (res as List)
      .map((e) => CouponModel.fromJson(Map<String, dynamic>.from(e as Map)))
      .toList();

  Stream<List<CouponModel>> couponsStream() => ApiClient.poll(
      const Duration(seconds: 20),
      () async => _parse(await _api.get('/v1/admin/coupons')));

  /// Creates or updates a coupon. [previousId] is the pre-edit code/id when
  /// the admin renamed the code.
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
    if (existingId != null) {
      await _api.patch('/v1/admin/coupons/$existingId', body);
    } else {
      await _api.post('/v1/admin/coupons', body);
    }
  }

  Future<void> setActive(String id, bool active) async {
    final backendId = await _resolveId(id);
    if (backendId != null) {
      await _api.patch('/v1/admin/coupons/$backendId', {'isActive': active});
    }
  }

  Future<void> deleteCoupon(String id) async {
    final backendId = await _resolveId(id);
    if (backendId != null) {
      await _api.delete('/v1/admin/coupons/$backendId');
    }
  }

  /// The old Firestore ids were the normalized code; the API uses uuids. This
  /// accepts either and returns the backend id (or null when unknown).
  Future<String?> _resolveId(String idOrCode) async {
    if (idOrCode.isEmpty) return null;
    try {
      final list = await _api.get('/v1/admin/coupons') as List;
      for (final raw in list) {
        final c = Map<String, dynamic>.from(raw as Map);
        if (c['id'] == idOrCode ||
            c['code'] == CouponModel.normalize(idOrCode)) {
          return c['id'] as String;
        }
      }
    } catch (_) {}
    return null;
  }
}
