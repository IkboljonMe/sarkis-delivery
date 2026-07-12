import 'package:flutter/foundation.dart';

import '../models/order_model.dart';
import '../services/order_service.dart';

class OrderProvider extends ChangeNotifier {
  final OrderService _service = OrderService.instance;

  Stream<List<OrderModel>> userOrdersStream(String userId) =>
      _service.userOrdersStream(userId);

  Stream<OrderModel?> orderStream(String orderId) =>
      _service.orderStream(orderId);

  static const _active = ['pending', 'confirmed', 'on_the_way'];

  List<OrderModel> active(List<OrderModel> orders) =>
      orders.where((o) => _active.contains(o.status)).toList();

  List<OrderModel> completed(List<OrderModel> orders) =>
      orders.where((o) => !_active.contains(o.status)).toList();
}
