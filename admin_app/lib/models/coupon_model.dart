import 'package:cloud_firestore/cloud_firestore.dart';

/// A discount coupon a customer can redeem at checkout. The document id is the
/// normalized (uppercased) code, so a customer can fetch one by code without
/// being able to list every coupon.
class CouponModel {
  final String id; // == normalized code
  final String code;
  final String type; // 'percent' | 'fixed'
  final double value; // percent (0-100) or fixed EUR amount
  final double minOrder; // minimum order subtotal (0 = none)
  final bool isActive;
  final DateTime? expiresAt;
  final int usageLimit; // total redemptions allowed (0 = unlimited)
  final int usedCount;
  final DateTime? createdAt;

  CouponModel({
    required this.id,
    required this.code,
    this.type = 'percent',
    this.value = 0,
    this.minOrder = 0,
    this.isActive = true,
    this.expiresAt,
    this.usageLimit = 0,
    this.usedCount = 0,
    this.createdAt,
  });

  static String normalize(String code) =>
      code.trim().toUpperCase().replaceAll(RegExp(r'\s+'), '');

  /// Discount amount this coupon yields for a given order subtotal.
  double discountFor(double subtotal) {
    if (value <= 0) return 0;
    final raw = type == 'percent' ? subtotal * value / 100 : value;
    final capped = raw > subtotal ? subtotal : raw;
    return (capped * 100).round() / 100;
  }

  bool get exhausted => usageLimit > 0 && usedCount >= usageLimit;

  bool isExpired(DateTime now) => expiresAt != null && now.isAfter(expiresAt!);

  /// Returns a problem key if the coupon can't be used, else null.
  String? validate(double subtotal, DateTime now) {
    if (!isActive) return 'couponInactive';
    if (isExpired(now)) return 'couponExpired';
    if (exhausted) return 'couponExhausted';
    if (minOrder > 0 && subtotal < minOrder) return 'couponMinOrder';
    return null;
  }

  factory CouponModel.fromJson(Map<String, dynamic> json) {
    return CouponModel(
      id: json['id'] as String? ?? '',
      code: json['code'] as String? ?? '',
      type: json['type'] as String? ?? 'percent',
      value: (json['value'] as num?)?.toDouble() ?? 0,
      minOrder: (json['minOrder'] as num?)?.toDouble() ?? 0,
      isActive: json['isActive'] as bool? ?? true,
      expiresAt: json['expiresAt'] is Timestamp
          ? (json['expiresAt'] as Timestamp).toDate()
          : null,
      usageLimit: (json['usageLimit'] as num?)?.toInt() ?? 0,
      usedCount: (json['usedCount'] as num?)?.toInt() ?? 0,
      createdAt: json['createdAt'] is Timestamp
          ? (json['createdAt'] as Timestamp).toDate()
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'code': code,
        'type': type,
        'value': value,
        'minOrder': minOrder,
        'isActive': isActive,
        'expiresAt': expiresAt != null ? Timestamp.fromDate(expiresAt!) : null,
        'usageLimit': usageLimit,
        'usedCount': usedCount,
        'createdAt': createdAt != null
            ? Timestamp.fromDate(createdAt!)
            : FieldValue.serverTimestamp(),
      };

  CouponModel copyWith({
    String? id,
    String? code,
    String? type,
    double? value,
    double? minOrder,
    bool? isActive,
    DateTime? expiresAt,
    int? usageLimit,
    int? usedCount,
    DateTime? createdAt,
  }) {
    return CouponModel(
      id: id ?? this.id,
      code: code ?? this.code,
      type: type ?? this.type,
      value: value ?? this.value,
      minOrder: minOrder ?? this.minOrder,
      isActive: isActive ?? this.isActive,
      expiresAt: expiresAt ?? this.expiresAt,
      usageLimit: usageLimit ?? this.usageLimit,
      usedCount: usedCount ?? this.usedCount,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
