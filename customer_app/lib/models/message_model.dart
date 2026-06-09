import 'package:cloud_firestore/cloud_firestore.dart';

/// A chat message inside a topic (topicId == userId).
class MessageModel {
  final String id;
  final String senderId;
  final String senderName;
  final String text;
  final bool isFromAdmin;
  final bool isRead;
  final bool delivered; // recipient's device was notified (set server-side)
  final DateTime? createdAt;
  // Reply (quote) of another message.
  final String replyToId;
  final String replyToText;
  final String replyToSender;
  // Emoji reactions: userId -> emoji.
  final Map<String, String> reactions;
  // Media: type is 'text' | 'image' | 'voice' | 'order'.
  final String type;
  final String mediaUrl; // single (voice / legacy image)
  final List<String> mediaUrls; // album: multiple photos in one message
  final int durationMs; // voice length
  final String orderId; // attached order ('order' type) -> "View order" card
  final List<int> waveform; // voice amplitude bars (0-100), for the player UI
  final int sizeBytes; // media size, shown on voice bubbles
  final bool uploading; // media still uploading (optimistic send)
  final int uploadCount; // expected number of album photos while uploading

  MessageModel({
    required this.id,
    required this.senderId,
    this.senderName = '',
    required this.text,
    required this.isFromAdmin,
    this.isRead = false,
    this.delivered = false,
    this.createdAt,
    this.replyToId = '',
    this.replyToText = '',
    this.replyToSender = '',
    this.reactions = const {},
    this.type = 'text',
    this.mediaUrl = '',
    this.mediaUrls = const [],
    this.durationMs = 0,
    this.orderId = '',
    this.waveform = const [],
    this.sizeBytes = 0,
    this.uploading = false,
    this.uploadCount = 0,
  });

  bool get hasReply => replyToId.isNotEmpty;
  bool get isImage => type == 'image';
  bool get isVoice => type == 'voice';
  bool get isVideo => type == 'video';
  bool get isOrder => type == 'order';

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
    if (isOrder) return '📦 Заказ';
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
      delivered: json['delivered'] as bool? ?? false,
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
      orderId: json['orderId'] as String? ?? '',
      waveform: (json['waveform'] as List?)
              ?.map((e) => (e as num).toInt())
              .toList() ??
          const [],
      sizeBytes: (json['sizeBytes'] as num?)?.toInt() ?? 0,
      uploading: json['uploading'] as bool? ?? false,
      uploadCount: (json['uploadCount'] as num?)?.toInt() ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'senderId': senderId,
        'senderName': senderName,
        'text': text,
        'isFromAdmin': isFromAdmin,
        'isRead': isRead,
        'delivered': delivered,
        'replyToId': replyToId,
        'replyToText': replyToText,
        'replyToSender': replyToSender,
        'reactions': reactions,
        'type': type,
        'mediaUrl': mediaUrl,
        'mediaUrls': mediaUrls,
        'durationMs': durationMs,
        'orderId': orderId,
        'waveform': waveform,
        'sizeBytes': sizeBytes,
        'uploading': uploading,
        'uploadCount': uploadCount,
        'createdAt': createdAt != null
            ? Timestamp.fromDate(createdAt!)
            : FieldValue.serverTimestamp(),
      };

  MessageModel copyWith({bool? isRead, bool? delivered}) => MessageModel(
        id: id,
        senderId: senderId,
        senderName: senderName,
        text: text,
        isFromAdmin: isFromAdmin,
        isRead: isRead ?? this.isRead,
        delivered: delivered ?? this.delivered,
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
