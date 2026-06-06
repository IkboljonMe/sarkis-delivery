import 'package:flutter/foundation.dart';

import '../models/message_model.dart';
import '../services/message_service.dart';

class MessageProvider extends ChangeNotifier {
  final MessageService _service = MessageService.instance;

  Stream<List<MessageModel>> messagesStream(String topicId) =>
      _service.messagesStream(topicId);

  Stream<int> unreadStream(String topicId) =>
      _service.customerUnreadStream(topicId);

  Future<void> send({
    required String topicId,
    required String text,
    required String senderId,
    required String senderName,
    required bool isFromAdmin,
    String userGroup = '',
  }) async {
    await _service.ensureTopic(
        topicId: topicId, userName: senderName, userGroup: userGroup);
    await _service.sendMessage(
      topicId: topicId,
      text: text,
      senderId: senderId,
      senderName: senderName,
      isFromAdmin: isFromAdmin,
    );
  }

  Future<void> markRead(String topicId, {required bool readingAsAdmin}) =>
      _service.markRead(topicId, readingAsAdmin: readingAsAdmin);
}
