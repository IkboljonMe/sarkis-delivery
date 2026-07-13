import 'dart:typed_data';

import '../models/message_model.dart';
import 'api_client.dart';

/// Customer↔admin chat backed by the REST API (polling; topicId == userId).
class MessageService {
  MessageService._();
  static final MessageService instance = MessageService._();

  final ApiClient _api = ApiClient.instance;

  List<MessageModel> _parse(dynamic res) => (res as List)
      .map((e) => MessageModel.fromJson(Map<String, dynamic>.from(e as Map)))
      .toList();

  /// Uploads chat media and returns its public URL.
  Future<String> uploadChatMedia(
    String topicId,
    Uint8List bytes, {
    required String ext,
    required String contentType,
  }) {
    return _api.uploadBytes('/v1/uploads/chat', bytes, filename: 'media.$ext');
  }

  /// Uploads a media file by path (large videos/voice notes).
  Future<String> uploadChatFile(
    String topicId,
    String path, {
    required String ext,
    required String contentType,
  }) {
    return _api.uploadFilePath('/v1/uploads/chat', path);
  }

  /// Soft-deletes a message ("message deleted" placeholder for both sides).
  Future<void> deleteMessage(String topicId, String msgId) async {
    try {
      await _api.delete('/v1/messages/$topicId/$msgId');
    } catch (_) {}
  }

  Stream<List<MessageModel>> messagesStream(String topicId) =>
      ApiClient.poll(const Duration(seconds: 3),
          () async => _parse(await _api.get('/v1/messages/$topicId')));

  Future<String> sendMessage({
    required String topicId,
    required String text,
    required String senderId,
    required String senderName,
    required bool isFromAdmin,
    String replyToId = '',
    String replyToText = '',
    String replyToSender = '',
    String type = 'text',
    String mediaUrl = '',
    List<String> mediaUrls = const [],
    int durationMs = 0,
    String orderId = '',
    List<int> waveform = const [],
    int sizeBytes = 0,
    bool uploading = false,
    int uploadCount = 0,
  }) async {
    final res = await _api.post('/v1/messages/$topicId', {
      'type': type,
      'text': text,
      if (replyToId.isNotEmpty) 'replyToId': replyToId,
      if (replyToText.isNotEmpty) 'replyToText': replyToText,
      if (replyToSender.isNotEmpty) 'replyToSender': replyToSender,
      if (mediaUrl.isNotEmpty) 'mediaUrl': mediaUrl,
      if (mediaUrls.isNotEmpty) 'mediaUrls': mediaUrls,
      if (durationMs > 0) 'durationMs': durationMs,
      if (orderId.isNotEmpty) 'orderId': orderId,
      if (waveform.isNotEmpty) 'waveform': waveform,
      if (sizeBytes > 0) 'sizeBytes': sizeBytes,
      if (uploadCount > 0) 'uploadCount': uploadCount,
    });
    return (res as Map)['id'] as String;
  }

  /// Patches fields of an existing message (fills media URLs after an
  /// optimistic upload completes).
  Future<void> patchMessage(
      String topicId, String msgId, Map<String, dynamic> data) async {
    try {
      await _api.patch('/v1/messages/$topicId/$msgId', data);
    } catch (_) {}
  }

  /// Appends one uploaded photo URL to an album message (optimistic send).
  Future<void> appendMediaUrl(String topicId, String msgId, String url) async {
    try {
      await _api.patch('/v1/messages/$topicId/$msgId', {'appendMediaUrl': url});
    } catch (_) {}
  }

  /// Toggles an emoji reaction on a message ([userId] is implied by auth).
  Future<void> toggleReaction(
      String topicId, String msgId, String userId, String emoji) async {
    try {
      await _api.post('/v1/messages/$topicId/$msgId/reactions', {'emoji': emoji});
    } catch (_) {}
  }

  /// Marks messages from the other party as read.
  Future<void> markRead(String topicId, {required bool readingAsAdmin}) async {
    try {
      await _api.post('/v1/messages/$topicId/read', {'asAdmin': readingAsAdmin});
    } catch (_) {}
  }

  /// Unread count for the customer (admin messages not yet read).
  Stream<int> customerUnreadStream(String topicId) =>
      ApiClient.poll(const Duration(seconds: 6), () async {
        final res = await _api.get('/v1/messages/unread');
        return ((res as Map)['unread'] as num?)?.toInt() ?? 0;
      });

  /// All topics (admin chat list).
  Stream<List<ChatTopicModel>> topicsStream() =>
      ApiClient.poll(const Duration(seconds: 5), () async {
        final res = await _api.get('/v1/messages/topics');
        return (res as List)
            .map((e) =>
                ChatTopicModel.fromJson(Map<String, dynamic>.from(e as Map)))
            .toList();
      });

  /// Asks the backend to post the one-time welcome message (no-op if the
  /// topic already has messages).
  Future<void> sendWelcomeIfNew({
    required String topicId,
    required String userName,
    required String userGroup,
    required String text,
    required String adminUid,
    required String senderName,
  }) async {
    try {
      await _api.post('/v1/messages/$topicId/welcome',
          {'text': text, 'senderName': senderName});
    } catch (_) {}
  }

  /// Topics are created server-side on first access; kept for compatibility.
  Future<void> ensureTopic({
    required String topicId,
    required String userName,
    required String userGroup,
  }) async {
    try {
      await _api.get('/v1/messages/topics/$topicId');
    } catch (_) {}
  }
}
