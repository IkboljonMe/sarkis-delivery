import 'package:flutter/foundation.dart';

import '../models/order_model.dart';
import '../services/firebase_service.dart';

/// Exposes order streams and status mutations for the admin app.
class AdminOrderProvider extends ChangeNotifier {
  final FirebaseService _db = FirebaseService.instance;

  Stream<List<OrderModel>> ordersStream() => _db.allOrdersStream();
  Stream<OrderModel?> orderStream(String id) => _db.orderStream(id);

  String? _error;
  String? get error => _error;

  /// Valid status transitions for the admin workflow.
  static List<String> nextStatuses(String current) {
    switch (current) {
      case 'pending':
        return ['confirmed', 'cancelled'];
      case 'confirmed':
        return ['on_the_way', 'cancelled'];
      case 'on_the_way':
        return ['delivered'];
      default:
        return [];
    }
  }

  Future<bool> updateStatus(String orderId, String status) async {
    try {
      await _db.updateOrderStatus(orderId, status);
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> sendMessage(String orderId, String text) async {
    try {
      await _db.sendAdminMessage(orderId, text);
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  /// Filters orders by tab/group/date in memory (small dataset, single admin).
  List<OrderModel> applyFilters(
    List<OrderModel> orders, {
    String? status,
    String? group,
    DateTime? deliveryDate,
  }) {
    return orders.where((o) {
      if (status != null && status.isNotEmpty && o.status != status) {
        return false;
      }
      if (group != null && group.isNotEmpty && o.group != group) return false;
      if (deliveryDate != null) {
        final d = o.deliveryDate;
        if (d.year != deliveryDate.year ||
            d.month != deliveryDate.month ||
            d.day != deliveryDate.day) {
          return false;
        }
      }
      return true;
    }).toList();
  }
}
