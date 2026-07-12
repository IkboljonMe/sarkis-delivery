class OrderItemModel {
  final String productId;
  final String categoryId;
  final String name;
  final int qty;
  final double unitPrice;

  OrderItemModel({
    required this.productId,
    this.categoryId = '',
    required this.name,
    required this.qty,
    required this.unitPrice,
  });

  double get subtotal => qty * unitPrice;

  factory OrderItemModel.fromJson(Map<String, dynamic> json) {
    return OrderItemModel(
      productId: json['productId'] as String? ?? '',
      categoryId: json['categoryId'] as String? ?? '',
      name: json['name'] as String? ?? '',
      qty: (json['qty'] as num?)?.toInt() ?? 0,
      unitPrice: (json['unitPrice'] as num?)?.toDouble() ??
          (json['price'] as num?)?.toDouble() ??
          0.0,
    );
  }

  Map<String, dynamic> toJson() => {
        'productId': productId,
        'categoryId': categoryId,
        'name': name,
        'qty': qty,
        'unitPrice': unitPrice,
        'subtotal': subtotal,
      };

  OrderItemModel copyWith({
    String? productId,
    String? categoryId,
    String? name,
    int? qty,
    double? unitPrice,
  }) {
    return OrderItemModel(
      productId: productId ?? this.productId,
      categoryId: categoryId ?? this.categoryId,
      name: name ?? this.name,
      qty: qty ?? this.qty,
      unitPrice: unitPrice ?? this.unitPrice,
    );
  }
}
