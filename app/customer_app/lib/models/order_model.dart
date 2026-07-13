import '../utils/json_date.dart';

import 'order_item_model.dart';

class OrderModel {
  final String id;
  final String userId;
  final String userName;
  final String userPhone;
  final String userAddress;
  final String userCity;
  final String userGroup;
  final double? userLat;
  final double? userLng;
  final String shiftId;
  final DateTime shiftDate;
  final String shiftLabel;
  final List<OrderItemModel> items;
  final double subtotal;
  final double discount;
  final String couponCode;
  final double totalPrice;
  final String status;
  final String adminNote;
  // Denormalized from the shift at order time: how many days before delivery
  // the customer may still cancel / edit.
  final int cancelDaysBefore;
  final int editDaysBefore;
  // New orders wait for admin acceptance unless auto-accept is on.
  final bool pendingApproval;
  // True when the customer is outside all delivery groups: the order has no
  // shift/date yet and the admin will schedule it.
  final bool awaitingSchedule;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  OrderModel({
    required this.id,
    required this.userId,
    required this.userName,
    required this.userPhone,
    required this.userAddress,
    this.userCity = '',
    required this.userGroup,
    this.userLat,
    this.userLng,
    required this.shiftId,
    required this.shiftDate,
    required this.shiftLabel,
    required this.items,
    double? subtotal,
    this.discount = 0,
    this.couponCode = '',
    required this.totalPrice,
    this.status = 'pending',
    this.adminNote = '',
    this.cancelDaysBefore = 3,
    this.editDaysBefore = 4,
    this.pendingApproval = false,
    this.awaitingSchedule = false,
    this.createdAt,
    this.updatedAt,
  }) : subtotal = subtotal ?? totalPrice;

  int get itemCount => items.fold(0, (s, i) => s + i.qty);

  String get shortId =>
      id.isEmpty ? '' : id.substring(0, id.length < 6 ? id.length : 6).toUpperCase();

  String get itemsSummary =>
      items.map((i) => '${i.name} x${i.qty}').join(', ');

  /// Whole days from today until the delivery date.
  int get daysUntilDelivery {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final d = DateTime(shiftDate.year, shiftDate.month, shiftDate.day);
    return d.difference(today).inDays;
  }

  bool get _isActive => status == 'pending' || status == 'confirmed';

  /// Customer may cancel while the order is active and still outside the
  /// cancellation cut-off window. Orders awaiting scheduling have no date yet,
  /// so they can always be cancelled while active.
  bool get canCancel =>
      _isActive &&
      (awaitingSchedule || daysUntilDelivery >= cancelDaysBefore);

  /// Customer may edit while active and outside the (usually larger) edit
  /// cut-off window. Editing needs a concrete delivery date, so it is disabled
  /// while awaiting scheduling.
  bool get canEdit =>
      _isActive && !awaitingSchedule && daysUntilDelivery >= editDaysBefore;

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    final rawItems = json['items'];
    final items = <OrderItemModel>[];
    if (rawItems is List) {
      for (final i in rawItems) {
        if (i is Map) {
          items.add(OrderItemModel.fromJson(Map<String, dynamic>.from(i)));
        }
      }
    }
    return OrderModel(
      id: json['id'] as String? ?? '',
      userId: json['userId'] as String? ?? '',
      userName: json['userName'] as String? ?? '',
      userPhone: json['userPhone'] as String? ?? '',
      userAddress: json['userAddress'] as String? ?? '',
      userCity: json['userCity'] as String? ?? '',
      userGroup: json['userGroup'] as String? ?? '',
      userLat: (json['userLat'] as num?)?.toDouble(),
      userLng: (json['userLng'] as num?)?.toDouble(),
      shiftId: json['shiftId'] as String? ?? '',
      shiftDate: parseDate(json['shiftDate']) ?? DateTime.now(),
      shiftLabel: json['shiftLabel'] as String? ?? '',
      items: items,
      subtotal: (json['subtotal'] as num?)?.toDouble(),
      discount: (json['discount'] as num?)?.toDouble() ?? 0.0,
      couponCode: json['couponCode'] as String? ?? '',
      totalPrice: (json['totalPrice'] as num?)?.toDouble() ?? 0.0,
      status: json['status'] as String? ?? 'pending',
      adminNote: json['adminNote'] as String? ?? '',
      cancelDaysBefore: (json['cancelDaysBefore'] as num?)?.toInt() ?? 3,
      editDaysBefore: (json['editDaysBefore'] as num?)?.toInt() ?? 4,
      pendingApproval: json['pendingApproval'] as bool? ?? false,
      awaitingSchedule: json['awaitingSchedule'] as bool? ?? false,
      createdAt: parseDate(json['createdAt']),
      updatedAt: parseDate(json['updatedAt']),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'userId': userId,
        'userName': userName,
        'userPhone': userPhone,
        'userAddress': userAddress,
        'userCity': userCity,
        'userGroup': userGroup,
        'userLat': userLat,
        'userLng': userLng,
        'shiftId': shiftId,
        'shiftDate': shiftDate.toIso8601String(),
        'shiftLabel': shiftLabel,
        'items': items.map((e) => e.toJson()).toList(),
        'subtotal': subtotal,
        'discount': discount,
        'couponCode': couponCode,
        'totalPrice': totalPrice,
        'status': status,
        'adminNote': adminNote,
        'cancelDaysBefore': cancelDaysBefore,
        'editDaysBefore': editDaysBefore,
        'pendingApproval': pendingApproval,
        'awaitingSchedule': awaitingSchedule,
        'createdAt': createdAt?.toIso8601String(),
        'updatedAt': updatedAt?.toIso8601String(),
      };

  OrderModel copyWith({
    String? id,
    String? status,
    String? adminNote,
    List<OrderItemModel>? items,
    double? totalPrice,
  }) {
    return OrderModel(
      id: id ?? this.id,
      userId: userId,
      userName: userName,
      userPhone: userPhone,
      userAddress: userAddress,
      userCity: userCity,
      userGroup: userGroup,
      userLat: userLat,
      userLng: userLng,
      shiftId: shiftId,
      shiftDate: shiftDate,
      shiftLabel: shiftLabel,
      items: items ?? this.items,
      totalPrice: totalPrice ?? this.totalPrice,
      status: status ?? this.status,
      adminNote: adminNote ?? this.adminNote,
      awaitingSchedule: awaitingSchedule,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  @override
  bool operator ==(Object other) => other is OrderModel && other.id == id;

  @override
  int get hashCode => id.hashCode;
}
