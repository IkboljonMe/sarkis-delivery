import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/order_model.dart';
import '../utils/constants.dart';

class OrderService {
  OrderService._();
  static final OrderService instance = OrderService._();

  final CollectionReference<Map<String, dynamic>> _col =
      FirebaseFirestore.instance.collection('orders');

  Future<String> createOrder(OrderModel order) async {
    try {
      final ref = _col.doc();
      final data = order.copyWith(id: ref.id).toJson();
      data['createdAt'] = FieldValue.serverTimestamp();
      data['updatedAt'] = FieldValue.serverTimestamp();
      await ref.set(data);
      return ref.id;
    } catch (e) {
      throw Exception('Failed to create order: $e');
    }
  }

  List<OrderModel> _sortByCreatedDesc(QuerySnapshot<Map<String, dynamic>> s) {
    final list = s.docs
        .map((d) => OrderModel.fromJson({...d.data(), 'id': d.id}))
        .toList();
    list.sort((a, b) {
      final ad = a.createdAt ?? DateTime(1970);
      final bd = b.createdAt ?? DateTime(1970);
      return bd.compareTo(ad);
    });
    return list;
  }

  Stream<List<OrderModel>> userOrdersStream(String userId) =>
      _col.where('userId', isEqualTo: userId).snapshots().map(_sortByCreatedDesc);

  Stream<List<OrderModel>> ordersByGroupStream(String group) =>
      _col.where('userGroup', isEqualTo: group).snapshots().map(_sortByCreatedDesc);

  /// Every order across all groups.
  Stream<List<OrderModel>> allOrdersStream() =>
      _col.snapshots().map(_sortByCreatedDesc);

  /// All orders when [group] is the "All" pseudo-group, else just that group.
  Stream<List<OrderModel>> ordersStream(String group) =>
      AppConstants.isAllGroups(group)
          ? allOrdersStream()
          : ordersByGroupStream(group);

  Stream<List<OrderModel>> ordersByShiftStream(String shiftId) =>
      _col.where('shiftId', isEqualTo: shiftId).snapshots().map(_sortByCreatedDesc);

  Stream<OrderModel?> orderStream(String orderId) {
    return _col.doc(orderId).snapshots().map((d) {
      if (!d.exists || d.data() == null) return null;
      return OrderModel.fromJson({...d.data()!, 'id': d.id});
    });
  }

  Future<void> updateStatus(String orderId, String status) async {
    try {
      await _col.doc(orderId).update({
        'status': status,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Failed to update status: $e');
    }
  }

  Future<void> updateOrder(String orderId, Map<String, dynamic> data) async {
    try {
      await _col.doc(orderId).update({
        ...data,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Failed to update order: $e');
    }
  }
}
