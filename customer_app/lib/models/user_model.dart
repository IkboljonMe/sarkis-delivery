import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String id;
  final String phone;
  final String name;
  final String address;
  final String city;
  final String postalCode;
  final String group; // Berlin | Hamburg
  final String language; // en | hy | ru | tr | de
  final String fcmToken;
  final DateTime? createdAt;

  UserModel({
    required this.id,
    required this.phone,
    required this.name,
    required this.address,
    required this.city,
    required this.postalCode,
    required this.group,
    required this.language,
    required this.fcmToken,
    this.createdAt,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String? ?? '',
      phone: json['phone'] as String? ?? '',
      name: json['name'] as String? ?? '',
      address: json['address'] as String? ?? '',
      city: json['city'] as String? ?? '',
      postalCode: json['postalCode'] as String? ?? '',
      group: json['group'] as String? ?? '',
      language: json['language'] as String? ?? 'en',
      fcmToken: json['fcmToken'] as String? ?? '',
      createdAt: json['createdAt'] is Timestamp
          ? (json['createdAt'] as Timestamp).toDate()
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'phone': phone,
      'name': name,
      'address': address,
      'city': city,
      'postalCode': postalCode,
      'group': group,
      'language': language,
      'fcmToken': fcmToken,
      'createdAt': createdAt != null
          ? Timestamp.fromDate(createdAt!)
          : FieldValue.serverTimestamp(),
    };
  }

  UserModel copyWith({
    String? id,
    String? phone,
    String? name,
    String? address,
    String? city,
    String? postalCode,
    String? group,
    String? language,
    String? fcmToken,
    DateTime? createdAt,
  }) {
    return UserModel(
      id: id ?? this.id,
      phone: phone ?? this.phone,
      name: name ?? this.name,
      address: address ?? this.address,
      city: city ?? this.city,
      postalCode: postalCode ?? this.postalCode,
      group: group ?? this.group,
      language: language ?? this.language,
      fcmToken: fcmToken ?? this.fcmToken,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
