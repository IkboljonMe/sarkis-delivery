class ProductModel {
  final String id;
  final String categoryId;
  final Map<String, String> name; // {en, hy, ru, tr, de}
  final Map<String, String> description; // {en, hy, ru, tr, de}
  final double price; // EUR
  final String unit;
  final int maxQty;
  final String imageUrl;
  final List<String> images; // gallery (2-3 photos); imageUrl is the primary
  final bool isActive;
  final int sortOrder;

  ProductModel({
    required this.id,
    required this.categoryId,
    required this.name,
    this.description = const {},
    required this.price,
    this.unit = 'piece',
    this.maxQty = 10,
    this.imageUrl = '',
    this.images = const [],
    this.isActive = true,
    this.sortOrder = 0,
  });

  /// All gallery images (falls back to imageUrl). De-duplicated, non-empty.
  List<String> get gallery {
    final all = <String>[if (imageUrl.isNotEmpty) imageUrl, ...images];
    return all.where((e) => e.isNotEmpty).toSet().toList();
  }

  String nameFor(String lang) => _localized(name, lang);
  String descriptionFor(String lang) => _localized(description, lang);

  static String _localized(Map<String, String> map, String lang) {
    if (map[lang]?.isNotEmpty ?? false) return map[lang]!;
    if (map['en']?.isNotEmpty ?? false) return map['en']!;
    return map.values.isNotEmpty ? map.values.first : '';
  }

  static Map<String, String> _parseMap(dynamic raw) {
    final parsed = <String, String>{};
    if (raw is Map) {
      raw.forEach((k, v) => parsed[k.toString()] = v?.toString() ?? '');
    }
    return parsed;
  }

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    return ProductModel(
      id: json['id'] as String? ?? '',
      categoryId: json['categoryId'] as String? ?? '',
      name: _parseMap(json['name']),
      description: _parseMap(json['description']),
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
      unit: json['unit'] as String? ?? 'piece',
      maxQty: (json['maxQty'] as num?)?.toInt() ?? 10,
      imageUrl: json['imageUrl'] as String? ?? '',
      images: (json['images'] as List?)
              ?.map((e) => e.toString())
              .where((e) => e.isNotEmpty)
              .toList() ??
          const [],
      isActive: json['isActive'] as bool? ?? true,
      sortOrder: (json['sortOrder'] as num?)?.toInt() ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'categoryId': categoryId,
        'name': name,
        'description': description,
        'price': price,
        'unit': unit,
        'maxQty': maxQty,
        'imageUrl': imageUrl,
        'images': images,
        'isActive': isActive,
        'sortOrder': sortOrder,
      };

  ProductModel copyWith({
    String? id,
    String? categoryId,
    Map<String, String>? name,
    Map<String, String>? description,
    double? price,
    String? unit,
    int? maxQty,
    String? imageUrl,
    List<String>? images,
    bool? isActive,
    int? sortOrder,
  }) {
    return ProductModel(
      id: id ?? this.id,
      categoryId: categoryId ?? this.categoryId,
      name: name ?? this.name,
      description: description ?? this.description,
      price: price ?? this.price,
      unit: unit ?? this.unit,
      maxQty: maxQty ?? this.maxQty,
      imageUrl: imageUrl ?? this.imageUrl,
      images: images ?? this.images,
      isActive: isActive ?? this.isActive,
      sortOrder: sortOrder ?? this.sortOrder,
    );
  }

  @override
  bool operator ==(Object other) => other is ProductModel && other.id == id;

  @override
  int get hashCode => id.hashCode;
}
