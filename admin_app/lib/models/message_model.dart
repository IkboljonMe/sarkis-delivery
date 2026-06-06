import 'package:cloud_firestore/cloud_firestore.dart';

/// A chat message inside a topic (topicId == userId).
class MessageModel {
  final String id;
  final String senderId;
  final String senderName;
  final String text;
  final bool isFromAdmin;
  final bool isRead;
  final DateTime? createdAt;

  MessageModel({
    required this.id,
    required this.senderId,
    this.senderName = '',
    required this.text,
    required this.isFromAdmin,
    this.isRead = false,
    this.createdAt,
  });

  factory MessageModel.fromJson(Map<String, dynamic> json) {
    return MessageModel(
      id: json['id'] as String? ?? '',
      senderId: json['senderId'] as String? ?? '',
      senderName: json['senderName'] as String? ?? '',
      text: json['text'] as String? ?? '',
      isFromAdmin: json['isFromAdmin'] as bool? ?? false,
      isRead: json['isRead'] as bool? ?? false,
      createdAt: json['createdAt'] is Timestamp
          ? (json['createdAt'] as Timestamp).toDate()
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'senderId': senderId,
        'senderName': senderName,
        'text': text,
        'isFromAdmin': isFromAdmin,
        'isRead': isRead,
        'createdAt': createdAt != null
            ? Timestamp.fromDate(createdAt!)
            : FieldValue.serverTimestamp(),
      };

  MessageModel copyWith({bool? isRead}) => MessageModel(
        id: id,
        senderId: senderId,
        senderName: senderName,
        text: text,
        isFromAdmin: isFromAdmin,
        isRead: isRead ?? this.isRead,
        createdAt: createdAt,
      );
}

/// Lightweight view of a chat topic for the admin chat list.
class ChatTopicModel {
  final String topicId; // == userId
  final String userName;
  final String userGroup;
  final String lastMessage;
  final DateTime? lastAt;
  final int unread;

  ChatTopicModel({
    required this.topicId,
    required this.userName,
    this.userGroup = '',
    this.lastMessage = '',
    this.lastAt,
    this.unread = 0,
  });
}
