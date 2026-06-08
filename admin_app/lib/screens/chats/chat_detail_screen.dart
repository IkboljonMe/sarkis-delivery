import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../models/message_model.dart';
import '../../providers/admin_auth_provider.dart';
import '../../services/message_service.dart';
import '../../utils/app_colors.dart';
import '../../utils/app_text_styles.dart';

class ChatDetailScreen extends StatefulWidget {
  final String topicId; // userId
  final String userName;
  const ChatDetailScreen(
      {super.key, required this.topicId, required this.userName});

  @override
  State<ChatDetailScreen> createState() => _ChatDetailScreenState();
}

class _ChatDetailScreenState extends State<ChatDetailScreen> {
  final _controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      MessageService.instance.markRead(widget.topicId, readingAsAdmin: true);
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    _controller.clear();
    final admin = context.read<AdminAuthProvider>();
    await MessageService.instance.sendMessage(
      topicId: widget.topicId,
      text: text,
      senderId: admin.uid ?? 'admin',
      senderName: 'Admin',
      isFromAdmin: true,
    );
    // The push to the customer is sent server-side by onChatMessageCreated.
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.userName)),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<List<MessageModel>>(
              stream: MessageService.instance.messagesStream(widget.topicId),
              builder: (context, snap) {
                final msgs = snap.data ?? [];
                if (msgs.isEmpty) {
                  return Center(
                      child: Text('Нет сообщений',
                          style: AppTextStyles.caption));
                }
                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: msgs.length,
                  itemBuilder: (context, i) => _bubble(msgs[i]),
                );
              },
            ),
          ),
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: Row(children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    style: AppTextStyles.body,
                    minLines: 1,
                    maxLines: 4,
                    decoration: const InputDecoration(hintText: 'Сообщение...'),
                  ),
                ),
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: _send,
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: const BoxDecoration(
                        gradient: AppColors.goldGradient,
                        shape: BoxShape.circle),
                    child:
                        const Icon(Icons.send, color: Colors.white, size: 20),
                  ),
                ),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _bubble(MessageModel m) {
    final admin = m.isFromAdmin;
    final time =
        m.createdAt != null ? DateFormat('d MMM HH:mm').format(m.createdAt!) : '';
    return Align(
      alignment: admin ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        constraints:
            BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.7),
        decoration: BoxDecoration(
          gradient: admin ? AppColors.goldGradient : null,
          color: admin ? null : AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: admin ? null : Border.all(color: AppColors.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(m.text,
                style: TextStyle(
                    color: admin ? Colors.white : AppColors.textPrimary)),
            Text(time,
                style: TextStyle(
                    fontSize: 10,
                    color: admin ? Colors.white70 : AppColors.textMuted)),
          ],
        ),
      ),
    );
  }
}
