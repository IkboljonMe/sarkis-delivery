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
  // Media: type is 'text' | 'image' | 'voice'.
  final String type;
  final String mediaUrl; // single (voice / legacy image)
  final List<String> mediaUrls; // album: multiple photos in one message
  final int durationMs; // voice length

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
    this.type = 'text',
    this.mediaUrl = '',
    this.mediaUrls = const [],
    this.durationMs = 0,
  });

  bool get hasReply => replyToId.isNotEmpty;
  bool get isImage => type == 'image';
  bool get isVoice => type == 'voice';
  bool get isVideo => type == 'video';

  /// All image urls for an image message (album-aware, legacy-compatible).
  List<String> get images => mediaUrls.isNotEmpty
      ? mediaUrls
      : (mediaUrl.isNotEmpty ? [mediaUrl] : const []);

  /// Short text for previews/notifications (label for media messages).
  String get previewText {
    if (text.trim().isNotEmpty) return text;
    if (isImage) return '📷 Фото';
    if (isVoice) return '🎤 Голосовое';
    if (isVideo) return '🎥 Видео';
    return '';
  }

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
      type: json['type'] as String? ?? 'text',
      mediaUrl: json['mediaUrl'] as String? ?? '',
      mediaUrls: (json['mediaUrls'] as List?)
              ?.map((e) => e.toString())
              .where((e) => e.isNotEmpty)
              .toList() ??
          const [],
      durationMs: (json['durationMs'] as num?)?.toInt() ?? 0,
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
        'type': type,
        'mediaUrl': mediaUrl,
        'mediaUrls': mediaUrls,
        'durationMs': durationMs,
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
        type: type,
        mediaUrl: mediaUrl,
        durationMs: durationMs,
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
