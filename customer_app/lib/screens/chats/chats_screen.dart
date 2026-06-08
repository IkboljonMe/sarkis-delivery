import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../l10n/app_localizations.dart';
import '../../models/message_model.dart';
import '../../models/user_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/message_provider.dart';
import '../../utils/app_colors.dart';
import '../../utils/app_text_styles.dart';
import '../../widgets/chat_image.dart';
import '../../widgets/empty_state.dart';

const _kReactions = ['👍', '❤️', '😂', '😮', '😢', '🙏'];

class ChatsScreen extends StatefulWidget {
  const ChatsScreen({super.key});

  @override
  State<ChatsScreen> createState() => _ChatsScreenState();
}

class _ChatsScreenState extends State<ChatsScreen> {
  final _controller = TextEditingController();
  final _picker = ImagePicker();
  bool _marked = false;
  bool _uploading = false;
  MessageModel? _replyTo;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _send(UserModel user) async {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    _controller.clear();
    final reply = _replyTo;
    setState(() => _replyTo = null);
    await context.read<MessageProvider>().send(
          topicId: user.id,
          text: text,
          senderId: user.id,
          senderName: user.name,
          isFromAdmin: false,
          userGroup: user.group,
          replyToId: reply?.id ?? '',
          replyToText: reply?.text ?? '',
          replyToSender:
              reply == null ? '' : (reply.isFromAdmin ? 'Admin' : user.name),
        );
  }

  Future<void> _pickAndSendImage(UserModel user) async {
    if (_uploading) return;
    final msg = context.read<MessageProvider>();
    try {
      final picked = await _picker.pickImage(
          source: ImageSource.gallery, imageQuality: 70, maxWidth: 1600);
      if (picked == null) return;
      setState(() => _uploading = true);
      final bytes = await picked.readAsBytes();
      final ext = picked.name.split('.').last.toLowerCase();
      final url = await msg.uploadChatMedia(
        user.id,
        bytes,
        ext: ext == 'png' ? 'png' : 'jpg',
        contentType: ext == 'png' ? 'image/png' : 'image/jpeg',
      );
      await msg.send(
        topicId: user.id,
        text: '',
        senderId: user.id,
        senderName: user.name,
        isFromAdmin: false,
        userGroup: user.group,
        type: 'image',
        mediaUrl: url,
      );
    } catch (e) {
      Fluttertoast.showToast(msg: 'Не удалось отправить фото');
    } finally {
      if (mounted) setState(() => _uploading = false);
    }
  }

  void _showReactions(UserModel user, MessageModel m) {
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
                        context
                            .read<MessageProvider>()
                            .toggleReaction(user.id, m.id, user.id, e);
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
    final t = AppLocalizations.of(context);
    final user = context.watch<AuthProvider>().user;
    final msgProvider = context.read<MessageProvider>();

    if (user == null) {
      return Scaffold(body: Center(child: Text(t.loading)));
    }

    if (!_marked) {
      _marked = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        msgProvider.markRead(user.id, readingAsAdmin: false);
      });
    }

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Row(
          children: [
            Text(t.chats),
            const SizedBox(width: 8),
            Container(
              width: 8,
              height: 8,
              decoration: const BoxDecoration(
                  color: AppColors.success, shape: BoxShape.circle),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<List<MessageModel>>(
              stream: msgProvider.messagesStream(user.id),
              builder: (context, snap) {
                final msgs = snap.data ?? [];
                if (msgs.isEmpty) {
                  return EmptyState(
                      icon: Icons.chat_bubble_outline,
                      title: t.t('noMessages'));
                }
                return ListView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: msgs.length,
                  itemBuilder: (context, i) => _bubble(user, msgs[i]),
                );
              },
            ),
          ),
          if (_replyTo != null) _replyBanner(),
          _inputBar(t, user),
        ],
      ),
    );
  }

  Widget _bubble(UserModel user, MessageModel m) {
    final mine = !m.isFromAdmin;
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
        onLongPress: () => _showReactions(user, m),
        child: Align(
          alignment: mine ? Alignment.centerRight : Alignment.centerLeft,
          child: Column(
            crossAxisAlignment:
                mine ? CrossAxisAlignment.end : CrossAxisAlignment.start,
            children: [
              Container(
                margin: const EdgeInsets.symmetric(vertical: 3),
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                constraints: BoxConstraints(
                    maxWidth: MediaQuery.of(context).size.width * 0.75),
                decoration: BoxDecoration(
                  gradient: mine ? AppColors.goldGradient : null,
                  color: mine ? null : AppColors.surface,
                  borderRadius: BorderRadius.circular(16),
                  border: mine ? null : Border.all(color: AppColors.border),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (!mine)
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text('Admin',
                              style: AppTextStyles.label
                                  .copyWith(color: AppColors.primary)),
                          const SizedBox(width: 4),
                          Container(
                            width: 5,
                            height: 5,
                            decoration: const BoxDecoration(
                                color: AppColors.primary,
                                shape: BoxShape.circle),
                          ),
                        ],
                      ),
                    if (m.hasReply) _replyQuote(m, mine),
                    if (m.isImage) ChatImage(url: m.mediaUrl),
                    if (!m.isImage)
                      Text(m.text,
                          style: TextStyle(
                              color: mine
                                  ? Colors.white
                                  : AppColors.textPrimary)),
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
                Text(r.isFromAdmin ? 'Admin' : 'Вы',
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

  Widget _inputBar(AppLocalizations t, UserModel user) {
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(6, 8, 12, 8),
        child: Row(
          children: [
            IconButton(
              onPressed: _uploading ? null : () => _pickAndSendImage(user),
              icon: _uploading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2))
                  : const Icon(Icons.attach_file, color: AppColors.primary),
            ),
            Expanded(
              child: TextField(
                controller: _controller,
                style: AppTextStyles.body,
                minLines: 1,
                maxLines: 4,
                decoration: InputDecoration(hintText: t.sendMessage),
              ),
            ),
            const SizedBox(width: 8),
            GestureDetector(
              onTap: () => _send(user),
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: const BoxDecoration(
                    gradient: AppColors.goldGradient, shape: BoxShape.circle),
                child: const Icon(Icons.send, color: Colors.white, size: 20),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
