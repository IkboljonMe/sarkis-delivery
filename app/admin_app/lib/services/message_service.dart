import 'dart:convert';
import 'dart:typed_data';

import 'package:drift/drift.dart' as drift;

import '../local_db/app_database.dart';
import '../models/message_model.dart';
import '../sync/mutation_queue.dart';
import 'api_client.dart';

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
      type: drift.Value('deleted'),
      content: drift.Value(''),
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
              final extra = r.extraJson.isNotEmpty ? jsonDecode(r.extraJson) as Map<String, dynamic> : <String, dynamic>{};
              return MessageModel(
                id: r.id,
                senderId: r.senderId,
                senderName: r.senderName,
                isFromAdmin: r.isFromAdmin,
                type: r.type,
                text: r.content,
                createdAt: r.createdAt,
                replyToId: (extra['replyToId'] as String?) ?? '',
                replyToText: (extra['replyToText'] as String?) ?? '',
                replyToSender: (extra['replyToSender'] as String?) ?? '',
                mediaUrl: (extra['mediaUrl'] as String?) ?? '',
                mediaUrls: extra['mediaUrls'] != null ? (extra['mediaUrls'] as List).map((e) => e.toString()).toList() : const [],
                durationMs: (extra['durationMs'] as num?)?.toInt() ?? 0,
                orderId: (extra['orderId'] as String?) ?? '',
                waveform: extra['waveform'] != null ? (extra['waveform'] as List).map((e) => (e as num).toInt()).toList() : const [],
                sizeBytes: (extra['sizeBytes'] as num?)?.toInt() ?? 0,
                uploading: r.pendingSync,
                uploadCount: (extra['uploadCount'] as num?)?.toInt() ?? 0,
                reactions: extra['reactions'] != null ? Map<String, String>.from(extra['reactions'] as Map) : const {},
                isRead: r.isRead,
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
    bool silent = false,
  }) async {
    final localId = 'local_${DateTime.now().millisecondsSinceEpoch}';
    final db = AppDatabase.instance;
    
    final extra = <String, dynamic>{
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
      if (silent) 'silent': silent,
    };

    await db.into(db.messages).insert(MessagesCompanion.insert(
          id: localId,
          topicId: topicId,
          senderId: senderId,
          senderName: drift.Value(senderName),
          isFromAdmin: drift.Value(isFromAdmin),
          type: drift.Value(type),
          content: drift.Value(text),
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
          extraJson: drift.Value(jsonEncode(extra)),
          isRead: const drift.Value(true),
          pendingSync: const drift.Value(true),
        ));

    return _dispatchSend(topicId, localId, {
      'type': type,
      'text': text,
      ...extra,
    });
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
    final extra = r.extraJson.isNotEmpty
        ? jsonDecode(r.extraJson) as Map<String, dynamic>
        : <String, dynamic>{};
    await _dispatchSend(topicId, localId, {
      'type': r.type,
      'text': r.content,
      ...extra,
    });
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
    return const Stream.empty(); // Not actively used via polling in admin app, kept for signature
  }

  Stream<List<ChatTopicModel>> topicsStream() {
    final db = AppDatabase.instance;
    return (db.select(db.chatTopics)
          ..orderBy([(t) => drift.OrderingTerm.desc(t.lastAt)])) // Changed to watch directly
        .watch()
        .map((rows) => rows.map((r) => ChatTopicModel(
              topicId: r.id,
              userName: r.userName,
              userGroup: r.userGroup,
              lastMessage: r.lastMessage,
              lastAt: r.lastAt,
              unread: r.adminUnread,
              lastFromAdmin: r.lastFromAdmin,
              lastRead: false,
              lastDelivered: true,
            )).toList());
  }

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
