class OrderItemModel {
  final String productId;
  final String name;
  final int qty;
  final double price;

  OrderItemModel({
    required this.productId,
    required this.name,
    required this.qty,
    required this.price,
  });

  double get subtotal => qty * price;

  factory OrderItemModel.fromJson(Map<String, dynamic> json) {
    return OrderItemModel(
      productId: json['productId'] as String? ?? '',
      name: json['name'] as String? ?? '',
      qty: (json['qty'] as num?)?.toInt() ?? 0,
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'productId': productId,
      'name': name,
      'qty': qty,
      'price': price,
    };
  }

  OrderItemModel copyWith({
    String? productId,
    String? name,
    int? qty,
    double? price,
  }) {
    return OrderItemModel(
      productId: productId ?? this.productId,
      name: name ?? this.name,
      qty: qty ?? this.qty,
      price: price ?? this.price,
    );
  }
}
