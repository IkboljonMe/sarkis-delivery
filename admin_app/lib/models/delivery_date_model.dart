import 'package:cloud_firestore/cloud_firestore.dart';

class DeliveryDateModel {
  final String id;
  final DateTime date;
  final String group; // Berlin | Hamburg
  final bool isOpen;
  final DateTime? createdAt;

  DeliveryDateModel({
    required this.id,
    required this.date,
    required this.group,
    required this.isOpen,
    this.createdAt,
  });

  factory DeliveryDateModel.fromJson(Map<String, dynamic> json) {
    return DeliveryDateModel(
      id: json['id'] as String? ?? '',
      date: json['date'] is Timestamp
          ? (json['date'] as Timestamp).toDate()
          : DateTime.now(),
      group: json['group'] as String? ?? '',
      isOpen: json['isOpen'] as bool? ?? false,
      createdAt: json['createdAt'] is Timestamp
          ? (json['createdAt'] as Timestamp).toDate()
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'date': Timestamp.fromDate(date),
      'group': group,
      'isOpen': isOpen,
      'createdAt': createdAt != null
          ? Timestamp.fromDate(createdAt!)
          : FieldValue.serverTimestamp(),
    };
  }

  DeliveryDateModel copyWith({
    String? id,
    DateTime? date,
    String? group,
    bool? isOpen,
    DateTime? createdAt,
  }) {
    return DeliveryDateModel(
      id: id ?? this.id,
      date: date ?? this.date,
      group: group ?? this.group,
      isOpen: isOpen ?? this.isOpen,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
