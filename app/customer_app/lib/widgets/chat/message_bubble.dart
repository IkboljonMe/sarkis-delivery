import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../l10n/app_localizations.dart';
import '../../models/message_model.dart';
import '../../utils/app_colors.dart';
import '../../utils/app_text_styles.dart';
import '../chat_album.dart';
import '../video_bubble.dart';
import '../voice_bubble.dart';

/// Renders a single chat message bubble (text/image/video/voice/order card,
/// reply quote and reaction chips). Presentational: the owning screen keeps the
/// state and supplies data + callbacks.
class MessageBubble extends StatelessWidget {
  final MessageModel message;
  final String? highlightedId;
  final bool showTranslated;
  final Map<String, String> translations;
  final Set<String> translating;
  final void Function(MessageModel) onReplySwipe;
  final void Function(MessageModel) onLongPress;
  final void Function(String replyToId) onQuoteTap;
  final void Function(String orderId) onOrderTap;
  final void Function(MessageModel)? onRetry;

  const MessageBubble({
    super.key,
    required this.message,
    required this.highlightedId,
    required this.showTranslated,
    required this.translations,
    required this.translating,
    required this.onReplySwipe,
    required this.onLongPress,
    required this.onQuoteTap,
    required this.onOrderTap,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    final m = message;
    final mine = !m.isFromAdmin;
    final time =
        m.createdAt != null ? DateFormat('HH:mm').format(m.createdAt!) : '';
    final reactions = m.reactionCounts;

    return Dismissible(
      key: ValueKey(m.id),
      direction: DismissDirection.startToEnd,
      dismissThresholds: const {DismissDirection.startToEnd: 0.25},
      confirmDismiss: (_) async {
        onReplySwipe(m);
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
        onLongPress: () => onLongPress(m),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          color: m.id == highlightedId
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
                  child: _bubbleContent(context, m, mine, time),
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
        _statusIcon(m, base: Colors.white70),
      ],
    ];
  }

  /// WhatsApp-style status tick for my outgoing messages.
  Widget _statusIcon(MessageModel m, {required Color base}) {
    switch (m.sendStatus) {
      case MsgSendStatus.sending:
        return Icon(Icons.access_time, size: 13, color: base);
      case MsgSendStatus.failed:
        return GestureDetector(
          onTap: onRetry == null ? null : () => onRetry!(m),
          child: const Icon(Icons.error_outline,
              size: 15, color: Color(0xFFFF6B6B)),
        );
      case MsgSendStatus.read:
        return const Icon(Icons.done_all,
            size: 14, color: Color(0xFF7FE0FF));
      case MsgSendStatus.sent:
        return Icon(Icons.done_all, size: 14, color: base);
    }
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
            _statusIcon(m, base: Colors.white),
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
  Widget _translatedAwareText(
      BuildContext context, MessageModel m, Color textColor, bool mine) {
    final t = AppLocalizations.of(context);
    final incoming = !mine;
    final translated = translations[m.id];
    final showT = showTranslated && incoming && translated != null;
    final translatingNow =
        showTranslated && incoming && translating.contains(m.id);
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
        if (translatingNow)
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

  Widget _bubbleContent(
      BuildContext context, MessageModel m, bool mine, String time) {
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

    if (m.isOrder) return _orderCard(context, m, mine, time, textColor);

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
                child: _replyQuote(context, m, mine)),
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
              child: _translatedAwareText(context, m, textColor, mine),
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
                child: _replyQuote(context, m, mine)),
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
              child: _translatedAwareText(context, m, textColor, mine),
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
          if (m.hasReply) _replyQuote(context, m, mine),
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
          if (m.hasReply) _replyQuote(context, m, mine),
          _translatedAwareText(context, m, textColor, mine),
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
  Widget _orderCard(BuildContext context, MessageModel m, bool mine,
      String time, Color textColor) {
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
        if (m.text.isNotEmpty)
          _translatedAwareText(context, m, textColor, mine),
        const SizedBox(height: 8),
        InkWell(
          onTap: m.orderId.isEmpty ? null : () => onOrderTap(m.orderId),
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

  Widget _replyQuote(BuildContext context, MessageModel m, bool mine) {
    final t = AppLocalizations.of(context);
    return GestureDetector(
      onTap: () => onQuoteTap(m.replyToId),
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
}
