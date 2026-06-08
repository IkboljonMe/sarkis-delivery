import 'dart:async';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';

import '../../l10n/app_localizations.dart';
import '../../models/message_model.dart';
import '../../models/user_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/message_provider.dart';
import '../../services/translate_service.dart';
import '../../utils/app_colors.dart';
import '../../utils/app_text_styles.dart';
import '../../utils/voice_recorder.dart';
import '../../widgets/chat_album.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/media_composer.dart';
import '../../widgets/voice_bubble.dart';

const _kReactions = ['👍', '❤️', '😂', '😮', '😢', '🙏'];

class ChatsScreen extends StatefulWidget {
  const ChatsScreen({super.key});

  @override
  State<ChatsScreen> createState() => _ChatsScreenState();
}

class _ChatsScreenState extends State<ChatsScreen> {
  final _controller = TextEditingController();
  final _picker = ImagePicker();
  final _recorder = VoiceRecorder();
  final ItemScrollController _itemScroll = ItemScrollController();
  final ItemPositionsListener _positions = ItemPositionsListener.create();
  final FocusNode _inputFocus = FocusNode();
  bool _uploading = false;
  bool _recording = false;
  int _recSeconds = 0;
  Timer? _recTimer;
  MessageModel? _replyTo;

  List<MessageModel> _msgs = const [];
  bool _initialized = false;
  String? _unreadAnchorId;
  String? _highlightedId;
  Timer? _flashTimer;
  final Map<String, String> _translations = {};
  final Set<String> _translating = {};

  Future<void> _translate(MessageModel m, String target) async {
    if (_translations.containsKey(m.id)) {
      setState(() => _translations.remove(m.id));
      return;
    }
    setState(() => _translating.add(m.id));
    final out = await TranslateService.translate(m.text, target);
    if (!mounted) return;
    setState(() {
      _translating.remove(m.id);
      if (out != null) _translations[m.id] = out;
    });
  }

  @override
  void initState() {
    super.initState();
    _controller.addListener(_onTextChanged);
    _inputFocus.addListener(() {
      if (_inputFocus.hasFocus) {
        Future.delayed(const Duration(milliseconds: 250), () {
          if (mounted && _itemScroll.isAttached && _msgs.isNotEmpty) {
            _itemScroll.scrollTo(
                index: _msgs.length - 1,
                duration: const Duration(milliseconds: 200));
          }
        });
      }
    });
  }

  void _onTextChanged() => setState(() {});

  void _flashMessage(String id) {
    setState(() => _highlightedId = id);
    _flashTimer?.cancel();
    _flashTimer = Timer(const Duration(milliseconds: 2200), () {
      if (mounted) setState(() => _highlightedId = null);
    });
  }

