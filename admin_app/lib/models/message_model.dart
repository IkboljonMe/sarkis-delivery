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
  // Reply (quote) of another message.
  final String replyToId;
  final String replyToText;
  final String replyToSender;
  // Emoji reactions: userId -> emoji.
  final Map<String, String> reactions;

  MessageModel({
    required this.id,
    required this.senderId,
    this.senderName = '',
    required this.text,
    required this.isFromAdmin,
    this.isRead = false,
    this.createdAt,
    this.replyToId = '',
    this.replyToText = '',
    this.replyToSender = '',
    this.reactions = const {},
  });

  bool get hasReply => replyToId.isNotEmpty;

  /// Reactions grouped to emoji -> count, for display.
  Map<String, int> get reactionCounts {
    final m = <String, int>{};
    for (final e in reactions.values) {
      if (e.isEmpty) continue;
      m[e] = (m[e] ?? 0) + 1;
    }
    return m;
  }

  static Map<String, String> _parseReactions(dynamic raw) {
    final m = <String, String>{};
    if (raw is Map) {
      raw.forEach((k, v) => m[k.toString()] = v?.toString() ?? '');
    }
    return m;
  }

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
      replyToId: json['replyToId'] as String? ?? '',
      replyToText: json['replyToText'] as String? ?? '',
      replyToSender: json['replyToSender'] as String? ?? '',
      reactions: _parseReactions(json['reactions']),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'senderId': senderId,
        'senderName': senderName,
        'text': text,
        'isFromAdmin': isFromAdmin,
        'isRead': isRead,
        'replyToId': replyToId,
        'replyToText': replyToText,
        'replyToSender': replyToSender,
        'reactions': reactions,
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
        replyToId: replyToId,
        replyToText: replyToText,
        replyToSender: replyToSender,
        reactions: reactions,
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
