
import 'package:flutter/foundation.dart';

import '../models/message_model.dart';
import '../realtime/socket_service.dart';
import '../services/message_service.dart';
import '../sync/sync_engine.dart';

class MessageProvider extends ChangeNotifier {
  final MessageService _service = MessageService.instance;

  Stream<List<MessageModel>> messagesStream(String topicId) =>
      _service.messagesStream(topicId);

  /// Called when a chat screen opens: join its realtime room and pull the
  /// latest messages so the screen recovers history on its own, independent of
  /// whether the login-time sync succeeded. Throws on pull failure so the UI
  /// can show a retry affordance.
  Future<void> openChat(String topicId) async {
    SocketService.instance.joinChat(topicId);
    await SyncEngine.instance.syncMessages(topicId);
  }

  /// Called when a chat screen closes: leave its realtime room.
  void closeChat(String topicId) => SocketService.instance.leaveChat(topicId);

  Stream<int> unreadStream(String topicId) =>
      _service.customerUnreadStream(topicId);

  Future<String> send({
    required String topicId,
    required String text,
    required String senderId,
    required String senderName,
    required bool isFromAdmin,
    String userGroup = '',
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
    await _service.ensureTopic(
        topicId: topicId, userName: senderName, userGroup: userGroup);
    return _service.sendMessage(
      topicId: topicId,
      text: text,
      senderId: senderId,
      senderName: senderName,
      isFromAdmin: isFromAdmin,
      replyToId: replyToId,
      replyToText: replyToText,
      replyToSender: replyToSender,
      type: type,
      mediaUrl: mediaUrl,
      mediaUrls: mediaUrls,
      durationMs: durationMs,
      orderId: orderId,
      waveform: waveform,
      sizeBytes: sizeBytes,
      uploading: uploading,
      uploadCount: uploadCount,
    );
  }

  Future<void> resendMessage(String topicId, String localId) =>
      _service.resendMessage(topicId, localId);

  Future<void> patchMessage(
          String topicId, String msgId, Map<String, dynamic> data) =>
      _service.patchMessage(topicId, msgId, data);

  Future<void> appendMediaUrl(String topicId, String msgId, String url) =>
      _service.appendMediaUrl(topicId, msgId, url);

  Future<String> uploadChatFile(String topicId, String path,
          {required String ext, required String contentType}) =>
      _service.uploadChatFile(topicId, path, ext: ext, contentType: contentType);

  Future<void> deleteMessage(String topicId, String msgId) =>
      _service.deleteMessage(topicId, msgId);

  Future<String> uploadChatMedia(String topicId, Uint8List bytes,
          {required String ext, required String contentType}) =>
      _service.uploadChatMedia(topicId, bytes,
          ext: ext, contentType: contentType);

  Future<void> toggleReaction(
          String topicId, String msgId, String userId, String emoji) =>
      _service.toggleReaction(topicId, msgId, userId, emoji);

  Future<void> markRead(String topicId, {required bool readingAsAdmin}) =>
      _service.markRead(topicId, readingAsAdmin: readingAsAdmin);
}
