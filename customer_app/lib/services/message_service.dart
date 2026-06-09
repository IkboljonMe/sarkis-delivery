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

  Stream<List<MessageModel>> messagesStream(String topicId) {
    return _msgs(topicId)
        .orderBy('createdAt', descending: false)
        .snapshots()
        .map((s) => s.docs
            .map((d) => MessageModel.fromJson({...d.data(), 'id': d.id}))
            .toList());
  }

  Future<void> sendMessage({
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
  }) async {
    try {
      final ref = _msgs(topicId).doc();
      await ref.set({
        'id': ref.id,
        'senderId': senderId,
        'senderName': senderName,
        'text': text,
        'isFromAdmin': isFromAdmin,
        'isRead': false,
        'replyToId': replyToId,
        'replyToText': replyToText,
        'replyToSender': replyToSender,
        'reactions': <String, String>{},
        'type': type,
        'mediaUrl': mediaUrl,
        'mediaUrls': mediaUrls,
        'durationMs': durationMs,
        'createdAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Failed to send message: $e');
    }
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
          lastMessage: lastMsg?.text ?? '',
          lastAt: lastMsg?.createdAt,
          unread: unread.docs.length,
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

  /// Sends the one-time admin welcome message to a freshly registered user.
  /// No-op if the topic already has any messages (avoids duplicates).
  Future<void> sendWelcomeIfNew({
    required String topicId,
    required String userName,
    required String userGroup,
    required String text,
    required String adminUid,
    required String senderName,
  }) async {
    try {
      final existing = await _msgs(topicId).limit(1).get();
      if (existing.docs.isNotEmpty) return;
      await ensureTopic(
          topicId: topicId, userName: userName, userGroup: userGroup);
      await sendMessage(
        topicId: topicId,
        text: text,
        senderId: adminUid,
        senderName: senderName,
        isFromAdmin: true,
      );
    } catch (_) {}
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
