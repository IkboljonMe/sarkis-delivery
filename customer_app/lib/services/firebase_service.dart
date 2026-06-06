import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/delivery_date_model.dart';
import '../models/message_model.dart';
import '../models/order_model.dart';
import '../models/product_model.dart';
import '../models/user_model.dart';

/// Central access point to Firestore for the customer app.
/// All async methods are wrapped in try/catch and rethrow a readable error.
class FirebaseService {
  FirebaseService._();
  static final FirebaseService instance = FirebaseService._();

  final FirebaseFirestore _db = FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _users =>
      _db.collection('users');
  CollectionReference<Map<String, dynamic>> get _products =>
      _db.collection('products');
  CollectionReference<Map<String, dynamic>> get _deliveryDates =>
      _db.collection('delivery_dates');
  CollectionReference<Map<String, dynamic>> get _orders =>
      _db.collection('orders');

  // ---------------------------------------------------------------- USERS
  Future<UserModel?> getUser(String uid) async {
    try {
      final doc = await _users.doc(uid).get();
      if (!doc.exists || doc.data() == null) return null;
      return UserModel.fromJson({...doc.data()!, 'id': doc.id});
    } catch (e) {
      throw Exception('Failed to load user: $e');
    }
  }

  Future<void> saveUser(UserModel user) async {
    try {
      await _users.doc(user.id).set(user.toJson(), SetOptions(merge: true));
    } catch (e) {
      throw Exception('Failed to save user: $e');
    }
  }

  Future<void> updateUserFields(String uid, Map<String, dynamic> data) async {
    try {
      await _users.doc(uid).update(data);
    } catch (e) {
      throw Exception('Failed to update user: $e');
    }
  }

  Future<void> updateFcmToken(String uid, String token) async {
    try {
      await _users.doc(uid).set({'fcmToken': token}, SetOptions(merge: true));
    } catch (e) {
      // Non-fatal; token can be retried later.
    }
  }

  // ------------------------------------------------------------- PRODUCTS
  Stream<List<ProductModel>> productsStream() {
    return _products
        .where('isActive', isEqualTo: true)
        .snapshots()
        .map((snap) => snap.docs
            .map((d) => ProductModel.fromJson({...d.data(), 'id': d.id}))
            .toList());
  }

  // -------------------------------------------------------- DELIVERY DATES
  Stream<List<DeliveryDateModel>> openDeliveryDatesStream(String group) {
    return _deliveryDates
        .where('group', isEqualTo: group)
        .where('isOpen', isEqualTo: true)
        .snapshots()
        .map((snap) {
      final list = snap.docs
          .map((d) => DeliveryDateModel.fromJson({...d.data(), 'id': d.id}))
          .toList();
      list.sort((a, b) => a.date.compareTo(b.date));
      return list;
    });
  }

  // --------------------------------------------------------------- ORDERS
  Future<String> createOrder(OrderModel order) async {
    try {
      final ref = _orders.doc();
      final data = order.copyWith(id: ref.id).toJson();
      data['createdAt'] = FieldValue.serverTimestamp();
      await ref.set(data);
      return ref.id;
    } catch (e) {
      throw Exception('Failed to create order: $e');
    }
  }

  Stream<List<OrderModel>> userOrdersStream(String userId) {
    return _orders.where('userId', isEqualTo: userId).snapshots().map((snap) {
      final list = snap.docs
          .map((d) => OrderModel.fromJson({...d.data(), 'id': d.id}))
          .toList();
      list.sort((a, b) {
        final ad = a.createdAt ?? DateTime(1970);
        final bd = b.createdAt ?? DateTime(1970);
        return bd.compareTo(ad);
      });
      return list;
    });
  }

  Stream<OrderModel?> orderStream(String orderId) {
    return _orders.doc(orderId).snapshots().map((doc) {
      if (!doc.exists || doc.data() == null) return null;
      return OrderModel.fromJson({...doc.data()!, 'id': doc.id});
    });
  }

  // ------------------------------------------------------------- MESSAGES
  Stream<List<MessageModel>> messagesStream(String orderId) {
    return _orders
        .doc(orderId)
        .collection('messages')
        .orderBy('createdAt', descending: false)
        .snapshots()
        .map((snap) => snap.docs
            .map((d) => MessageModel.fromJson({...d.data(), 'id': d.id}))
            .toList());
  }

  /// Marks all admin-sent messages on [orderId] as read.
  Future<void> markMessagesRead(String orderId) async {
    try {
      final col = _orders.doc(orderId).collection('messages');
      final unread = await col
          .where('fromAdmin', isEqualTo: true)
          .where('isRead', isEqualTo: false)
          .get();
      final batch = _db.batch();
      for (final doc in unread.docs) {
        batch.update(doc.reference, {'isRead': true});
      }
      await batch.commit();
    } catch (e) {
      // Non-fatal.
    }
  }

  // ------------------------------------------------------------- SETTINGS
  Future<Map<String, dynamic>> getSettings() async {
    try {
      final doc = await _db.collection('settings').doc('config').get();
      return doc.data() ?? {'maxQty': 10, 'minQty': 1};
    } catch (e) {
      return {'maxQty': 10, 'minQty': 1};
    }
  }
}
