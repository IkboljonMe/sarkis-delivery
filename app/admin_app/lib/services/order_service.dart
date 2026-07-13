import '../models/order_model.dart';
import 'api_client.dart';

class OrderService {
  OrderService._();
  static final OrderService instance = OrderService._();

  final ApiClient _api = ApiClient.instance;

  static const _interval = Duration(seconds: 10);

  List<OrderModel> _parse(dynamic res) => (res as List)
      .map((e) => OrderModel.fromJson(Map<String, dynamic>.from(e as Map)))
      .toList();

  Stream<List<OrderModel>> _list(String query) =>
      ApiClient.poll(_interval, () async => _parse(await _api.get('/v1/admin/orders$query')));

  Stream<List<OrderModel>> userOrdersStream(String userId) => _list('?userId=$userId');

  Stream<List<OrderModel>> ordersByGroupStream(String group) =>
      _list('?group=${Uri.encodeComponent(group)}');

  Stream<List<OrderModel>> allOrdersStream() => _list('');

  Stream<List<OrderModel>> ordersStream(String group) =>
      group.isEmpty ? allOrdersStream() : ordersByGroupStream(group);

  Stream<List<OrderModel>> ordersByShiftStream(String shiftId) => _list('?shiftId=$shiftId');

  Stream<OrderModel?> orderStream(String orderId) =>
      ApiClient.poll(const Duration(seconds: 8), () async {
        final res = await _api.get('/v1/orders/$orderId');
        return OrderModel.fromJson(Map<String, dynamic>.from(res as Map));
      });

  Future<void> updateStatus(String orderId, String status) async {
    await _api.patch('/v1/admin/orders/$orderId', {'status': status});
  }

  /// Partial admin edit (adminNote, shiftId, pendingApproval, cashCollected…).
  Future<void> updateOrder(String orderId, Map<String, dynamic> data) async {
    final allowed = <String, dynamic>{};
    for (final k in ['status', 'adminNote', 'pendingApproval', 'awaitingSchedule', 'cashCollected', 'shiftId']) {
      if (data.containsKey(k)) allowed[k] = data[k];
    }
    if (allowed.isNotEmpty) {
      await _api.patch('/v1/admin/orders/$orderId', allowed);
    }
  }

  Future<void> assignDriver(String orderId, String driverId) async {
    await _api.post('/v1/admin/orders/$orderId/assign', {'driverId': driverId});
  }
}
