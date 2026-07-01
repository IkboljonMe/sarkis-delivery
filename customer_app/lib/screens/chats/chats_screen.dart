import 'dart:async';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
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
import '../../widgets/chat_album.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/media_composer.dart';
import '../../widgets/video_bubble.dart';
import '../../widgets/voice_bubble.dart';
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
  bool _uploading = false;
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

  String _fmtSeconds(int s) =>
      '${s ~/ 60}:${(s % 60).toString().padLeft(2, '0')}';

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
        Icon(m.isRead || m.delivered ? Icons.done_all : Icons.done,
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
            Icon(m.isRead || m.delivered ? Icons.done_all : Icons.done,
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

  /// Renders the message text, swapping in the translation for incoming
  /// (admin) messages while the global translate toggle is on.
  Widget _translatedAwareText(MessageModel m, Color textColor, bool mine) {
    final t = AppLocalizations.of(context);
    final incoming = !mine;
    final translated = _translations[m.id];
    final showT = _showTranslated && incoming && translated != null;
    final translating =
        _showTranslated && incoming && _translating.contains(m.id);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(showT ? translated : m.text, style: TextStyle(color: textColor)),
        if (showT)
          Padding(
            padding: const EdgeInsets.only(top: 2),
            child: Icon(Icons.translate,
                size: 11,
                color: mine ? Colors.white70 : AppColors.textMuted),
          ),
        if (translating)
          Padding(
            padding: const EdgeInsets.only(top: 2),
            child: Text(t.t('translating'),
                style: TextStyle(
                    fontSize: 11,
                    fontStyle: FontStyle.italic,
                    color: mine ? Colors.white70 : AppColors.textSecondary)),
          ),
      ],
    );
  }

  Widget _bubbleContent(MessageModel m, bool mine, String time) {
    final textColor = mine ? Colors.white : AppColors.textPrimary;

    if (m.deleted) {
      final muted = mine ? Colors.white70 : AppColors.textMuted;
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.block, size: 14, color: muted),
          const SizedBox(width: 6),
          Text(AppLocalizations.of(context).t('messageDeleted'),
              style: TextStyle(
                  fontStyle: FontStyle.italic, color: muted, fontSize: 13)),
          const SizedBox(width: 8),
          ..._metaInline(m, mine, time),
        ],
      );
    }

    if (m.isOrder) return _orderCard(m, mine, time, textColor);

    if (m.isVideo) {
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
              VideoBubble(
                  url: m.mediaUrl,
                  sizeBytes: m.sizeBytes,
                  uploading: m.uploading),
              Positioned(
                  right: 8, bottom: 8, child: _metaChip(m, mine, time)),
            ],
          ),
          if (m.text.isNotEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(6, 6, 6, 2),
              child: _translatedAwareText(m, textColor, mine),
            ),
        ],
      );
    }

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
              ChatAlbum(
                urls: m.images,
                pendingCount: m.uploading
                    ? (m.uploadCount - m.images.length).clamp(0, 20)
                    : 0,
              ),
              Positioned(
                  right: 8, bottom: 8, child: _metaChip(m, mine, time)),
            ],
          ),
          if (m.text.isNotEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(6, 6, 6, 2),
              child: _translatedAwareText(m, textColor, mine),
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
          VoiceBubble(
            url: m.mediaUrl,
            durationMs: m.durationMs,
            mine: mine,
            waveform: m.waveform,
            sizeBytes: m.sizeBytes,
            uploading: m.uploading,
          ),
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
          _translatedAwareText(m, textColor, mine),
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

  /// Telegram-style attachment card linking to an order ("View order").
  Widget _orderCard(MessageModel m, bool mine, String time, Color textColor) {
    final t = AppLocalizations.of(context);
    final accent = mine ? Colors.white : AppColors.primary;
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (!mine) _adminLabel(),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.receipt_long, size: 18, color: accent),
            const SizedBox(width: 6),
            Text(t.t('orderDetails'),
                style: AppTextStyles.bodyBold.copyWith(color: textColor)),
          ],
        ),
        const SizedBox(height: 4),
        if (m.text.isNotEmpty) _translatedAwareText(m, textColor, mine),
        const SizedBox(height: 8),
        InkWell(
          onTap: m.orderId.isEmpty
              ? null
              : () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) =>
                            OrderDetailScreen(orderId: m.orderId)),
                  ),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: (mine ? Colors.white : AppColors.primary)
                  .withOpacity(0.15),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: accent.withOpacity(0.5)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(t.t('viewOrder'),
                    style: AppTextStyles.bodyBold.copyWith(color: accent)),
                const SizedBox(width: 4),
                Icon(Icons.arrow_forward, size: 16, color: accent),
              ],
            ),
          ),
        ),
        const SizedBox(height: 4),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: _metaInline(m, mine, time),
        ),
      ],
    );
  }

  Widget _replyQuote(MessageModel m, bool mine) {
    final t = AppLocalizations.of(context);
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
            Text(m.replyToSender.isEmpty ? t.t('reply') : m.replyToSender,
                style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: mine ? Colors.white : AppColors.primary)),
            Text(m.replyToText.isEmpty ? t.t('attachment') : m.replyToText,
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
    final hasText = _controller.text.trim().isNotEmpty;
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(6, 8, 12, 8),
        child: Row(
          children: [
            if (_recording)
              Expanded(child: _recordingStrip())
            else ...[
              IconButton(
                onPressed: () => _showAttachSheet(user),
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
            ],
            const SizedBox(width: 8),
            if (hasText && !_recording)
              _circleBtn(icon: Icons.send, onTap: () => _send(user))
            else
              // Hold-to-record (Telegram-style): press to start, release to
              // send, slide left to cancel. The button stays mounted across
              // the recording state so the pointer-up still reaches it.
              Listener(
                onPointerDown: (_) {
                  _recDrag = 0;
                  _startRecording(user);
                },
                onPointerMove: (e) {
                  _recDrag += e.delta.dx;
                  if (_recDrag < -90 && _recording) _cancelRecording();
                },
                onPointerUp: (_) {
                  if (_recording) _stopAndSendVoice(user);
                },
                onPointerCancel: (_) {
                  if (_recording) _cancelRecording();
                },
                child: _circleBtn(
                    icon: _recording ? Icons.send : Icons.mic, onTap: null),
              ),
          ],
        ),
      ),
    );
  }

  Widget _recordingStrip() {
    final t = AppLocalizations.of(context);
    return Row(
      children: [
        const _RecDot(),
        const SizedBox(width: 8),
        Text(_fmtSeconds(_recSeconds), style: AppTextStyles.bodyBold),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            _recDrag < -40 ? t.t('releaseToCancel') : t.t('slideToCancel'),
            overflow: TextOverflow.ellipsis,
            style: AppTextStyles.caption.copyWith(color: AppColors.error),
          ),
        ),
      ],
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
