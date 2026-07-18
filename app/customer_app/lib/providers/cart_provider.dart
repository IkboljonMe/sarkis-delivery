import 'package:drift/drift.dart';
import 'package:flutter/foundation.dart';

import '../local_db/app_database.dart';
import '../models/coupon_model.dart';
import '../models/order_item_model.dart';
import '../models/order_model.dart';
import '../models/product_model.dart';
import '../models/shift_model.dart';
import '../models/user_model.dart';
import '../services/coupon_service.dart';
import '../services/message_service.dart';
import '../services/order_service.dart';
import '../utils/constants.dart';
import '../utils/order_messages.dart';

/// In-memory + persisted cart. Stores qty per productId and the chosen shift.
class CartProvider extends ChangeNotifier {
  final Map<String, int> _qty = {}; // productId -> qty
  ShiftModel? _shift;
  CouponModel? _coupon;
  String? _editingOrderId; // non-null while editing an existing order
  int _minQty = AppConstants.defaultMinQty;
  int _maxQty = AppConstants.defaultMaxQty;
  bool _placing = false;

  Map<String, int> get quantities => Map.unmodifiable(_qty);
  ShiftModel? get shift => _shift;
  CouponModel? get coupon => _coupon;
  String? get editingOrderId => _editingOrderId;
  bool get isEditing => _editingOrderId != null;

  /// Loads an existing order into the cart so the customer can amend it.
  void loadFromOrder(OrderModel o, ShiftModel shift) {
    _qty.clear();
    for (final it in o.items) {
      if (it.qty > 0) _qty[it.productId] = it.qty;
    }
    _shift = shift;
    _coupon = null;
    _editingOrderId = o.id;
    notifyListeners();
    _persist();
  }

