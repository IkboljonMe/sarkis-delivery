import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/order_item_model.dart';
import '../models/order_model.dart';
import '../models/product_model.dart';
import '../models/shift_model.dart';
import '../models/user_model.dart';
import '../services/order_service.dart';
import '../utils/constants.dart';

/// In-memory + persisted cart. Stores qty per productId and the chosen shift.
class CartProvider extends ChangeNotifier {
  static const _prefKey = 'cart_state';

  final Map<String, int> _qty = {}; // productId -> qty
  ShiftModel? _shift;
  int _minQty = AppConstants.defaultMinQty;
  int _maxQty = AppConstants.defaultMaxQty;
  bool _placing = false;

  Map<String, int> get quantities => Map.unmodifiable(_qty);
  ShiftModel? get shift => _shift;
  int get minQty => _minQty;
  int get maxQty => _maxQty;
  bool get placing => _placing;
  bool get isEmpty => _qty.isEmpty;
  int get totalItems => _qty.values.fold(0, (s, q) => s + q);

  int qtyOf(String productId) => _qty[productId] ?? 0;

  void setLimits({int? min, int? max}) {
    if (min != null) _minQty = min;
    if (max != null) _maxQty = max;
  }

  void setShift(ShiftModel shift) {
    _shift = shift;
    notifyListeners();
    _persist();
  }

  int effectiveMax(ProductModel p) {
    final pMax = p.maxQty > 0 ? p.maxQty : _maxQty;
    return pMax < _maxQty ? pMax : _maxQty;
  }

  void increment(ProductModel p) {
    final cur = _qty[p.id] ?? 0;
    if (cur >= effectiveMax(p)) return;
    _qty[p.id] = cur + 1;
    notifyListeners();
    _persist();
  }

  void decrement(ProductModel p) {
    final cur = _qty[p.id] ?? 0;
    if (cur <= 0) return;
    final next = cur - 1;
    if (next <= 0) {
      _qty.remove(p.id);
    } else {
      _qty[p.id] = next;
    }
    notifyListeners();
    _persist();
  }

  void setQty(String productId, int qty) {
    if (qty <= 0) {
      _qty.remove(productId);
    } else {
      _qty[productId] = qty;
    }
    notifyListeners();
    _persist();
  }

  void remove(String productId) {
    _qty.remove(productId);
    notifyListeners();
    _persist();
  }

  void clear() {
    _qty.clear();
    notifyListeners();
    _persist();
  }

  double total(List<ProductModel> products) {
    double t = 0;
    for (final p in products) {
      t += (_qty[p.id] ?? 0) * p.price;
    }
    return t;
  }

  Future<void> loadPersisted() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_prefKey);
      if (raw == null) return;
      final map = jsonDecode(raw) as Map<String, dynamic>;
      final q = map['qty'] as Map<String, dynamic>?;
      if (q != null) {
        _qty.clear();
        q.forEach((k, v) => _qty[k] = (v as num).toInt());
      }
      notifyListeners();
    } catch (_) {}
  }

  Future<void> _persist() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_prefKey, jsonEncode({'qty': _qty}));
    } catch (_) {}
  }

  /// Builds and writes the order. Returns new order id, or null on failure.
  Future<String?> placeOrder({
    required UserModel user,
    required List<ProductModel> products,
  }) async {
    if (_qty.isEmpty || _shift == null) return null;
    _placing = true;
    notifyListeners();
    try {
      final items = <OrderItemModel>[];
      for (final p in products) {
        final q = _qty[p.id] ?? 0;
        if (q > 0) {
          items.add(OrderItemModel(
            productId: p.id,
            categoryId: p.categoryId,
            name: p.nameFor(user.language),
            qty: q,
            unitPrice: p.price,
          ));
        }
      }
      final order = OrderModel(
        id: '',
        userId: user.id,
        userName: user.name,
        userPhone: user.phone,
        userAddress: user.address,
        userCity: user.city,
        userGroup: user.group,
        shiftId: _shift!.id,
        shiftDate: _shift!.date,
        shiftLabel: _shift!.label,
        items: items,
        totalPrice: items.fold(0.0, (s, i) => s + i.subtotal),
        status: AppConstants.statusPending,
      );
      final id = await OrderService.instance.createOrder(order);
      clear();
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
