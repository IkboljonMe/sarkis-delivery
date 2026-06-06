class ProductModel {
  final String id;
  final Map<String, String> name; // {en, hy, ru, tr, de}
  final double price; // EUR
  final String unit; // piece, pack
  final int maxQty;
  final bool isActive;
  final String imageUrl;

  ProductModel({
    required this.id,
    required this.name,
    required this.price,
    required this.unit,
    required this.maxQty,
    required this.isActive,
    this.imageUrl = '',
  });

  /// Returns the localized name for [lang], falling back to en then any value.
  String nameFor(String lang) {
    if (name[lang] != null && name[lang]!.isNotEmpty) return name[lang]!;
    if (name['en'] != null && name['en']!.isNotEmpty) return name['en']!;
    return name.values.isNotEmpty ? name.values.first : '';
  }

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    final rawName = json['name'];
    final Map<String, String> parsedName = {};
    if (rawName is Map) {
      rawName.forEach((key, value) {
        parsedName[key.toString()] = value?.toString() ?? '';
      });
    }
    return ProductModel(
      id: json['id'] as String? ?? '',
      name: parsedName,
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
      unit: json['unit'] as String? ?? 'piece',
      maxQty: (json['maxQty'] as num?)?.toInt() ?? 10,
      isActive: json['isActive'] as bool? ?? true,
      imageUrl: json['imageUrl'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'price': price,
      'unit': unit,
      'maxQty': maxQty,
      'isActive': isActive,
      'imageUrl': imageUrl,
    };
  }

  ProductModel copyWith({
    String? id,
    Map<String, String>? name,
    double? price,
    String? unit,
    int? maxQty,
    bool? isActive,
    String? imageUrl,
  }) {
    return ProductModel(
      id: id ?? this.id,
      name: name ?? this.name,
      price: price ?? this.price,
      unit: unit ?? this.unit,
      maxQty: maxQty ?? this.maxQty,
      isActive: isActive ?? this.isActive,
      imageUrl: imageUrl ?? this.imageUrl,
    );
  }
}
