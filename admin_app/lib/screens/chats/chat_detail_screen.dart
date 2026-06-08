import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../models/message_model.dart';
import '../../providers/admin_auth_provider.dart';
import '../../services/message_service.dart';
import '../../utils/app_colors.dart';
import '../../utils/app_text_styles.dart';

const _kReactions = ['👍', '❤️', '😂', '😮', '😢', '🙏'];

class ChatDetailScreen extends StatefulWidget {
  final String topicId; // userId
  final String userName;
  final String? initialText; // pre-filled draft (e.g. an ETA message)
  const ChatDetailScreen(
      {super.key,
      required this.topicId,
      required this.userName,
      this.initialText});

  @override
  State<ChatDetailScreen> createState() => _ChatDetailScreenState();
}

class _ChatDetailScreenState extends State<ChatDetailScreen> {
  final _controller = TextEditingController();
  MessageModel? _replyTo;

  @override
  void initState() {
    super.initState();
    if (widget.initialText != null && widget.initialText!.isNotEmpty) {
      _controller.text = widget.initialText!;
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      MessageService.instance.markRead(widget.topicId, readingAsAdmin: true);
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  String get _uid => context.read<AdminAuthProvider>().uid ?? 'admin';

  Future<void> _send() async {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    _controller.clear();
    final reply = _replyTo;
    setState(() => _replyTo = null);
    await MessageService.instance.sendMessage(
      topicId: widget.topicId,
      text: text,
      senderId: _uid,
      senderName: 'Admin',
      isFromAdmin: true,
      replyToId: reply?.id ?? '',
      replyToText: reply?.text ?? '',
      replyToSender: reply == null ? '' : (reply.isFromAdmin ? 'Admin' : widget.userName),
    );
    // The push to the customer is sent server-side by onChatMessageCreated.
  }

  void _showReactions(MessageModel m) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surfaceElevated,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: _kReactions
                .map((e) => GestureDetector(
                      onTap: () {
                        Navigator.pop(ctx);
                        MessageService.instance
                            .toggleReaction(widget.topicId, m.id, _uid, e);
                      },
                      child: Text(e, style: const TextStyle(fontSize: 30)),
                    ))
                .toList(),
          ),
        ),
      ),
    );
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
                      child:
                          Text('Нет сообщений', style: AppTextStyles.caption));
                }
                return ListView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: msgs.length,
                  itemBuilder: (context, i) => _bubble(msgs[i]),
                );
              },
            ),
          ),
          if (_replyTo != null) _replyBanner(),
          _inputBar(),
        ],
      ),
    );
  }

  Widget _bubble(MessageModel m) {
    final mine = m.isFromAdmin;
    final time =
        m.createdAt != null ? DateFormat('HH:mm').format(m.createdAt!) : '';
    final reactions = m.reactionCounts;

    return Dismissible(
      key: ValueKey(m.id),
      direction: DismissDirection.startToEnd,
      dismissThresholds: const {DismissDirection.startToEnd: 0.25},
      confirmDismiss: (_) async {
        setState(() => _replyTo = m);
        return false;
      },
      background: const Padding(
        padding: EdgeInsets.only(left: 20),
        child: Align(
          alignment: Alignment.centerLeft,
          child: Icon(Icons.reply, color: AppColors.primary),
        ),
      ),
      child: GestureDetector(
        onLongPress: () => _showReactions(m),
        child: Align(
          alignment: mine ? Alignment.centerRight : Alignment.centerLeft,
          child: Column(
            crossAxisAlignment:
                mine ? CrossAxisAlignment.end : CrossAxisAlignment.start,
            children: [
              Container(
                margin: const EdgeInsets.symmetric(vertical: 3),
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                constraints: BoxConstraints(
                    maxWidth: MediaQuery.of(context).size.width * 0.72),
                decoration: BoxDecoration(
                  gradient: mine ? AppColors.goldGradient : null,
                  color: mine ? null : AppColors.surface,
                  borderRadius: BorderRadius.circular(14),
                  border: mine ? null : Border.all(color: AppColors.border),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (m.hasReply) _replyQuote(m, mine),
                    Text(m.text,
                        style: TextStyle(
                            color:
                                mine ? Colors.white : AppColors.textPrimary)),
                    const SizedBox(height: 2),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(time,
                            style: TextStyle(
                                fontSize: 10,
                                color: mine
                                    ? Colors.white70
                                    : AppColors.textMuted)),
                        if (mine) ...[
                          const SizedBox(width: 4),
                          Icon(m.isRead ? Icons.done_all : Icons.done,
                              size: 14,
                              color: m.isRead
                                  ? const Color(0xFF7FE0FF)
                                  : Colors.white70),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
              if (reactions.isNotEmpty) _reactionChips(reactions),
            ],
          ),
        ),
      ),
    );
  }

  Widget _replyQuote(MessageModel m, bool mine) {
    return Container(
      margin: const EdgeInsets.only(bottom: 6),
      padding: const EdgeInsets.fromLTRB(8, 4, 8, 4),
      decoration: BoxDecoration(
        color: (mine ? Colors.white : AppColors.primary).withOpacity(0.15),
        borderRadius: BorderRadius.circular(8),
        border: Border(
            left: BorderSide(
                color: mine ? Colors.white : AppColors.primary, width: 3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(m.replyToSender.isEmpty ? 'Ответ' : m.replyToSender,
              style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: mine ? Colors.white : AppColors.primary)),
          Text(m.replyToText,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                  fontSize: 12,
                  color: mine ? Colors.white70 : AppColors.textSecondary)),
        ],
      ),
    );
  }

  Widget _reactionChips(Map<String, int> reactions) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Wrap(
        spacing: 4,
        children: reactions.entries
            .map((e) => Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceElevated,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Text('${e.key} ${e.value}',
                      style: const TextStyle(fontSize: 12)),
                ))
            .toList(),
      ),
    );
  }

  Widget _replyBanner() {
    final r = _replyTo!;
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 6, 8, 6),
      color: AppColors.surface,
      child: Row(
        children: [
          const Icon(Icons.reply, size: 18, color: AppColors.primary),
          const SizedBox(width: 8),
          Container(width: 3, height: 32, color: AppColors.primary),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(r.isFromAdmin ? 'Admin' : widget.userName,
                    style: AppTextStyles.label
                        .copyWith(color: AppColors.primary)),
                Text(r.text,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.caption),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.close, size: 18),
            onPressed: () => setState(() => _replyTo = null),
          ),
        ],
      ),
    );
  }

  Widget _inputBar() {
    return SafeArea(
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
                  gradient: AppColors.goldGradient, shape: BoxShape.circle),
              child: const Icon(Icons.send, color: Colors.white, size: 20),
            ),
          ),
        ]),
      ),
    );
  }
}
