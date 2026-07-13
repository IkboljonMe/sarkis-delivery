import '../models/coupon_model.dart';
import 'api_client.dart';

class CouponService {
  CouponService._();
  static final CouponService instance = CouponService._();

  final ApiClient _api = ApiClient.instance;

  /// Fetches a coupon by its (case-insensitive) code, or null if unknown.
  Future<CouponModel?> getByCode(String code) async {
    final id = CouponModel.normalize(code);
    if (id.isEmpty) return null;
    try {
      final res = await _api.get('/v1/coupons/${Uri.encodeComponent(id)}');
      return CouponModel.fromJson(Map<String, dynamic>.from(res as Map));
    } catch (_) {
      return null;
    }
  }

  /// Redemption is counted server-side when the order is created.
  Future<void> incrementUsage(String id) async {}
}
