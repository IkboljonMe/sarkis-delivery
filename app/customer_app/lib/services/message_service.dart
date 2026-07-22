import 'dart:convert';
import 'dart:typed_data';

import 'package:drift/drift.dart' as drift;

import '../local_db/app_database.dart';
import '../models/message_model.dart';
import '../sync/mutation_queue.dart';
import 'api_client.dart';

/// Customer↔admin chat backed by the offline-first sync engine.
class MessageService {
  MessageService._();
  static final MessageService instance = MessageService._();

  final ApiClient _api = ApiClient.instance;

  Future<String> uploadChatMedia(
    String topicId,
    Uint8List bytes, {
    required String ext,
    required String contentType,
  }) {
    return _api.uploadBytes('/v1/uploads/chat', bytes, filename: 'media.$ext');
  }

  Future<String> uploadChatFile(
    String topicId,
    String path, {
    required String ext,
    required String contentType,
  }) {
    return _api.uploadFilePath('/v1/uploads/chat', path);
  }

  Future<void> deleteMessage(String topicId, String msgId) async {
    final db = AppDatabase.instance;
    await (db.update(db.messages)..where((t) => t.id.equals(msgId))).write(const MessagesCompanion(
      deleted: drift.Value(true),
      textContent: drift.Value(''),
    ));

    await MutationQueue.instance.run(
      entityType: 'message',
      method: 'DELETE',
      path: '/v1/messages/$topicId/$msgId',
    );
  }

  Stream<List<MessageModel>> messagesStream(String topicId) {
    final db = AppDatabase.instance;
    return (db.select(db.messages)
          ..where((t) => t.topicId.equals(topicId))
          // Ascending: index 0 is the oldest, last index is the newest — the
          // chat list and all its scroll math treat the last item as the
          // bottom/newest message.
          ..orderBy([(t) => drift.OrderingTerm.asc(t.createdAt)]))
        .watch()
        .map((rows) => rows.map((r) {
              return MessageModel(
                id: r.id,
                senderId: r.senderId,
                senderName: r.senderName,
                isFromAdmin: r.isFromAdmin,
                type: r.type,
                text: r.textContent ?? '',
                createdAt: r.createdAt,
                replyToId: r.replyToId,
                replyToText: r.replyToText,
                replyToSender: r.replyToSender,
                mediaUrl: r.mediaUrl ?? '',
                mediaUrls: r.mediaUrlsJson != null && r.mediaUrlsJson!.isNotEmpty
                    ? (jsonDecode(r.mediaUrlsJson!) as List).map((e) => e.toString()).toList()
                    : const [],
                durationMs: r.durationMs,
                orderId: r.orderId,
                waveform: r.waveformJson != null && r.waveformJson!.isNotEmpty
                    ? (jsonDecode(r.waveformJson!) as List).map((e) => (e as num).toInt()).toList()
                    : const [],
                sizeBytes: r.sizeBytes,
                uploading: r.uploading,
                uploadCount: r.uploadCount,
                reactions: r.reactionsJson != null && r.reactionsJson!.isNotEmpty
                    ? Map<String, String>.from(jsonDecode(r.reactionsJson!))
                    : const {},
                isRead: r.isRead,
                deleted: r.deleted,
                pendingSync: r.pendingSync,
                sendFailed: r.sendFailed,
              );
            }).toList());
  }

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
    final localId = 'local_${DateTime.now().millisecondsSinceEpoch}';
    final db = AppDatabase.instance;

    await db.into(db.messages).insert(MessagesCompanion.insert(
          id: localId,
          topicId: topicId,
          senderId: senderId,
          senderName: senderName,
          isFromAdmin: isFromAdmin,
          type: type,
          textContent: drift.Value(text),
          createdAt: DateTime.now(),
          replyToId: drift.Value(replyToId),
          replyToText: drift.Value(replyToText),
          replyToSender: drift.Value(replyToSender),
          mediaUrl: drift.Value(mediaUrl),
          mediaUrlsJson: drift.Value(mediaUrls.isNotEmpty ? jsonEncode(mediaUrls) : null),
          durationMs: drift.Value(durationMs),
          orderId: drift.Value(orderId),
          waveformJson: drift.Value(waveform.isNotEmpty ? jsonEncode(waveform) : null),
          sizeBytes: drift.Value(sizeBytes),
          uploading: drift.Value(uploading),
          uploadCount: drift.Value(uploadCount),
          isRead: const drift.Value(true),
          pendingSync: const drift.Value(true),
        ));

