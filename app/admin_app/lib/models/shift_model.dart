import '../utils/json_date.dart';
import 'package:intl/intl.dart';

/// A "shift" is a delivery date for a group.
class ShiftModel {
  final String id;
  final String group; // Berlin | Hamburg
  final DateTime date;
  final String label; // e.g. "05.06"
  final bool isOpen;
  // How many days before the delivery date a customer may still cancel / edit.
  final int cancelDaysBefore;
  final int editDaysBefore;
  final DateTime? createdAt;

  ShiftModel({
    required this.id,
    required this.group,
    required this.date,
    required this.label,
    this.isOpen = true,
    this.cancelDaysBefore = 3,
    this.editDaysBefore = 4,
    this.createdAt,
  });

  static String labelFor(DateTime date) => DateFormat('dd.MM').format(date);

  factory ShiftModel.fromJson(Map<String, dynamic> json) {
    final date = parseDate(json['date']) ?? DateTime.now();
    return ShiftModel(
      id: json['id'] as String? ?? '',
      group: json['group'] as String? ?? '',
      date: date,
      label: (json['label'] as String?)?.isNotEmpty == true
          ? json['label'] as String
          : labelFor(date),
      isOpen: json['isOpen'] as bool? ?? false,
      cancelDaysBefore: (json['cancelDaysBefore'] as num?)?.toInt() ?? 3,
      editDaysBefore: (json['editDaysBefore'] as num?)?.toInt() ?? 4,
      createdAt: parseDate(json['createdAt']),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'group': group,
        'date': date.toIso8601String(),
        'label': label,
        'isOpen': isOpen,
        'cancelDaysBefore': cancelDaysBefore,
        'editDaysBefore': editDaysBefore,
        'createdAt': createdAt?.toIso8601String(),
      };

  ShiftModel copyWith({
    String? id,
    String? group,
    DateTime? date,
    String? label,
    bool? isOpen,
    int? cancelDaysBefore,
    int? editDaysBefore,
    DateTime? createdAt,
  }) {
    return ShiftModel(
      id: id ?? this.id,
      group: group ?? this.group,
      date: date ?? this.date,
      label: label ?? this.label,
      isOpen: isOpen ?? this.isOpen,
      cancelDaysBefore: cancelDaysBefore ?? this.cancelDaysBefore,
      editDaysBefore: editDaysBefore ?? this.editDaysBefore,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  bool operator ==(Object other) => other is ShiftModel && other.id == id;

  @override
  int get hashCode => id.hashCode;
}
