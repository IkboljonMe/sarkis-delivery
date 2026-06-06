import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String id;
  final String name;
  final String phone;
  final String address;
  final String city;
  final String postalCode;
  final String group; // Berlin | Hamburg
  final String language; // en | hy | ru | tr | de
  final String fcmToken;
  final bool isAdmin;
  final DateTime? createdAt;

  UserModel({
    required this.id,
    required this.name,
    required this.phone,
    required this.address,
    required this.city,
    required this.postalCode,
    required this.group,
    required this.language,
    this.fcmToken = '',
    this.isAdmin = false,
    this.createdAt,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      phone: json['phone'] as String? ?? '',
      address: json['address'] as String? ?? '',
      city: json['city'] as String? ?? '',
      postalCode: json['postalCode'] as String? ?? '',
      group: json['group'] as String? ?? '',
      language: json['language'] as String? ?? 'en',
      fcmToken: json['fcmToken'] as String? ?? '',
      isAdmin: json['isAdmin'] as bool? ?? false,
      createdAt: json['createdAt'] is Timestamp
          ? (json['createdAt'] as Timestamp).toDate()
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'phone': phone,
      'address': address,
      'city': city,
      'postalCode': postalCode,
      'group': group,
      'language': language,
      'fcmToken': fcmToken,
      'isAdmin': isAdmin,
      'createdAt': createdAt != null
          ? Timestamp.fromDate(createdAt!)
          : FieldValue.serverTimestamp(),
    };
  }

  UserModel copyWith({
    String? id,
    String? name,
    String? phone,
    String? address,
    String? city,
    String? postalCode,
    String? group,
    String? language,
    String? fcmToken,
    bool? isAdmin,
    DateTime? createdAt,
  }) {
    return UserModel(
      id: id ?? this.id,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      address: address ?? this.address,
      city: city ?? this.city,
      postalCode: postalCode ?? this.postalCode,
      group: group ?? this.group,
      language: language ?? this.language,
      fcmToken: fcmToken ?? this.fcmToken,
      isAdmin: isAdmin ?? this.isAdmin,
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
