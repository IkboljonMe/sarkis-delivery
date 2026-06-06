import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

/// A "shift" is a delivery date for a group.
class ShiftModel {
  final String id;
  final String group; // Berlin | Hamburg
  final DateTime date;
  final String label; // e.g. "05.06"
  final bool isOpen;
  final DateTime? createdAt;

  ShiftModel({
    required this.id,
    required this.group,
    required this.date,
    required this.label,
    this.isOpen = true,
    this.createdAt,
  });

  static String labelFor(DateTime date) => DateFormat('dd.MM').format(date);

  factory ShiftModel.fromJson(Map<String, dynamic> json) {
    final date = json['date'] is Timestamp
        ? (json['date'] as Timestamp).toDate()
        : DateTime.now();
    return ShiftModel(
      id: json['id'] as String? ?? '',
      group: json['group'] as String? ?? '',
      date: date,
      label: (json['label'] as String?)?.isNotEmpty == true
          ? json['label'] as String
          : labelFor(date),
      isOpen: json['isOpen'] as bool? ?? false,
      createdAt: json['createdAt'] is Timestamp
          ? (json['createdAt'] as Timestamp).toDate()
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'group': group,
        'date': Timestamp.fromDate(date),
        'label': label,
        'isOpen': isOpen,
        'createdAt': createdAt != null
            ? Timestamp.fromDate(createdAt!)
            : FieldValue.serverTimestamp(),
      };

  ShiftModel copyWith({
    String? id,
    String? group,
    DateTime? date,
    String? label,
    bool? isOpen,
    DateTime? createdAt,
  }) {
    return ShiftModel(
      id: id ?? this.id,
      group: group ?? this.group,
      date: date ?? this.date,
      label: label ?? this.label,
      isOpen: isOpen ?? this.isOpen,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  bool operator ==(Object other) => other is ShiftModel && other.id == id;

  @override
  int get hashCode => id.hashCode;
}
