import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/delivery_date_model.dart';
import '../models/message_model.dart';
import '../models/order_model.dart';
import '../models/product_model.dart';
import '../models/user_model.dart';

/// Central access point to Firestore for the admin app.
/// The admin has full read/write access (enforced by Firestore rules).
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

  // ------------------------------------------------------------- PRODUCTS
  Stream<List<ProductModel>> productsStream() {
    return _products.snapshots().map((snap) => snap.docs
        .map((d) => ProductModel.fromJson({...d.data(), 'id': d.id}))
        .toList());
  }

  Future<void> saveProduct(ProductModel product) async {
    try {
      if (product.id.isEmpty) {
        final ref = _products.doc();
        await ref.set(product.copyWith(id: ref.id).toJson());
      } else {
        await _products.doc(product.id).set(product.toJson());
      }
    } catch (e) {
      throw Exception('Failed to save product: $e');
    }
  }

  Future<void> setProductActive(String id, bool active) async {
    try {
      await _products.doc(id).update({'isActive': active});
    } catch (e) {
      throw Exception('Failed to update product: $e');
    }
  }

  Future<void> deleteProduct(String id) async {
    try {
      await _products.doc(id).delete();
    } catch (e) {
      throw Exception('Failed to delete product: $e');
    }
  }

  // -------------------------------------------------------- DELIVERY DATES
  Stream<List<DeliveryDateModel>> allDeliveryDatesStream() {
    return _deliveryDates.snapshots().map((snap) {
      final list = snap.docs
          .map((d) => DeliveryDateModel.fromJson({...d.data(), 'id': d.id}))
          .toList();
      list.sort((a, b) => a.date.compareTo(b.date));
      return list;
    });
  }

  Future<void> addDeliveryDate(DeliveryDateModel date) async {
    try {
      final ref = _deliveryDates.doc();
      final data = date.copyWith(id: ref.id).toJson();
      data['createdAt'] = FieldValue.serverTimestamp();
      await ref.set(data);
    } catch (e) {
      throw Exception('Failed to add delivery date: $e');
    }
  }

  Future<void> setDeliveryDateOpen(String id, bool isOpen) async {
    try {
      await _deliveryDates.doc(id).update({'isOpen': isOpen});
    } catch (e) {
      throw Exception('Failed to update delivery date: $e');
    }
  }

  Future<void> deleteDeliveryDate(String id) async {
    try {
      await _deliveryDates.doc(id).delete();
    } catch (e) {
      throw Exception('Failed to delete delivery date: $e');
    }
  }

  // --------------------------------------------------------------- ORDERS
  Stream<List<OrderModel>> allOrdersStream() {
    return _orders.snapshots().map((snap) {
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

  Future<void> updateOrderStatus(String orderId, String status) async {
    try {
      await _orders.doc(orderId).update({'status': status});
    } catch (e) {
      throw Exception('Failed to update order status: $e');
    }
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

  Future<void> sendAdminMessage(String orderId, String text) async {
    try {
      final ref = _orders.doc(orderId).collection('messages').doc();
      await ref.set({
        'id': ref.id,
        'text': text,
        'fromAdmin': true,
        'isRead': false,
        'createdAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Failed to send message: $e');
    }
  }

  // ------------------------------------------------------------- SETTINGS
  Future<Map<String, dynamic>> getSettings() async {
    try {
      final doc = await _db.collection('settings').doc('config').get();
      return doc.data() ?? {'maxQty': 10, 'minQty': 1, 'whatsappNumber': ''};
    } catch (e) {
      return {'maxQty': 10, 'minQty': 1, 'whatsappNumber': ''};
    }
  }

  Future<void> saveSettings(Map<String, dynamic> data) async {
    try {
      await _db
          .collection('settings')
          .doc('config')
          .set(data, SetOptions(merge: true));
    } catch (e) {
      throw Exception('Failed to save settings: $e');
    }
  }
}
