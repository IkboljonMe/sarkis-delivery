import 'package:cloud_firestore/cloud_firestore.dart';

class MessageModel {
  final String id;
  final String text;
  final bool fromAdmin;
  final DateTime? createdAt;
  final bool isRead;

  MessageModel({
    required this.id,
    required this.text,
    required this.fromAdmin,
    this.createdAt,
    this.isRead = false,
  });

  factory MessageModel.fromJson(Map<String, dynamic> json) {
    return MessageModel(
      id: json['id'] as String? ?? '',
      text: json['text'] as String? ?? '',
      fromAdmin: json['fromAdmin'] as bool? ?? false,
      createdAt: json['createdAt'] is Timestamp
          ? (json['createdAt'] as Timestamp).toDate()
          : null,
      isRead: json['isRead'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'text': text,
      'fromAdmin': fromAdmin,
      'createdAt': createdAt != null
          ? Timestamp.fromDate(createdAt!)
          : FieldValue.serverTimestamp(),
      'isRead': isRead,
    };
  }

  MessageModel copyWith({
    String? id,
    String? text,
    bool? fromAdmin,
    DateTime? createdAt,
    bool? isRead,
  }) {
    return MessageModel(
      id: id ?? this.id,
      text: text ?? this.text,
      fromAdmin: fromAdmin ?? this.fromAdmin,
      createdAt: createdAt ?? this.createdAt,
      isRead: isRead ?? this.isRead,
    );
  }
}
