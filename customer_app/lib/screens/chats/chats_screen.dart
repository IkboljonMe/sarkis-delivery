import 'dart:async';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/rendering.dart' show ScrollDirection;
import 'package:provider/provider.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../l10n/app_localizations.dart';
import '../../models/message_model.dart';
import '../../models/user_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/locale_provider.dart';
import '../../providers/message_provider.dart';
import '../../services/translate_service.dart';
import '../../utils/app_colors.dart';
import '../../utils/app_text_styles.dart';
import '../../utils/constants.dart';
import '../../utils/voice_recorder.dart';
import '../../widgets/chat/chat_input_bar.dart';
import '../../widgets/chat/message_bubble.dart';
import '../../widgets/app_lottie.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/media_composer.dart';
import '../orders/order_detail_screen.dart';

const _kReactions = ['👍', '❤️', '😂', '😮', '😢', '🙏'];

class ChatsScreen extends StatefulWidget {
  const ChatsScreen({super.key});

  @override
  State<ChatsScreen> createState() => _ChatsScreenState();
}

class _ChatsScreenState extends State<ChatsScreen>
    with WidgetsBindingObserver {
  final _controller = TextEditingController();
  final _picker = ImagePicker();
  final _recorder = VoiceRecorder();
  final ItemScrollController _itemScroll = ItemScrollController();
  final ItemPositionsListener _positions = ItemPositionsListener.create();
  final FocusNode _inputFocus = FocusNode();
  final bool _uploading = false;
  bool _recording = false;
  int _recSeconds = 0;
  double _recDrag = 0; // horizontal drag during hold-to-record (slide to cancel)
  Timer? _recTimer;
  MessageModel? _replyTo;

  List<MessageModel> _msgs = const [];
  bool _initialized = false;
  String? _unreadAnchorId;
  String? _highlightedId;
  Timer? _flashTimer;
  final Map<String, String> _translations = {};
  final Set<String> _translating = {};
  // Auto-translate incoming (admin) messages into the customer's language.
  bool _showTranslated = true;

  /// Lazily translates every incoming admin message that isn't cached yet.
  void _ensureTranslations() {
    if (!_showTranslated || _msgs.isEmpty) return;
    final target = context.read<LocaleProvider>().translateLang;
    for (final m in _msgs) {
      if (m.isFromAdmin &&
          m.text.trim().isNotEmpty &&
          !_translations.containsKey(m.id) &&
          !_translating.contains(m.id)) {
        _translateMsg(m, target);
      }
    }
  }

  Future<void> _translateMsg(MessageModel m, String target) async {
    _translating.add(m.id);
    final out = await TranslateService.translate(m.text, target);
    if (!mounted) return;
    setState(() {
      _translating.remove(m.id);
      if (out != null) _translations[m.id] = out;
    });
  }

  int _lastCount = 0;
  bool _pendingScrollToEnd = false; // set when I send, to follow my message

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _controller.addListener(_onTextChanged);
  }

  /// When the keyboard opens, only follow to the bottom if the user was
  /// already there — never yank them away from older messages they're reading.
  @override
  void didChangeMetrics() {
    if (_inputFocus.hasFocus && _atBottom()) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToEnd());
    }
  }

  /// True when the newest message is (almost) the last visible one.
  bool _atBottom() {
    final positions = _positions.itemPositions.value;
    if (positions.isEmpty || _msgs.isEmpty) return true;
    final lastVisible = positions
        .where((p) => p.itemTrailingEdge > 0)
        .map((p) => p.index)
        .fold(0, (a, b) => a > b ? a : b);
    return lastVisible >= _msgs.length - 2;
  }

  void _scrollToEnd({bool animated = true}) {
    if (!_itemScroll.isAttached || _msgs.isEmpty) return;
    _itemScroll.scrollTo(
        index: _msgs.length - 1,
        alignment: 0,
        duration: Duration(milliseconds: animated ? 220 : 1),
        curve: Curves.easeOut);
  }

  void _dismissKeyboard() => FocusScope.of(context).unfocus();

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
    final wasAtBottom = _atBottom();
    final grew = msgs.length > _lastCount;
    _lastCount = msgs.length;
    if (msgs.isEmpty) {
      _msgs = msgs;
      return;
    }
    // Keep read state fresh: while the chat is open, mark any unread admin
    // messages read immediately (fixes ticks/badge not updating on read).
    final hasUnreadIncoming = msgs.any((m) => m.isFromAdmin && !m.isRead);
    if (_initialized && hasUnreadIncoming) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          context.read<MessageProvider>().markRead(user.id, readingAsAdmin: false);
        }
      });
    }
    _msgs = msgs;
    if (!_initialized) {
      _initialized = true;
      final firstUnread = msgs.indexWhere((m) => m.isFromAdmin && !m.isRead);
      final target = firstUnread >= 0 ? firstUnread : msgs.length - 1;
      if (firstUnread >= 0) _unreadAnchorId = msgs[firstUnread].id;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_itemScroll.isAttached) {
          _itemScroll.jumpTo(
              index: target, alignment: firstUnread >= 0 ? 0.3 : 0.0);
        }
        context.read<MessageProvider>().markRead(user.id, readingAsAdmin: false);
      });
      return;
    }
    // A new message arrived while open — follow to the bottom if the user was
    // already there, or if it's a message I just sent.
    if (grew && (wasAtBottom || _pendingScrollToEnd)) {
      _pendingScrollToEnd = false;
      WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToEnd());
    }
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
    WidgetsBinding.instance.removeObserver(this);
    _controller.removeListener(_onTextChanged);
    _controller.dispose();
    _inputFocus.dispose();
    _recTimer?.cancel();
    _flashTimer?.cancel();
    _recorder.dispose();
    super.dispose();
  }

  // --- Contact admin (WhatsApp / phone call) ---

  void _showContactAdmin(AppLocalizations t) {
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
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 4),
              child: Row(children: [
                Text(t.t('callAdmin'), style: AppTextStyles.headingM),
              ]),
            ),
            ListTile(
              leading: const Icon(Icons.chat, color: Color(0xFF25D366)),
              title: Text(t.t('chatViaWhatsApp')),
              subtitle: Text(AppConstants.adminPhoneNumber,
                  style: AppTextStyles.caption),
              onTap: () {
                Navigator.pop(ctx);
                _openWhatsApp();
              },
            ),
            ListTile(
              leading: const Icon(Icons.call, color: AppColors.primary),
              title: Text(t.t('callViaPhone')),
              subtitle: Text(AppConstants.adminPhoneNumber,
                  style: AppTextStyles.caption),
              onTap: () {
                Navigator.pop(ctx);
                _callAdmin();
              },
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  Future<void> _openWhatsApp() async {
    final t = AppLocalizations.of(context);
    final uri = Uri.parse('https://wa.me/${AppConstants.adminPhoneDigits}');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      Fluttertoast.showToast(msg: t.t('whatsAppUnavailable'));
    }
  }

  Future<void> _callAdmin() async {
    final t = AppLocalizations.of(context);
    final uri = Uri(
        scheme: 'tel',
        path: AppConstants.adminPhoneNumber.replaceAll(' ', ''));
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      Fluttertoast.showToast(msg: t.t('callFailed'));
    }
  }

  static const int _maxVoiceSeconds = 300; // 5-minute cap

  Future<void> _startRecording(UserModel user) async {
    final t = AppLocalizations.of(context);
    final ok = await _recorder.hasPermission();
    if (!ok) {
      Fluttertoast.showToast(msg: t.t('micPermissionDenied'));
      return;
    }
    await _recorder.start();
    setState(() {
      _recording = true;
      _recSeconds = 0;
    });
    _recTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      setState(() => _recSeconds++);
      if (_recSeconds >= _maxVoiceSeconds) _stopAndSendVoice(user);
    });
  }

  Future<void> _cancelRecording() async {
    _recTimer?.cancel();
    await _recorder.cancel();
    if (mounted) setState(() => _recording = false);
  }

  Future<void> _stopAndSendVoice(UserModel user) async {
    if (!_recording) return;
    _recTimer?.cancel();
    setState(() => _recording = false);
    final t = AppLocalizations.of(context);
    final msg = context.read<MessageProvider>();
    try {
      final rec = await _recorder.stop();
      if (rec == null || rec.durationMs < 500) return;
      _pendingScrollToEnd = true;
      // Post the voice message instantly (uploading), then fill in the URL.
      final id = await msg.send(
        topicId: user.id,
        text: '',
        senderId: user.id,
        senderName: user.name,
        isFromAdmin: false,
        userGroup: user.group,
        type: 'voice',
        mediaUrl: '',
        durationMs: rec.durationMs,
        waveform: rec.waveform,
        sizeBytes: rec.sizeBytes,
        uploading: true,
      );
      final url = await msg.uploadChatMedia(user.id, rec.bytes,
          ext: rec.ext, contentType: rec.contentType);
      await msg.patchMessage(
          user.id, id, {'mediaUrl': url, 'uploading': false});
    } catch (_) {
      Fluttertoast.showToast(msg: t.t('voiceSendFailed'));
    }
  }

  Future<void> _send(UserModel user) async {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    _controller.clear();
    _pendingScrollToEnd = true;
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

  void _showAttachSheet(UserModel user) {
    final t = AppLocalizations.of(context);
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
            ListTile(
              leading: const Icon(Icons.photo_library_outlined,
                  color: AppColors.primary),
              title: Text(t.t('photo')),
              onTap: () {
                Navigator.pop(ctx);
                _pickAndSendImages(user);
              },
            ),
            ListTile(
              leading: const Icon(Icons.videocam_outlined,
                  color: AppColors.primary),
              title: Text(t.t('video')),
              subtitle: Text(t.t('videoMaxSize')),
              onTap: () {
                Navigator.pop(ctx);
                _pickAndSendVideo(user);
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickAndSendVideo(UserModel user) async {
    final t = AppLocalizations.of(context);
    final picked = await _picker.pickVideo(source: ImageSource.gallery);
    if (picked == null || !mounted) return;
    final size = await picked.length();
    if (size > 50 * 1024 * 1024) {
      Fluttertoast.showToast(msg: t.t('videoTooLarge'));
      return;
    }
    if (!mounted) return;
    final msg = context.read<MessageProvider>();
    _pendingScrollToEnd = true;
    try {
      final id = await msg.send(
        topicId: user.id,
        text: '',
        senderId: user.id,
        senderName: user.name,
        isFromAdmin: false,
        userGroup: user.group,
        type: 'video',
        mediaUrl: '',
        sizeBytes: size,
        uploading: true,
      );
      final url = await msg.uploadChatFile(user.id, picked.path,
          ext: 'mp4', contentType: 'video/mp4');
      await msg.patchMessage(user.id, id, {'mediaUrl': url, 'uploading': false});
    } catch (_) {
      Fluttertoast.showToast(msg: t.t('videoSendFailed'));
    }
  }

  Future<void> _pickAndSendImages(UserModel user) async {
    final t = AppLocalizations.of(context);
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
    _pendingScrollToEnd = true;
    final n = result.files.length;
    try {
      // 1) Post the album message immediately so it appears instantly with
      //    per-photo spinners (Telegram-style optimistic send).
      final id = await msg.send(
        topicId: user.id,
        text: result.caption,
        senderId: user.id,
        senderName: user.name,
        isFromAdmin: false,
        userGroup: user.group,
        type: 'image',
        mediaUrls: const [],
        uploading: true,
        uploadCount: n,
      );
      // 2) Upload each photo, revealing it as soon as it lands.
      for (final f in result.files) {
        final bytes = await f.readAsBytes();
        final ext = f.name.split('.').last.toLowerCase();
        final url = await msg.uploadChatMedia(
          user.id,
          bytes,
          ext: ext == 'png' ? 'png' : 'jpg',
          contentType: ext == 'png' ? 'image/png' : 'image/jpeg',
        );
        await msg.appendMediaUrl(user.id, id, url);
      }
      // 3) Mark the album complete.
      await msg.patchMessage(user.id, id, {'uploading': false});
    } catch (e) {
      Fluttertoast.showToast(msg: t.t('photoSendFailed'));
    }
  }

  void _showReactions(UserModel user, MessageModel m) {
    final t = AppLocalizations.of(context);
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
              title: Text(t.t('reply')),
              onTap: () {
                Navigator.pop(ctx);
                setState(() => _replyTo = m);
              },
            ),
            if (!m.isFromAdmin && !m.deleted)
              ListTile(
                leading: const Icon(Icons.delete_outline,
                    color: AppColors.error),
                title: Text(AppLocalizations.of(context).t('deleteMessage'),
                    style: const TextStyle(color: AppColors.error)),
                onTap: () {
                  Navigator.pop(ctx);
                  context
                      .read<MessageProvider>()
                      .deleteMessage(user.id, m.id);
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
        centerTitle: true,
        toolbarHeight: 60,
        leadingWidth: 56,
        leading: IconButton(
          tooltip: t.t('callAdmin'),
          onPressed: () => _showContactAdmin(t),
          icon: const Icon(Icons.call, color: AppColors.primary),
        ),
        title: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(t.t('supportTitle'), style: AppTextStyles.headingM),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 7,
                  height: 7,
                  decoration: const BoxDecoration(
                      color: AppColors.success, shape: BoxShape.circle),
                ),
                const SizedBox(width: 5),
                Text(t.t('supportOnline'),
                    style: AppTextStyles.label
                        .copyWith(color: AppColors.textSecondary)),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(
            tooltip: t.t('chatSettings'),
            onPressed: () => _showChatSettings(t),
            icon: const Icon(Icons.settings_outlined,
                color: AppColors.primary),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<List<MessageModel>>(
              stream: msgProvider.messagesStream(user.id),
              builder: (context, snap) {
                final msgs = snap.data ?? [];
                _onMessages(user, msgs);
                _ensureTranslations();
                if (msgs.isEmpty) {
                  return EmptyState(
                      animation: AppAnim.envelope,
                      icon: Icons.chat_bubble_outline,
                      title: t.t('noMessages'));
                }
                return GestureDetector(
                  behavior: HitTestBehavior.translucent,
                  onTap: _dismissKeyboard,
                  child: NotificationListener<UserScrollNotification>(
                    onNotification: (n) {
                      if (n.direction != ScrollDirection.idle &&
                          _inputFocus.hasFocus) {
                        _dismissKeyboard();
                      }
                      return false;
                    },
                    child: Stack(
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
                    ),
                  ),
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

  /// Chat settings sheet: turn translation on/off and pick the language that
  /// incoming (admin) messages are translated into.
  void _showChatSettings(AppLocalizations t) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surfaceElevated,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        final locale = ctx.read<LocaleProvider>();
        return StatefulBuilder(
          builder: (ctx, setSheet) => SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 18, 20, 4),
                  child: Text(t.t('chatSettings'),
                      style: AppTextStyles.headingM),
                ),
                SwitchListTile(
                  value: _showTranslated,
                  activeColor: AppColors.primary,
                  title: Text(t.t('autoTranslate')),
                  subtitle: Text(t.t('translateLanguageHint'),
                      style: AppTextStyles.caption),
                  onChanged: (v) {
                    setSheet(() {});
                    setState(() => _showTranslated = v);
                    _ensureTranslations();
                  },
                ),
                const Divider(height: 1, color: AppColors.border),
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 12, 20, 6),
                  child: Text(t.t('translateLanguage'),
                      style: AppTextStyles.label),
                ),
                ...AppConstants.languages.map((lang) {
                  final sel = locale.translateLang == lang['code'];
                  return ListTile(
                    leading:
                        Text(lang['flag']!, style: const TextStyle(fontSize: 22)),
                    title: Text(lang['native']!),
                    trailing: sel
                        ? const Icon(Icons.check_circle,
                            color: AppColors.primary)
                        : null,
                    onTap: () {
                      locale.setTranslateLang(lang['code']!);
                      setSheet(() {});
                      setState(() {
                        _translations.clear(); // re-translate into new language
                      });
                      _ensureTranslations();
                    },
                  );
                }),
                const SizedBox(height: 8),
              ],
            ),
          ),
        );
      },
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
    final t = AppLocalizations.of(context);
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.symmetric(vertical: 4),
      alignment: Alignment.center,
      color: AppColors.surfaceElevated.withOpacity(0.6),
      child: Text(t.t('unreadMessages'),
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
    return MessageBubble(
      message: m,
      highlightedId: _highlightedId,
      showTranslated: _showTranslated,
      translations: _translations,
      translating: _translating,
      onReplySwipe: (msg) => setState(() => _replyTo = msg),
      onLongPress: (msg) => _showReactions(user, msg),
      onQuoteTap: _scrollToMessage,
      onOrderTap: (orderId) => Navigator.push(
        context,
        MaterialPageRoute(
            builder: (_) => OrderDetailScreen(orderId: orderId)),
      ),
    );
  }

  Widget _replyBanner() {
    final t = AppLocalizations.of(context);
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
                Text(r.isFromAdmin ? 'Admin' : t.t('you'),
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
    return ChatInputBar(
      controller: _controller,
      inputFocus: _inputFocus,
      recording: _recording,
      recSeconds: _recSeconds,
      recDrag: _recDrag,
      onAttach: () => _showAttachSheet(user),
      onSend: () => _send(user),
      onRecordStart: () {
        _recDrag = 0;
        _startRecording(user);
      },
      onRecordMove: (dx) {
        _recDrag += dx;
        if (_recDrag < -90 && _recording) _cancelRecording();
      },
      onRecordEnd: () {
        if (_recording) _stopAndSendVoice(user);
      },
      onRecordCancel: () {
        if (_recording) _cancelRecording();
      },
    );
  }
}
