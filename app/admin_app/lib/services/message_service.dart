import 'dart:io';
import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

import '../models/message_model.dart';

/// Chat messages live under messages/{topicId}/messages/{msgId}.
/// One topic per customer; topicId == userId.
class MessageService {
  MessageService._();
  static final MessageService instance = MessageService._();

  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  CollectionReference<Map<String, dynamic>> _msgs(String topicId) =>
      _db.collection('messages').doc(topicId).collection('messages');

  /// Uploads chat media to Storage and returns its download URL.
  Future<String> uploadChatMedia(
    String topicId,
    Uint8List bytes, {
    required String ext,
    required String contentType,
  }) async {
    final name = _msgs(topicId).doc().id;
    final ref = _storage.ref().child('chat/$topicId/$name.$ext');
    await ref.putData(bytes, SettableMetadata(contentType: contentType));
    return ref.getDownloadURL();
  }

  /// Uploads a media file by path (streamed — used for large videos).
  Future<String> uploadChatFile(
    String topicId,
    String path, {
    required String ext,
    required String contentType,
  }) async {
    final name = _msgs(topicId).doc().id;
    final ref = _storage.ref().child('chat/$topicId/$name.$ext');
    await ref.putFile(File(path), SettableMetadata(contentType: contentType));
    return ref.getDownloadURL();
  }

  /// Soft-deletes a message ("message deleted" placeholder for both sides).
  Future<void> deleteMessage(String topicId, String msgId) async {
    try {
      await _msgs(topicId).doc(msgId).update({
        'deleted': true,
        'text': '',
        'mediaUrl': '',
        'mediaUrls': <String>[],
        'waveform': <int>[],
        'orderId': '',
        'type': 'text',
        'uploading': false,
      });
    } catch (_) {}
  }

  Stream<List<MessageModel>> messagesStream(String topicId) {
    return _msgs(topicId)
        .orderBy('createdAt', descending: false)
        .snapshots()
        .map((s) => s.docs
            .map((d) => MessageModel.fromJson({...d.data(), 'id': d.id}))
            .toList());
  }

  Future<String> sendMessage({
    required String topicId,
    required String text,
    required String senderId,
    required String senderName,
    required bool isFromAdmin,
    bool silent = false,
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
    final ref = _msgs(topicId).doc();
    try {
      await ref.set({
        'id': ref.id,
        'senderId': senderId,
        'senderName': senderName,
        'text': text,
        'isFromAdmin': isFromAdmin,
        'isRead': false,
        'delivered': false,
        // Status-update messages set silent:true so the Cloud Function does
        // not send a duplicate chat push (the order trigger handles it).
        'silent': silent,
        'replyToId': replyToId,
        'replyToText': replyToText,
        'replyToSender': replyToSender,
        'reactions': <String, String>{},
        'type': type,
        'mediaUrl': mediaUrl,
        'mediaUrls': mediaUrls,
        'durationMs': durationMs,
        'orderId': orderId,
        'waveform': waveform,
        'sizeBytes': sizeBytes,
        'uploading': uploading,
        'uploadCount': uploadCount,
        'createdAt': FieldValue.serverTimestamp(),
      });
      return ref.id;
    } catch (e) {
      throw Exception('Failed to send message: $e');
    }
  }

  /// Patches fields of an existing message (fills media URLs after upload).
  Future<void> patchMessage(
      String topicId, String msgId, Map<String, dynamic> data) async {
    try {
      await _msgs(topicId).doc(msgId).update(data);
    } catch (_) {}
  }

  /// Appends one uploaded photo URL to an album message (optimistic send).
  Future<void> appendMediaUrl(String topicId, String msgId, String url) async {
    try {
      await _msgs(topicId).doc(msgId).update({
        'mediaUrls': FieldValue.arrayUnion([url]),
      });
    } catch (_) {}
  }

  /// Toggles an emoji reaction by [userId] on a message.
  Future<void> toggleReaction(
      String topicId, String msgId, String userId, String emoji) async {
    try {
      final ref = _msgs(topicId).doc(msgId);
      final doc = await ref.get();
      final reactions = (doc.data()?['reactions'] as Map?) ?? const {};
      if (reactions[userId] == emoji) {
        await ref.update({'reactions.$userId': FieldValue.delete()});
      } else {
        await ref.update({'reactions.$userId': emoji});
      }
    } catch (_) {}
  }

  /// Marks messages from the other party as read.
  Future<void> markRead(String topicId, {required bool readingAsAdmin}) async {
    try {
      // Admin reads customer messages (isFromAdmin == false) and vice versa.
      final query = await _msgs(topicId)
          .where('isFromAdmin', isEqualTo: !readingAsAdmin)
          .where('isRead', isEqualTo: false)
          .get();
      final batch = _db.batch();
      for (final d in query.docs) {
        batch.update(d.reference, {'isRead': true});
      }
      await batch.commit();
    } catch (_) {}
  }

  /// Unread count for the customer (admin messages not yet read).
  Stream<int> customerUnreadStream(String topicId) {
    return _msgs(topicId)
        .where('isFromAdmin', isEqualTo: true)
        .where('isRead', isEqualTo: false)
        .snapshots()
        .map((s) => s.docs.length);
  }

  /// All topics with their latest message (admin chat list).
  Stream<List<ChatTopicModel>> topicsStream() {
    return _db.collection('messages').snapshots().asyncMap((s) async {
      final topics = <ChatTopicModel>[];
      for (final doc in s.docs) {
        final last = await _msgs(doc.id)
            .orderBy('createdAt', descending: true)
            .limit(1)
            .get();
        final unread = await _msgs(doc.id)
            .where('isFromAdmin', isEqualTo: false)
            .where('isRead', isEqualTo: false)
            .get();
        final data = doc.data();
        final lastMsg = last.docs.isNotEmpty
            ? MessageModel.fromJson(
                {...last.docs.first.data(), 'id': last.docs.first.id})
            : null;
        topics.add(ChatTopicModel(
          topicId: doc.id,
          userName: data['userName'] as String? ?? '',
          userGroup: data['userGroup'] as String? ?? '',
          lastMessage: lastMsg?.previewText ?? '',
          lastAt: lastMsg?.createdAt,
          unread: unread.docs.length,
          lastFromAdmin: lastMsg?.isFromAdmin ?? false,
          lastDelivered: lastMsg?.delivered ?? false,
          lastRead: lastMsg?.isRead ?? false,
        ));
      }
      topics.sort((a, b) {
        if (a.unread != b.unread) return b.unread.compareTo(a.unread);
        final ad = a.lastAt ?? DateTime(1970);
        final bd = b.lastAt ?? DateTime(1970);
        return bd.compareTo(ad);
      });
      return topics;
    });
  }

  /// Ensures a topic doc exists with denormalized user info for the admin list.
  Future<void> ensureTopic({
    required String topicId,
    required String userName,
    required String userGroup,
  }) async {
    try {
      await _db.collection('messages').doc(topicId).set(
        {'userName': userName, 'userGroup': userGroup},
        SetOptions(merge: true),
      );
    } catch (_) {}
  }
}