    final body = {
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
    };
    return _dispatchSend(topicId, localId, body);
  }

  /// POSTs an optimistic message. On success the local row is dropped (the
  /// server echo replaces it); on a connectivity failure it stays queued and
  /// `pendingSync` (shows "sending"); on a real server rejection it's flagged
  /// `sendFailed` so the bubble can offer a retry.
  Future<String> _dispatchSend(
      String topicId, String localId, Map<String, dynamic> body) async {
    final db = AppDatabase.instance;
    try {
      final res = await MutationQueue.instance.run(
        entityType: 'message',
        method: 'POST',
        path: '/v1/messages/$topicId',
        body: body,
        localRefId: localId,
      );
      if (res != null) {
        await (db.delete(db.messages)..where((t) => t.id.equals(localId))).go();
        return (res as Map)['id'] as String;
      }
      return localId; // queued offline — stays pendingSync
    } on ApiException catch (e) {
      if (e.statusCode != 0) {
        await (db.update(db.messages)..where((t) => t.id.equals(localId)))
            .write(const MessagesCompanion(
          sendFailed: drift.Value(true),
          pendingSync: drift.Value(false),
        ));
      }
      return localId;
    }
  }

  /// Re-attempts a previously failed optimistic message (tap-to-retry).
  Future<void> resendMessage(String topicId, String localId) async {
    final db = AppDatabase.instance;
    final r = await (db.select(db.messages)..where((t) => t.id.equals(localId)))
        .getSingleOrNull();
    if (r == null) return;
    await (db.update(db.messages)..where((t) => t.id.equals(localId)))
        .write(const MessagesCompanion(
      sendFailed: drift.Value(false),
      pendingSync: drift.Value(true),
    ));
    final mediaUrls = r.mediaUrlsJson != null && r.mediaUrlsJson!.isNotEmpty
        ? (jsonDecode(r.mediaUrlsJson!) as List).map((e) => e.toString()).toList()
        : const <String>[];
    final waveform = r.waveformJson != null && r.waveformJson!.isNotEmpty
        ? (jsonDecode(r.waveformJson!) as List).map((e) => (e as num).toInt()).toList()
        : const <int>[];
    final body = {
      'type': r.type,
      'text': r.textContent ?? '',
      if (r.replyToId.isNotEmpty) 'replyToId': r.replyToId,
      if (r.replyToText.isNotEmpty) 'replyToText': r.replyToText,
      if (r.replyToSender.isNotEmpty) 'replyToSender': r.replyToSender,
      if ((r.mediaUrl ?? '').isNotEmpty) 'mediaUrl': r.mediaUrl,
      if (mediaUrls.isNotEmpty) 'mediaUrls': mediaUrls,
      if (r.durationMs > 0) 'durationMs': r.durationMs,
      if (r.orderId.isNotEmpty) 'orderId': r.orderId,
      if (waveform.isNotEmpty) 'waveform': waveform,
      if (r.sizeBytes > 0) 'sizeBytes': r.sizeBytes,
      if (r.uploadCount > 0) 'uploadCount': r.uploadCount,
    };
    await _dispatchSend(topicId, localId, body);
  }

  Future<void> patchMessage(String topicId, String msgId, Map<String, dynamic> data) async {
    await MutationQueue.instance.run(
      entityType: 'message',
      method: 'PATCH',
      path: '/v1/messages/$topicId/$msgId',
      body: data,
    );
  }

  Future<void> appendMediaUrl(String topicId, String msgId, String url) async {
    await MutationQueue.instance.run(
      entityType: 'message',
      method: 'PATCH',
      path: '/v1/messages/$topicId/$msgId',
      body: {'appendMediaUrl': url},
    );
  }

  Future<void> toggleReaction(String topicId, String msgId, String userId, String emoji) async {
    await MutationQueue.instance.run(
      entityType: 'message',
      method: 'POST',
      path: '/v1/messages/$topicId/$msgId/reactions',
      body: {'emoji': emoji},
    );
  }

  Future<void> markRead(String topicId, {required bool readingAsAdmin}) async {
    final db = AppDatabase.instance;
    await (db.update(db.messages)
          ..where((t) => t.topicId.equals(topicId) & t.isFromAdmin.equals(!readingAsAdmin)))
        .write(const MessagesCompanion(isRead: drift.Value(true)));

    await MutationQueue.instance.run(
      entityType: 'message',
      method: 'POST',
      path: '/v1/messages/$topicId/read',
      body: {'asAdmin': readingAsAdmin},
    );
  }

  Stream<int> customerUnreadStream(String topicId) {
    final db = AppDatabase.instance;
    return (db.select(db.messages)..where((t) => t.topicId.equals(topicId) & t.isFromAdmin.equals(true) & t.isRead.equals(false)))
        .watch()
        .map((rows) => rows.length);
  }

  Stream<List<ChatTopicModel>> topicsStream() => ApiClient.poll(const Duration(seconds: 5), () async {
        final res = await _api.get('/v1/messages/topics');
        return (res as List).map((e) => ChatTopicModel.fromJson(Map<String, dynamic>.from(e as Map))).toList();
      });

  Future<void> sendWelcomeIfNew({
    required String topicId,
    required String userName,
    required String userGroup,
    required String text,
    required String senderName,
  }) async {
    await MutationQueue.instance.run(
      entityType: 'message',
      method: 'POST',
      path: '/v1/messages/$topicId/welcome',
      body: {'text': text, 'senderName': senderName},
    );
  }

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
