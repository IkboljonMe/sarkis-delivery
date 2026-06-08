import 'package:cloud_firestore/cloud_firestore.dart';

import 'order_item_model.dart';

class OrderModel {
  final String id;
  final String userId;
  final String userName;
  final String userPhone;
  final String userAddress;
  final String userCity;
  final String userGroup;
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
    this.createdAt,
    this.updatedAt,
  }) : subtotal = subtotal ?? totalPrice;

  int get itemCount => items.fold(0, (s, i) => s + i.qty);

  String get shortId =>
      id.isEmpty ? '' : id.substring(0, id.length < 6 ? id.length : 6).toUpperCase();

  String get itemsSummary =>
      items.map((i) => '${i.name} x${i.qty}').join(', ');

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
      shiftId: json['shiftId'] as String? ?? '',
      shiftDate: json['shiftDate'] is Timestamp
          ? (json['shiftDate'] as Timestamp).toDate()
          : DateTime.now(),
      shiftLabel: json['shiftLabel'] as String? ?? '',
      items: items,
      subtotal: (json['subtotal'] as num?)?.toDouble(),
      discount: (json['discount'] as num?)?.toDouble() ?? 0.0,
      couponCode: json['couponCode'] as String? ?? '',
      totalPrice: (json['totalPrice'] as num?)?.toDouble() ?? 0.0,
      status: json['status'] as String? ?? 'pending',
      adminNote: json['adminNote'] as String? ?? '',
      createdAt: json['createdAt'] is Timestamp
          ? (json['createdAt'] as Timestamp).toDate()
          : null,
      updatedAt: json['updatedAt'] is Timestamp
          ? (json['updatedAt'] as Timestamp).toDate()
          : null,
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
        'shiftId': shiftId,
        'shiftDate': Timestamp.fromDate(shiftDate),
        'shiftLabel': shiftLabel,
        'items': items.map((e) => e.toJson()).toList(),
        'subtotal': subtotal,
        'discount': discount,
        'couponCode': couponCode,
        'totalPrice': totalPrice,
        'status': status,
        'adminNote': adminNote,
        'createdAt': createdAt != null
            ? Timestamp.fromDate(createdAt!)
            : FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
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
      shiftId: shiftId,
      shiftDate: shiftDate,
      shiftLabel: shiftLabel,
      items: items ?? this.items,
      totalPrice: totalPrice ?? this.totalPrice,
      status: status ?? this.status,
      adminNote: adminNote ?? this.adminNote,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  @override
  bool operator ==(Object other) => other is OrderModel && other.id == id;

  @override
  int get hashCode => id.hashCode;
}
