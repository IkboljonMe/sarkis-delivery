import 'dart:async';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';

import '../../models/message_model.dart';
import '../../providers/admin_auth_provider.dart';
import '../../services/message_service.dart';
import '../../utils/app_colors.dart';
import '../../utils/app_text_styles.dart';
import '../../utils/voice_recorder.dart';
import '../../widgets/chat_image.dart';
import '../../widgets/voice_bubble.dart';

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
  final _picker = ImagePicker();
  final _recorder = VoiceRecorder();
  final ItemScrollController _itemScroll = ItemScrollController();
  final ItemPositionsListener _positions = ItemPositionsListener.create();
  MessageModel? _replyTo;
  bool _uploading = false;
  bool _recording = false;
  int _recSeconds = 0;
  Timer? _recTimer;

  List<MessageModel> _msgs = const [];
  bool _initialized = false;
  String? _unreadAnchorId; // first unread message on entry (Telegram divider)

  @override
  void initState() {
    super.initState();
    if (widget.initialText != null && widget.initialText!.isNotEmpty) {
      _controller.text = widget.initialText!;
    }
    _controller.addListener(_onTextChanged);
  }

  /// On first data: capture the unread boundary, jump to it (or to bottom),
  /// then mark as read so the divider persists.
  void _onMessages(List<MessageModel> msgs) {
    _msgs = msgs;
    if (_initialized || msgs.isEmpty) return;
    _initialized = true;
    final firstUnread =
        msgs.indexWhere((m) => !m.isFromAdmin && !m.isRead);
    final target = firstUnread >= 0 ? firstUnread : msgs.length - 1;
    if (firstUnread >= 0) _unreadAnchorId = msgs[firstUnread].id;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_itemScroll.isAttached) {
        _itemScroll.jumpTo(
            index: target, alignment: firstUnread >= 0 ? 0.3 : 0.0);
      }
      MessageService.instance.markRead(widget.topicId, readingAsAdmin: true);
    });
  }

  int _indexOfMessage(String id) => _msgs.indexWhere((m) => m.id == id);

  void _scrollToMessage(String id) {
    final i = _indexOfMessage(id);
    if (i < 0 || !_itemScroll.isAttached) return;
    _itemScroll.scrollTo(
        index: i,
        alignment: 0.3,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut);
  }

  void _scrollToBottom() {
    if (_msgs.isEmpty || !_itemScroll.isAttached) return;
    _itemScroll.scrollTo(
        index: _msgs.length - 1,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut);
    MessageService.instance.markRead(widget.topicId, readingAsAdmin: true);
  }

  void _onTextChanged() => setState(() {});

  @override
  void dispose() {
    _controller.removeListener(_onTextChanged);
    _controller.dispose();
    _recTimer?.cancel();
    _recorder.dispose();
    super.dispose();
  }

  Future<void> _startRecording() async {
    final ok = await _recorder.hasPermission();
    if (!ok) {
      Fluttertoast.showToast(msg: 'Нет доступа к микрофону');
      return;
    }
    await _recorder.start();
    setState(() {
      _recording = true;
      _recSeconds = 0;
    });
    _recTimer = Timer.periodic(
        const Duration(seconds: 1), (_) => setState(() => _recSeconds++));
  }

  Future<void> _cancelRecording() async {
    _recTimer?.cancel();
    await _recorder.cancel();
    if (mounted) setState(() => _recording = false);
  }

  Future<void> _stopAndSendVoice() async {
    _recTimer?.cancel();
    setState(() => _recording = false);
    try {
      final rec = await _recorder.stop();
      if (rec == null || rec.durationMs < 500) return;
      setState(() => _uploading = true);
      final url = await MessageService.instance.uploadChatMedia(
          widget.topicId, rec.bytes,
          ext: rec.ext, contentType: rec.contentType);
      await MessageService.instance.sendMessage(
        topicId: widget.topicId,
        text: '',
        senderId: _uid,
        senderName: 'Admin',
        isFromAdmin: true,
        type: 'voice',
        mediaUrl: url,
        durationMs: rec.durationMs,
      );
    } catch (_) {
      Fluttertoast.showToast(msg: 'Не удалось отправить голосовое');
    } finally {
      if (mounted) setState(() => _uploading = false);
    }
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

  Future<void> _pickAndSendImage() async {
    if (_uploading) return;
    try {
      final picked = await _picker.pickImage(
          source: ImageSource.gallery, imageQuality: 70, maxWidth: 1600);
      if (picked == null) return;
      setState(() => _uploading = true);
      final bytes = await picked.readAsBytes();
      final ext = picked.name.split('.').last.toLowerCase();
      final url = await MessageService.instance.uploadChatMedia(
        widget.topicId,
        bytes,
        ext: ext == 'png' ? 'png' : 'jpg',
        contentType: ext == 'png' ? 'image/png' : 'image/jpeg',
      );
      await MessageService.instance.sendMessage(
        topicId: widget.topicId,
        text: '',
        senderId: _uid,
        senderName: 'Admin',
        isFromAdmin: true,
        type: 'image',
        mediaUrl: url,
      );
    } catch (e) {
      Fluttertoast.showToast(msg: 'Не удалось отправить фото');
    } finally {
      if (mounted) setState(() => _uploading = false);
    }
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
                _onMessages(msgs);
                if (msgs.isEmpty) {
                  return Center(
                      child:
                          Text('Нет сообщений', style: AppTextStyles.caption));
                }
                return Stack(
                  children: [
                    ScrollablePositionedList.builder(
                      itemScrollController: _itemScroll,
                      itemPositionsListener: _positions,
                      padding: const EdgeInsets.all(12),
                      itemCount: msgs.length,
                      itemBuilder: (context, i) => _item(msgs, i),
                    ),
                    _scrollDownButton(msgs),
                  ],
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

  Widget _item(List<MessageModel> msgs, int i) {
    final bubble = _bubble(msgs[i]);
    if (msgs[i].id == _unreadAnchorId && i > 0) {
      return Column(children: [_unreadDivider(), bubble]);
    }
    return bubble;
  }

  Widget _unreadDivider() {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.symmetric(vertical: 4),
      alignment: Alignment.center,
      color: AppColors.surfaceElevated.withOpacity(0.6),
      child: Text('Непрочитанные сообщения',
          style: AppTextStyles.caption.copyWith(color: AppColors.primary)),
    );
  }

  Widget _scrollDownButton(List<MessageModel> msgs) {
    return ValueListenableBuilder<Iterable<ItemPosition>>(
      valueListenable: _positions.itemPositions,
      builder: (context, positions, _) {
        if (positions.isEmpty) return const SizedBox.shrink();
        final lastVisible = positions
            .where((p) => p.itemTrailingEdge > 0)
            .map((p) => p.index)
            .fold(0, (a, b) => a > b ? a : b);
        if (lastVisible >= msgs.length - 1) return const SizedBox.shrink();
        final unreadBelow = msgs
            .skip(lastVisible + 1)
            .where((m) => !m.isFromAdmin && !m.isRead)
            .length;
        return Positioned(
          right: 12,
          bottom: 12,
          child: GestureDetector(
            onTap: _scrollToBottom,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: AppColors.surfaceElevated,
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.border),
                    boxShadow: const [
                      BoxShadow(color: Colors.black45, blurRadius: 6)
                    ],
                  ),
                  child: const Icon(Icons.keyboard_arrow_down,
                      color: AppColors.primary),
                ),
                if (unreadBelow > 0)
                  Positioned(
                    top: -4,
                    right: -4,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      constraints:
                          const BoxConstraints(minWidth: 20, minHeight: 20),
                      decoration: const BoxDecoration(
                          color: AppColors.primary, shape: BoxShape.circle),
                      child: Text('$unreadBelow',
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.bold)),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
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
                    if (m.isImage) ChatImage(url: m.mediaUrl),
                    if (m.isVoice)
                      VoiceBubble(
                          url: m.mediaUrl,
                          durationMs: m.durationMs,
                          mine: mine),
                    if (!m.isImage && !m.isVoice)
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
    return GestureDetector(
      onTap: () => _scrollToMessage(m.replyToId),
      child: Container(
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
            Text(m.replyToText.isEmpty ? '📎 вложение' : m.replyToText,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                    fontSize: 12,
                    color: mine ? Colors.white70 : AppColors.textSecondary)),
          ],
        ),
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
    if (_recording) return _recordingBar();
    final hasText = _controller.text.trim().isNotEmpty;
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Row(children: [
          IconButton(
            onPressed: _uploading ? null : _pickAndSendImage,
            icon: const Icon(Icons.attach_file, color: AppColors.primary),
          ),
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
          _circleBtn(
            icon: _uploading
                ? null
                : (hasText ? Icons.send : Icons.mic),
            loading: _uploading,
            onTap: _uploading
                ? null
                : (hasText ? _send : _startRecording),
          ),
        ]),
      ),
    );
  }

  Widget _recordingBar() {
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Row(children: [
          IconButton(
            onPressed: _cancelRecording,
            icon: const Icon(Icons.delete_outline, color: AppColors.error),
          ),
          const _RecDot(),
          const SizedBox(width: 8),
          Text(_fmtSeconds(_recSeconds), style: AppTextStyles.bodyBold),
          const Spacer(),
          Text('Запись…', style: AppTextStyles.caption),
          const SizedBox(width: 8),
          _circleBtn(icon: Icons.send, onTap: _stopAndSendVoice),
        ]),
      ),
    );
  }

  String _fmtSeconds(int s) =>
      '${s ~/ 60}:${(s % 60).toString().padLeft(2, '0')}';

  Widget _circleBtn(
      {IconData? icon, bool loading = false, VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: const BoxDecoration(
            gradient: AppColors.goldGradient, shape: BoxShape.circle),
        child: loading
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                    strokeWidth: 2, color: Colors.white))
            : Icon(icon, color: Colors.white, size: 20),
      ),
    );
  }
}

class _RecDot extends StatefulWidget {
  const _RecDot();
  @override
  State<_RecDot> createState() => _RecDotState();
}

class _RecDotState extends State<_RecDot>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 700))
    ..repeat(reverse: true);

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _c,
      child: Container(
        width: 12,
        height: 12,
        decoration:
            const BoxDecoration(color: AppColors.error, shape: BoxShape.circle),
      ),
    );
  }
}
