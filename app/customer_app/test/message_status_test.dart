import 'package:flutter_test/flutter_test.dart';
import 'package:customer_app/models/message_model.dart';

MessageModel _msg({
  bool isRead = false,
  bool pendingSync = false,
  bool sendFailed = false,
}) =>
    MessageModel(
      id: 'm1',
      senderId: 'u1',
      text: 'hi',
      isFromAdmin: false,
      isRead: isRead,
      pendingSync: pendingSync,
      sendFailed: sendFailed,
    );

void main() {
  group('MessageModel.sendStatus', () {
    test('optimistic (pendingSync) shows sending', () {
      expect(_msg(pendingSync: true).sendStatus, MsgSendStatus.sending);
    });

    test('server-rejected shows failed, overriding everything else', () {
      expect(
        _msg(pendingSync: true, sendFailed: true).sendStatus,
        MsgSendStatus.failed,
      );
    });

    test('acked and read shows read', () {
      expect(_msg(isRead: true).sendStatus, MsgSendStatus.read);
    });

    test('acked and unread shows sent', () {
      expect(_msg().sendStatus, MsgSendStatus.sent);
    });
  });
}