  /// On first data: capture the unread boundary, jump to it (or bottom), then
  /// mark read so the Telegram-style divider persists.
  void _onMessages(UserModel user, List<MessageModel> msgs) {
    _msgs = msgs;
    if (_initialized || msgs.isEmpty) return;
    _initialized = true;
    final firstUnread = msgs.indexWhere((m) => m.isFromAdmin && !m.isRead);
    final target = firstUnread >= 0 ? firstUnread : msgs.length - 1;
    if (firstUnread >= 0) _unreadAnchorId = msgs[firstUnread].id;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_itemScroll.isAttached) {
        _itemScroll.jumpTo(
            index: target, alignment: firstUnread >= 0 ? 0.3 : 0.0);
      }
      context
          .read<MessageProvider>()
          .markRead(user.id, readingAsAdmin: false);
    });
  }

  void _scrollToMessage(String id) {
    final i = _msgs.indexWhere((m) => m.id == id);
    if (i < 0 || !_itemScroll.isAttached) return;
    _itemScroll.scrollTo(
        index: i,
        alignment: 0.3,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut);
    _flashMessage(id);
  }

  void _scrollToBottom(UserModel user) {
    if (_msgs.isEmpty || !_itemScroll.isAttached) return;
    _itemScroll.scrollTo(
        index: _msgs.length - 1,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut);
    context.read<MessageProvider>().markRead(user.id, readingAsAdmin: false);
  }

  @override
  void dispose() {
    _controller.removeListener(_onTextChanged);
    _controller.dispose();
    _inputFocus.dispose();
    _recTimer?.cancel();
    _flashTimer?.cancel();
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

  Future<void> _stopAndSendVoice(UserModel user) async {
    _recTimer?.cancel();
    setState(() => _recording = false);
    final msg = context.read<MessageProvider>();
    try {
      final rec = await _recorder.stop();
      if (rec == null || rec.durationMs < 500) return;
      setState(() => _uploading = true);
      final url = await msg.uploadChatMedia(user.id, rec.bytes,
          ext: rec.ext, contentType: rec.contentType);
      await msg.send(
        topicId: user.id,
        text: '',
        senderId: user.id,
        senderName: user.name,
        isFromAdmin: false,
        userGroup: user.group,
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

  String _fmtSeconds(int s) =>
      '${s ~/ 60}:${(s % 60).toString().padLeft(2, '0')}';

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

  Future<void> _pickAndSendImages(UserModel user) async {
    if (_uploading) return;
    final picked =
        await _picker.pickMultiImage(imageQuality: 70, maxWidth: 1600);
    if (picked.isEmpty || !mounted) return;
    final result = await Navigator.push<MediaComposerResult>(
      context,
      MaterialPageRoute(builder: (_) => MediaComposer(initial: picked)),
    );
    if (result == null || result.files.isEmpty || !mounted) return;
    final msg = context.read<MessageProvider>();
    setState(() => _uploading = true);
    try {
      // Upload all, then send ONE album message (Telegram-style group).
      final urls = <String>[];
      for (final f in result.files) {
        final bytes = await f.readAsBytes();
        final ext = f.name.split('.').last.toLowerCase();
        urls.add(await msg.uploadChatMedia(
          user.id,
          bytes,
          ext: ext == 'png' ? 'png' : 'jpg',
          contentType: ext == 'png' ? 'image/png' : 'image/jpeg',
        ));
      }
      await msg.send(
        topicId: user.id,
        text: result.caption,
        senderId: user.id,
        senderName: user.name,
        isFromAdmin: false,
        userGroup: user.group,
        type: 'image',
        mediaUrls: urls,
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
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
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
            ListTile(
              leading: const Icon(Icons.reply, color: AppColors.primary),
              title: const Text('Ответить'),
              onTap: () {
                Navigator.pop(ctx);
                setState(() => _replyTo = m);
              },
            ),
            if (m.text.trim().isNotEmpty)
              ListTile(
                leading: const Icon(Icons.translate, color: AppColors.primary),
                title: Text(_translations.containsKey(m.id)
                    ? 'Оригинал'
                    : 'Перевести'),
                onTap: () {
                  Navigator.pop(ctx);
                  _translate(m, user.language);
                },
              ),
          ],
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
                _onMessages(user, msgs);
                if (msgs.isEmpty) {
                  return EmptyState(
                      icon: Icons.chat_bubble_outline,
                      title: t.t('noMessages'));
                }
                return Stack(
                  children: [
                    ScrollablePositionedList.builder(
                      itemScrollController: _itemScroll,
                      itemPositionsListener: _positions,
                      padding: const EdgeInsets.all(12),
                      itemCount: msgs.length,
                      itemBuilder: (context, i) => _item(user, msgs, i),
                    ),
                    _scrollDownButton(user, msgs),
                  ],
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

  Widget _item(UserModel user, List<MessageModel> msgs, int i) {
    final bubble = _bubble(user, msgs[i]);
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

  Widget _scrollDownButton(UserModel user, List<MessageModel> msgs) {
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
            .where((m) => m.isFromAdmin && !m.isRead)
            .length;
        return Positioned(
          right: 12,
          bottom: 12,
          child: GestureDetector(
            onTap: () => _scrollToBottom(user),
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
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          color: m.id == _highlightedId
              ? AppColors.primary.withOpacity(0.16)
              : Colors.transparent,
          child: Align(
            alignment: mine ? Alignment.centerRight : Alignment.centerLeft,
            child: Column(
              crossAxisAlignment:
                  mine ? CrossAxisAlignment.end : CrossAxisAlignment.start,
              children: [
                Container(
                  margin: const EdgeInsets.symmetric(vertical: 3),
                  padding: m.isImage
                      ? const EdgeInsets.all(3)
                      : const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 10),
                  constraints: BoxConstraints(
                      maxWidth: MediaQuery.of(context).size.width * 0.75),
                  decoration: BoxDecoration(
                    gradient: mine ? AppColors.goldGradient : null,
                    color: mine ? null : AppColors.surface,
                    borderRadius: BorderRadius.circular(16),
                    border: mine ? null : Border.all(color: AppColors.border),
                  ),
                  child: _bubbleContent(m, mine, time),
                ),
                if (reactions.isNotEmpty) _reactionChips(reactions),
              ],
            ),
          ),
        ),
      ),
    );
  }

  List<Widget> _metaInline(MessageModel m, bool mine, String time) {
    return [
      Text(time,
          style: TextStyle(
              fontSize: 10,
              color: mine ? Colors.white70 : AppColors.textMuted)),
      if (mine) ...[
        const SizedBox(width: 4),
        Icon(m.isRead ? Icons.done_all : Icons.done,
            size: 14,
            color: m.isRead ? const Color(0xFF7FE0FF) : Colors.white70),
      ],
    ];
  }

  Widget _metaChip(MessageModel m, bool mine, String time) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: Colors.black54,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(time,
              style: const TextStyle(fontSize: 10, color: Colors.white)),
          if (mine) ...[
            const SizedBox(width: 4),
            Icon(m.isRead ? Icons.done_all : Icons.done,
                size: 14,
                color: m.isRead ? const Color(0xFF7FE0FF) : Colors.white),
          ],
        ],
      ),
    );
  }

  Widget _adminLabel() => Padding(
        padding: const EdgeInsets.only(bottom: 2),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Admin',
                style:
                    AppTextStyles.label.copyWith(color: AppColors.primary)),
            const SizedBox(width: 4),
            Container(
              width: 5,
              height: 5,
              decoration: const BoxDecoration(
                  color: AppColors.primary, shape: BoxShape.circle),
            ),
          ],
        ),
      );

  Widget _maybeTranslation(MessageModel m, Color textColor, bool mine) {
    if (_translating.contains(m.id)) {
      return Padding(
        padding: const EdgeInsets.only(top: 4),
        child: Text('Перевод…',
            style: TextStyle(
                fontSize: 12,
                fontStyle: FontStyle.italic,
                color: mine ? Colors.white70 : AppColors.textSecondary)),
      );
    }
    final tr = _translations[m.id];
    if (tr == null) return const SizedBox.shrink();
    return Container(
      margin: const EdgeInsets.only(top: 4),
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: (mine ? Colors.white : AppColors.primary).withOpacity(0.12),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Перевод',
              style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: mine ? Colors.white70 : AppColors.primary)),
          Text(tr, style: TextStyle(color: textColor)),
        ],
      ),
    );
  }

  Widget _bubbleContent(MessageModel m, bool mine, String time) {
    final textColor = mine ? Colors.white : AppColors.textPrimary;

    if (m.isImage) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!mine)
            Padding(
                padding: const EdgeInsets.fromLTRB(6, 4, 6, 2),
                child: _adminLabel()),
          if (m.hasReply)
            Padding(
                padding: const EdgeInsets.fromLTRB(6, 2, 6, 4),
                child: _replyQuote(m, mine)),
          Stack(
            children: [
              ChatAlbum(urls: m.images),
              Positioned(
                  right: 8, bottom: 8, child: _metaChip(m, mine, time)),
            ],
          ),
          if (m.text.isNotEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(6, 6, 6, 2),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(m.text, style: TextStyle(color: textColor)),
                  _maybeTranslation(m, textColor, mine),
                ],
              ),
            ),
        ],
      );
    }

    if (m.isVoice) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!mine) _adminLabel(),
          if (m.hasReply) _replyQuote(m, mine),
          VoiceBubble(url: m.mediaUrl, durationMs: m.durationMs, mine: mine),
          const SizedBox(height: 2),
          SizedBox(
            width: 190,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: _metaInline(m, mine, time),
            ),
          ),
        ],
      );
    }

    return IntrinsicWidth(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!mine) _adminLabel(),
          if (m.hasReply) _replyQuote(m, mine),
          Text(m.text, style: TextStyle(color: textColor)),
          _maybeTranslation(m, textColor, mine),
          const SizedBox(height: 2),
          Row(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.end,
            children: _metaInline(m, mine, time),
          ),
        ],
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
    if (_recording) return _recordingBar(user);
    final hasText = _controller.text.trim().isNotEmpty;
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(6, 8, 12, 8),
        child: Row(
          children: [
            IconButton(
              onPressed: _uploading ? null : () => _pickAndSendImages(user),
              icon: const Icon(Icons.attach_file, color: AppColors.primary),
            ),
            Expanded(
              child: TextField(
                controller: _controller,
                focusNode: _inputFocus,
                style: AppTextStyles.body,
                minLines: 1,
                maxLines: 4,
                decoration: InputDecoration(hintText: t.sendMessage),
              ),
            ),
            const SizedBox(width: 8),
            _circleBtn(
              icon: _uploading ? null : (hasText ? Icons.send : Icons.mic),
              loading: _uploading,
              onTap: _uploading
                  ? null
                  : (hasText ? () => _send(user) : _startRecording),
            ),
          ],
        ),
      ),
    );
  }

  Widget _recordingBar(UserModel user) {
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(6, 8, 12, 8),
        child: Row(children: [
          IconButton(
            onPressed: _cancelRecording,
            icon: const Icon(Icons.delete_outline, color: AppColors.error),
          ),
          const _RecDot(),
          const SizedBox(width: 8),
          Text(_fmtSeconds(_recSeconds), style: AppTextStyles.bodyBold),
          const Spacer(),
          Text(_fmtSeconds(_recSeconds) == '0:00' ? '' : 'REC',
              style: AppTextStyles.caption.copyWith(color: AppColors.error)),
          const SizedBox(width: 8),
          _circleBtn(icon: Icons.send, onTap: () => _stopAndSendVoice(user)),
        ]),
      ),
    );
  }

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