  void cancelEdit() {
    _editingOrderId = null;
    notifyListeners();
  }
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
    // Choosing a delivery starts a fresh order — never an edit of an old one.
    _editingOrderId = null;
    _shift = shift;
    notifyListeners();
    _persist();
  }

  void setCoupon(CouponModel? coupon) {
    _coupon = coupon;
    notifyListeners();
  }

  /// Order-level discount the applied coupon yields for [subtotal].
  double couponDiscount(double subtotal) => _coupon?.discountFor(subtotal) ?? 0;

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
    _coupon = null;
    _editingOrderId = null;
    notifyListeners();
    _persist();
  }

  double total(List<ProductModel> products) {
    double t = 0;
    for (final p in products) {
      t += (_qty[p.id] ?? 0) * p.discountedPrice;
    }
    return t;
  }

  Future<void> loadPersisted() async {
    try {
      final db = AppDatabase.instance;
      final meta = await (db.select(db.cartMeta)..where((t) => t.id.equals(0))).getSingleOrNull();
      final items = await db.select(db.cartItems).get();
      
      _qty.clear();
      for (final row in items) {
        _qty[row.productId] = row.qty;
      }
      
      if (meta != null) {
        if (meta.editingOrderId.isNotEmpty) {
          _editingOrderId = meta.editingOrderId;
        }
        if (meta.shiftId.isNotEmpty) {
          final sRow = await (db.select(db.shifts)..where((t) => t.id.equals(meta.shiftId))).getSingleOrNull();
          if (sRow != null) {
            _shift = ShiftModel(
              id: sRow.id,
              group: sRow.group,
              date: sRow.date,
              label: sRow.label,
              isOpen: sRow.isOpen,
              cancelDaysBefore: sRow.cancelDaysBefore,
              editDaysBefore: sRow.editDaysBefore,
            );
          }
        }
        if (meta.couponCode.isNotEmpty) {
          final cRow = await (db.select(db.coupons)..where((t) => t.code.equals(meta.couponCode))).getSingleOrNull();
          if (cRow != null) {
            _coupon = CouponModel(
              id: cRow.code,
              code: cRow.code,
              type: cRow.type,
              value: cRow.value,
              minOrder: cRow.minOrder,
              isActive: cRow.isActive,
            );
          }
        }
      }
      notifyListeners();
    } catch (_) {}
  }

  Future<void> _persist() async {
    try {
      final db = AppDatabase.instance;
      await db.transaction(() async {
        await db.delete(db.cartItems).go();
        for (final entry in _qty.entries) {
          await db.into(db.cartItems).insert(CartItemsCompanion.insert(
            productId: entry.key,
            qty: entry.value,
          ));
        }
        await db.into(db.cartMeta).insertOnConflictUpdate(CartMetaCompanion.insert(
          id: const Value(0),
          shiftId: Value(_shift?.id ?? ''),
          couponCode: Value(_coupon?.code ?? ''),
          editingOrderId: Value(_editingOrderId ?? ''),
        ));
      });
    } catch (_) {}
  }

  /// Builds and writes the order. Returns new order id, or null on failure.
  /// An optional [coupon] applies an order-level discount on top of any
  /// per-product discounts already baked into the item unit prices.
  Future<String?> placeOrder({
    required UserModel user,
    required List<ProductModel> products,
  }) async {
    if (_qty.isEmpty) return null;
    // If no delivery shift was chosen (the cart is reachable directly from the
    // product list, which never sets one), place the order as "awaiting
    // schedule" — exactly the "we'll agree on a delivery date" flow the cart
    // already advertises. Previously this returned null silently, so checkout
    // appeared to do nothing for in-coverage users who skipped the shift picker.
    final awaiting = _shift == null;
    final coupon = _coupon;
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
            unitPrice: p.discountedPrice,
          ));
        }
      }
      final subtotal = items.fold(0.0, (s, i) => s + i.subtotal);
      final discount = coupon?.discountFor(subtotal) ?? 0;
      final grandTotal = (subtotal - discount).clamp(0, subtotal).toDouble();

      // Editing an existing order: update in place, no new thank-you message.
      if (_editingOrderId != null) {
        final editedId = _editingOrderId!;
        await OrderService.instance.updateOrder(editedId, {
          'items': items.map((e) => e.toJson()).toList(),
          'subtotal': subtotal,
          'discount': discount,
          'couponCode': discount > 0 ? (coupon?.code ?? '') : '',
          'totalPrice': grandTotal,
        });
        if (discount > 0 && coupon != null) {
          await CouponService.instance.incrementUsage(coupon.id);
        }
        clear();
        _placing = false;
        notifyListeners();
        return editedId;
      }

      final order = OrderModel(
        id: '',
        userId: user.id,
        userName: user.fullName,
        userPhone: user.phone,
        userAddress: user.address,
        userCity: user.city,
        userGroup: user.group,
        userLat: user.lat,
        userLng: user.lng,
        shiftId: _shift?.id ?? '',
        shiftDate: _shift?.date ?? DateTime.now(),
        shiftLabel: _shift?.label ?? '',
        items: items,
        subtotal: subtotal,
        discount: discount,
        couponCode: discount > 0 ? (coupon?.code ?? '') : '',
        totalPrice: grandTotal,
        status: AppConstants.statusPending,
        cancelDaysBefore: _shift?.cancelDaysBefore ?? 3,
        editDaysBefore: _shift?.editDaysBefore ?? 4,
        pendingApproval: true,
        awaitingSchedule: awaiting,
      );
      final id = await OrderService.instance.createOrder(order);
      // Best-effort: bump the coupon's redemption counter.
      if (discount > 0 && coupon != null) {
        await CouponService.instance.incrementUsage(coupon.id);
      }
      // Share the new order into the chat as an order card. The backend
      // attributes messages to the authenticated user, so this is sent as
      // the customer (the old Firebase code could fake an admin sender —
      // the REST API correctly refuses that).
      try {
        await MessageService.instance.ensureTopic(
            topicId: user.id, userName: user.fullName, userGroup: user.group);
        await MessageService.instance.sendMessage(
          topicId: user.id,
          text: OrderMessages.thankYou(user.language),
          senderId: user.id,
          senderName: user.fullName.isEmpty ? user.name : user.fullName,
          isFromAdmin: false,
          type: 'order',
          orderId: id,
        );
      } catch (_) {}
      clear();
      _placing = false;
      notifyListeners();
      return id;
    } catch (e, st) {
      debugPrint('placeOrder failed: $e\n$st');
      _placing = false;
      notifyListeners();
      return null;
    }
  }
}
