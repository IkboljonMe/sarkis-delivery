import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String id;
  final String name;
  final String lastName;
  final String phone;
  final String address;
  final String city;
  final String postalCode;
  final String group; // Berlin | Hamburg | Frankfurt | München
  final double? lat;
  final double? lng;
  final String language; // en | hy | ru | tr | de
  final String fcmToken;
  final String photoUrl;
  final bool isAdmin;
  final bool isVerified;
  final String referredBy; // optional: who referred this customer
  final DateTime? createdAt;

  UserModel({
    required this.id,
    required this.name,
    this.lastName = '',
    required this.phone,
    required this.address,
    required this.city,
    required this.postalCode,
    required this.group,
    this.lat,
    this.lng,
    required this.language,
    this.fcmToken = '',
    this.photoUrl = '',
    this.isAdmin = false,
    this.isVerified = false,
    this.referredBy = '',
    this.createdAt,
  });

  /// Full display name ("First Last"), trimmed.
  String get fullName => '$name $lastName'.trim();

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      lastName: json['lastName'] as String? ?? '',
      phone: json['phone'] as String? ?? '',
      address: json['address'] as String? ?? '',
      city: json['city'] as String? ?? '',
      postalCode: json['postalCode'] as String? ?? '',
      group: json['group'] as String? ?? '',
      lat: (json['lat'] as num?)?.toDouble(),
      lng: (json['lng'] as num?)?.toDouble(),
      language: json['language'] as String? ?? 'en',
      fcmToken: json['fcmToken'] as String? ?? '',
      photoUrl: json['photoUrl'] as String? ?? '',
      isAdmin: json['isAdmin'] as bool? ?? false,
      isVerified: json['isVerified'] as bool? ?? false,
      referredBy: json['referredBy'] as String? ?? '',
      createdAt: json['createdAt'] is Timestamp
          ? (json['createdAt'] as Timestamp).toDate()
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'lastName': lastName,
      'phone': phone,
      'address': address,
      'city': city,
      'postalCode': postalCode,
      'group': group,
      'lat': lat,
      'lng': lng,
      'language': language,
      'fcmToken': fcmToken,
      'photoUrl': photoUrl,
      'isAdmin': isAdmin,
      'isVerified': isVerified,
      'referredBy': referredBy,
      'createdAt': createdAt != null
          ? Timestamp.fromDate(createdAt!)
          : FieldValue.serverTimestamp(),
    };
  }

  UserModel copyWith({
    String? id,
    String? name,
    String? lastName,
    String? phone,
    String? address,
    String? city,
    String? postalCode,
    String? group,
    double? lat,
    double? lng,
    String? language,
    String? fcmToken,
    String? photoUrl,
    bool? isAdmin,
    bool? isVerified,
    String? referredBy,
    DateTime? createdAt,
  }) {
    return UserModel(
      id: id ?? this.id,
      name: name ?? this.name,
      lastName: lastName ?? this.lastName,
      phone: phone ?? this.phone,
      address: address ?? this.address,
      city: city ?? this.city,
      postalCode: postalCode ?? this.postalCode,
      group: group ?? this.group,
      lat: lat ?? this.lat,
      lng: lng ?? this.lng,
      language: language ?? this.language,
      fcmToken: fcmToken ?? this.fcmToken,
      photoUrl: photoUrl ?? this.photoUrl,
      isAdmin: isAdmin ?? this.isAdmin,
      isVerified: isVerified ?? this.isVerified,
      referredBy: referredBy ?? this.referredBy,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  bool operator ==(Object other) =>
      other is UserModel && other.id == id && other.name == name &&
      other.address == address && other.group == group &&
      other.language == language;

  @override
  int get hashCode => Object.hash(id, name, address, group, language);
}
