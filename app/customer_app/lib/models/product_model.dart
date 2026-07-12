/// One product photo with a per-language title/caption. The first entry in a
/// product's [ProductModel.photos] is the main image.
class ProductPhoto {
  final String url;
  final Map<String, String> title; // {en, hy, ru, tr, de}

  const ProductPhoto({required this.url, this.title = const {}});

  String titleFor(String lang) {
    if (title[lang]?.isNotEmpty ?? false) return title[lang]!;
    if (title['en']?.isNotEmpty ?? false) return title['en']!;
    return title.values.firstWhere((v) => v.isNotEmpty, orElse: () => '');
  }

  factory ProductPhoto.fromJson(Map<String, dynamic> json) {
    final t = <String, String>{};
    final raw = json['title'];
    if (raw is Map) raw.forEach((k, v) => t[k.toString()] = v?.toString() ?? '');
    return ProductPhoto(url: json['url'] as String? ?? '', title: t);
  }

  Map<String, dynamic> toJson() => {'url': url, 'title': title};

  ProductPhoto copyWith({String? url, Map<String, String>? title}) =>
      ProductPhoto(url: url ?? this.url, title: title ?? this.title);
}

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
  final List<ProductPhoto> photos; // structured photos w/ per-language titles
  final bool isActive;
  final int sortOrder;
  final String discountType; // 'none' | 'percent' | 'fixed'
  final double discountValue; // percent (0-100) or fixed EUR amount

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
    this.photos = const [],
    this.isActive = true,
    this.sortOrder = 0,
    this.discountType = 'none',
    this.discountValue = 0,
  });

  /// Final price after any active discount (rounded to cents).
  double get discountedPrice {
    if (discountType == 'percent' && discountValue > 0) {
      final p = price * (1 - discountValue / 100);
      return (p.clamp(0, price) * 100).round() / 100;
    }
    if (discountType == 'fixed' && discountValue > 0) {
      return ((price - discountValue).clamp(0, price) * 100).round() / 100;
    }
    return price;
  }

  /// Whether an active discount actually lowers the price.
  bool get hasDiscount =>
      discountType != 'none' && discountValue > 0 && discountedPrice < price;

  /// Discount percentage label (rounded) for the customer "-N%" badge.
  int get discountPercentLabel =>
      price <= 0 ? 0 : (((price - discountedPrice) / price) * 100).round();

  /// All gallery images (falls back to imageUrl). De-duplicated, non-empty.
  List<String> get gallery {
    if (photos.isNotEmpty) {
      return photos
          .map((p) => p.url)
          .where((e) => e.isNotEmpty)
          .toSet()
          .toList();
    }
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
    final imageUrl = json['imageUrl'] as String? ?? '';
    final images = (json['images'] as List?)
            ?.map((e) => e.toString())
            .where((e) => e.isNotEmpty)
            .toList() ??
        const <String>[];
    // Prefer the structured photo list; fall back to migrating the legacy
    // imageUrl + images so existing products keep working.
    var photos = (json['photos'] as List?)
            ?.whereType<Map>()
            .map((e) => ProductPhoto.fromJson(Map<String, dynamic>.from(e)))
            .where((p) => p.url.isNotEmpty)
            .toList() ??
        const <ProductPhoto>[];
    if (photos.isEmpty) {
      photos = [
        if (imageUrl.isNotEmpty) ProductPhoto(url: imageUrl),
        for (final u in images) ProductPhoto(url: u),
      ];
    }
    return ProductModel(
      id: json['id'] as String? ?? '',
      categoryId: json['categoryId'] as String? ?? '',
      name: _parseMap(json['name']),
      description: _parseMap(json['description']),
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
      unit: json['unit'] as String? ?? 'piece',
      maxQty: (json['maxQty'] as num?)?.toInt() ?? 10,
      imageUrl: imageUrl,
      images: images,
      photos: photos,
      isActive: json['isActive'] as bool? ?? true,
      sortOrder: (json['sortOrder'] as num?)?.toInt() ?? 0,
      discountType: json['discountType'] as String? ?? 'none',
      discountValue: (json['discountValue'] as num?)?.toDouble() ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    // Keep the legacy imageUrl/images mirrored from photos so the customer app
    // (which reads them) stays in sync without any migration.
    final effectiveMain = photos.isNotEmpty ? photos.first.url : imageUrl;
    final effectiveImages = photos.isNotEmpty
        ? photos.skip(1).map((p) => p.url).where((u) => u.isNotEmpty).toList()
        : images;
    return {
        'id': id,
        'categoryId': categoryId,
        'name': name,
        'description': description,
        'price': price,
        'unit': unit,
        'maxQty': maxQty,
        'imageUrl': effectiveMain,
        'images': effectiveImages,
        'photos': photos.map((p) => p.toJson()).toList(),
        'isActive': isActive,
        'sortOrder': sortOrder,
        'discountType': discountType,
        'discountValue': discountValue,
      };
  }

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
    List<ProductPhoto>? photos,
    bool? isActive,
    int? sortOrder,
    String? discountType,
    double? discountValue,
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
      photos: photos ?? this.photos,
      isActive: isActive ?? this.isActive,
      sortOrder: sortOrder ?? this.sortOrder,
      discountType: discountType ?? this.discountType,
      discountValue: discountValue ?? this.discountValue,
    );
  }

  @override
  bool operator ==(Object other) => other is ProductModel && other.id == id;

  @override
  int get hashCode => id.hashCode;
}
