import 'package:cloud_firestore/cloud_firestore.dart';

import 'order_item_model.dart';

class OrderModel {
  final String id;
  final String userId;
  final String userName;
  final String userPhone;
  final String userAddress;
  final String userGroup;
  final List<OrderItemModel> items;
  final String deliveryDateId;
  final DateTime deliveryDate;
  final String group; // Berlin | Hamburg
  final double totalPrice;
  final String status; // pending | confirmed | on_the_way | delivered | cancelled
  final String adminNote;
  final DateTime? createdAt;

  OrderModel({
    required this.id,
    required this.userId,
    required this.userName,
    required this.userPhone,
    required this.userAddress,
    required this.userGroup,
    required this.items,
    required this.deliveryDateId,
    required this.deliveryDate,
    required this.group,
    required this.totalPrice,
    required this.status,
    this.adminNote = '',
    this.createdAt,
  });

  int get itemCount => items.fold(0, (sum, item) => sum + item.qty);

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    final rawItems = json['items'];
    final List<OrderItemModel> parsedItems = [];
    if (rawItems is List) {
      for (final item in rawItems) {
        if (item is Map) {
          parsedItems
              .add(OrderItemModel.fromJson(Map<String, dynamic>.from(item)));
        }
      }
    }
    return OrderModel(
      id: json['id'] as String? ?? '',
      userId: json['userId'] as String? ?? '',
      userName: json['userName'] as String? ?? '',
      userPhone: json['userPhone'] as String? ?? '',
      userAddress: json['userAddress'] as String? ?? '',
      userGroup: json['userGroup'] as String? ?? '',
      items: parsedItems,
      deliveryDateId: json['deliveryDateId'] as String? ?? '',
      deliveryDate: json['deliveryDate'] is Timestamp
          ? (json['deliveryDate'] as Timestamp).toDate()
          : DateTime.now(),
      group: json['group'] as String? ?? '',
      totalPrice: (json['totalPrice'] as num?)?.toDouble() ?? 0.0,
      status: json['status'] as String? ?? 'pending',
      adminNote: json['adminNote'] as String? ?? '',
      createdAt: json['createdAt'] is Timestamp
          ? (json['createdAt'] as Timestamp).toDate()
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'userName': userName,
      'userPhone': userPhone,
      'userAddress': userAddress,
      'userGroup': userGroup,
      'items': items.map((e) => e.toJson()).toList(),
      'deliveryDateId': deliveryDateId,
      'deliveryDate': Timestamp.fromDate(deliveryDate),
      'group': group,
      'totalPrice': totalPrice,
      'status': status,
      'adminNote': adminNote,
      'createdAt': createdAt != null
          ? Timestamp.fromDate(createdAt!)
          : FieldValue.serverTimestamp(),
    };
  }

  OrderModel copyWith({
    String? id,
    String? userId,
    String? userName,
    String? userPhone,
    String? userAddress,
    String? userGroup,
    List<OrderItemModel>? items,
    String? deliveryDateId,
    DateTime? deliveryDate,
    String? group,
    double? totalPrice,
    String? status,
    String? adminNote,
    DateTime? createdAt,
  }) {
    return OrderModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      userName: userName ?? this.userName,
      userPhone: userPhone ?? this.userPhone,
      userAddress: userAddress ?? this.userAddress,
      userGroup: userGroup ?? this.userGroup,
      items: items ?? this.items,
      deliveryDateId: deliveryDateId ?? this.deliveryDateId,
      deliveryDate: deliveryDate ?? this.deliveryDate,
      group: group ?? this.group,
      totalPrice: totalPrice ?? this.totalPrice,
      status: status ?? this.status,
      adminNote: adminNote ?? this.adminNote,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
