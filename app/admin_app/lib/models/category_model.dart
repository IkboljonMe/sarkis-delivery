class CategoryModel {
  final String id;
  final Map<String, String> name; // {en, hy, ru, tr, de}
  final String imageUrl;
  final int sortOrder;
  final bool isActive;

  CategoryModel({
    required this.id,
    required this.name,
    this.imageUrl = '',
    this.sortOrder = 0,
    this.isActive = true,
  });

  String nameFor(String lang) {
    if (name[lang]?.isNotEmpty ?? false) return name[lang]!;
    if (name['en']?.isNotEmpty ?? false) return name['en']!;
    return name.values.isNotEmpty ? name.values.first : '';
  }

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    final raw = json['name'];
    final parsed = <String, String>{};
    if (raw is Map) {
      raw.forEach((k, v) => parsed[k.toString()] = v?.toString() ?? '');
    }
    return CategoryModel(
      id: json['id'] as String? ?? '',
      name: parsed,
      imageUrl: json['imageUrl'] as String? ?? '',
      sortOrder: (json['sortOrder'] as num?)?.toInt() ?? 0,
      isActive: json['isActive'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'imageUrl': imageUrl,
        'sortOrder': sortOrder,
        'isActive': isActive,
      };

  CategoryModel copyWith({
    String? id,
    Map<String, String>? name,
    String? imageUrl,
    int? sortOrder,
    bool? isActive,
  }) {
    return CategoryModel(
      id: id ?? this.id,
      name: name ?? this.name,
      imageUrl: imageUrl ?? this.imageUrl,
      sortOrder: sortOrder ?? this.sortOrder,
      isActive: isActive ?? this.isActive,
    );
  }

  @override
  bool operator ==(Object other) => other is CategoryModel && other.id == id;

  @override
  int get hashCode => id.hashCode;
}
