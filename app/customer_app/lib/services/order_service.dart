import '../models/order_model.dart';
import 'api_client.dart';

class OrderService {
  OrderService._();
  static final OrderService instance = OrderService._();

  final ApiClient _api = ApiClient.instance;

  List<OrderModel> _parseList(dynamic res) => (res as List)
      .map((e) => OrderModel.fromJson(Map<String, dynamic>.from(e as Map)))
      .toList();

  /// Creates the order. Prices/discounts are computed server-side from the
  /// product ids and quantities; the rest of [order] is derived from the
  /// authenticated profile.
  Future<String> createOrder(OrderModel order) async {
    final res = await _api.post('/v1/orders', {
      if (order.shiftId.isNotEmpty) 'shiftId': order.shiftId,
      if (order.couponCode.isNotEmpty) 'couponCode': order.couponCode,
      'items': order.items
          .map((i) => {'productId': i.productId, 'qty': i.qty})
          .toList(),
    });
    return (res as Map)['id'] as String;
  }

  Stream<List<OrderModel>> userOrdersStream(String userId) =>
      ApiClient.poll(const Duration(seconds: 10),
          () async => _parseList(await _api.get('/v1/orders/mine')));

  Stream<OrderModel?> orderStream(String orderId) =>
      ApiClient.poll(const Duration(seconds: 8), () async {
        final res = await _api.get('/v1/orders/$orderId');
        return OrderModel.fromJson(Map<String, dynamic>.from(res as Map));
      });

  /// Customer-side status change (only cancelling is allowed).
  Future<void> updateStatus(String orderId, String status) async {
    if (status == 'cancelled') {
      await _api.post('/v1/orders/$orderId/cancel');
    } else {
      throw Exception('Only cancelling is allowed');
    }
  }

  /// Customer edit (items / delivery day) within the edit window.
  Future<void> updateOrder(String orderId, Map<String, dynamic> data) async {
    final body = <String, dynamic>{};
    if (data['items'] is List) {
      body['items'] = (data['items'] as List)
          .map((i) => {'productId': i['productId'], 'qty': i['qty']})
          .toList();
    }
    if (data['shiftId'] is String && (data['shiftId'] as String).isNotEmpty) {
      body['shiftId'] = data['shiftId'];
    }
    await _api.patch('/v1/orders/$orderId', body);
  }
}
