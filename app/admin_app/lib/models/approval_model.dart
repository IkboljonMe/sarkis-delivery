import 'package:cloud_firestore/cloud_firestore.dart';

/// A pending change a customer requested that needs admin review.
class ApprovalModel {
  final String id;
  final String type; // 'profile'
  final String userId;
  final String userName;
  final Map<String, dynamic> changes; // e.g. {name, phone}
  final String status; // pending | approved | rejected
  final DateTime? createdAt;

  ApprovalModel({
    required this.id,
    required this.type,
    required this.userId,
    required this.userName,
    required this.changes,
    required this.status,
    this.createdAt,
  });

  factory ApprovalModel.fromJson(Map<String, dynamic> json) {
    return ApprovalModel(
      id: json['id'] as String? ?? '',
      type: json['type'] as String? ?? 'profile',
      userId: json['userId'] as String? ?? '',
      userName: json['userName'] as String? ?? '',
      changes: (json['changes'] as Map?)?.cast<String, dynamic>() ?? const {},
      status: json['status'] as String? ?? 'pending',
      createdAt: json['createdAt'] is Timestamp
          ? (json['createdAt'] as Timestamp).toDate()
          : null,
    );
  }
}
