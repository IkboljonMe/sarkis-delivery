import 'package:flutter/foundation.dart';

import '../models/delivery_date_model.dart';
import '../models/order_item_model.dart';
import '../models/order_model.dart';
import '../models/product_model.dart';
import '../models/user_model.dart';
import '../services/firebase_service.dart';
import '../utils/constants.dart';

/// Manages the in-progress cart and order creation.
class OrderProvider extends ChangeNotifier {
  final FirebaseService _db = FirebaseService.instance;

  // productId -> quantity
  final Map<String, int> _cart = {};
  int _minQty = AppConstants.defaultMinQty;
  int _maxQty = AppConstants.defaultMaxQty;
  bool _placing = false;

  Map<String, int> get cart => Map.unmodifiable(_cart);
  int get minQty => _minQty;
  int get maxQty => _maxQty;
  bool get placing => _placing;

  int qtyOf(String productId) => _cart[productId] ?? 0;
  int get totalItems => _cart.values.fold(0, (s, q) => s + q);

  double totalPrice(List<ProductModel> products) {
    double total = 0;
    for (final p in products) {
      total += (_cart[p.id] ?? 0) * p.price;
    }
    return total;
  }

  Future<void> loadSettings() async {
    try {
      final settings = await _db.getSettings();
      _minQty = (settings['minQty'] as num?)?.toInt() ?? _minQty;
      _maxQty = (settings['maxQty'] as num?)?.toInt() ?? _maxQty;
      notifyListeners();
    } catch (_) {}
  }

  /// Resolves the effective max for a product (per-product cap vs global).
  int effectiveMax(ProductModel product) {
    final productMax = product.maxQty > 0 ? product.maxQty : _maxQty;
    return productMax < _maxQty ? productMax : _maxQty;
  }

  void increment(ProductModel product) {
    final current = _cart[product.id] ?? 0;
    if (current >= effectiveMax(product)) return;
    _cart[product.id] = current + 1;
    notifyListeners();
  }

  void decrement(ProductModel product) {
    final current = _cart[product.id] ?? 0;
    if (current <= 0) return;
    final next = current - 1;
    if (next <= 0) {
      _cart.remove(product.id);
    } else {
      _cart[product.id] = next;
    }
    notifyListeners();
  }

  void clearCart() {
    _cart.clear();
    notifyListeners();
  }

  Stream<List<ProductModel>> productsStream() => _db.productsStream();

  Stream<List<OrderModel>> userOrdersStream(String userId) =>
      _db.userOrdersStream(userId);

  /// Builds and writes the order from the current cart. Returns the new id.
  Future<String?> placeOrder({
    required UserModel user,
    required DeliveryDateModel deliveryDate,
    required List<ProductModel> products,
  }) async {
    if (_cart.isEmpty) return null;
    _placing = true;
    notifyListeners();

    try {
      final items = <OrderItemModel>[];
      for (final p in products) {
        final qty = _cart[p.id] ?? 0;
        if (qty > 0) {
          items.add(OrderItemModel(
            productId: p.id,
            name: p.nameFor(user.language),
            qty: qty,
            price: p.price,
          ));
        }
      }

      final order = OrderModel(
        id: '',
        userId: user.id,
        userName: user.name,
        userPhone: user.phone,
        userAddress: user.address,
        userGroup: user.group,
        items: items,
        deliveryDateId: deliveryDate.id,
        deliveryDate: deliveryDate.date,
        group: deliveryDate.group,
        totalPrice: items.fold(0.0, (s, i) => s + i.subtotal),
        status: AppConstants.statusPending,
      );

      final id = await _db.createOrder(order);
      clearCart();
      _placing = false;
      notifyListeners();
      return id;
    } catch (e) {
      _placing = false;
      notifyListeners();
      return null;
    }
  }
}
