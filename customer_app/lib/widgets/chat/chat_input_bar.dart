import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';
import '../../utils/app_colors.dart';
import '../../utils/app_text_styles.dart';

/// Bottom composer row: attach + text field, or the hold-to-record voice strip
/// with slide-to-cancel, plus the send / mic button. Presentational: recording
/// state lives in the owning screen and is passed in with callbacks.
class ChatInputBar extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode inputFocus;
  final bool recording;
  final int recSeconds;
  final double recDrag;
  final VoidCallback onAttach;
  final VoidCallback onSend;
  final VoidCallback onRecordStart;
  final void Function(double deltaDx) onRecordMove;
  final VoidCallback onRecordEnd;
  final VoidCallback onRecordCancel;

  const ChatInputBar({
    super.key,
    required this.controller,
    required this.inputFocus,
    required this.recording,
    required this.recSeconds,
    required this.recDrag,
    required this.onAttach,
    required this.onSend,
    required this.onRecordStart,
    required this.onRecordMove,
    required this.onRecordEnd,
    required this.onRecordCancel,
  });

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final hasText = controller.text.trim().isNotEmpty;
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(6, 8, 12, 8),
        child: Row(
          children: [
            if (recording)
              Expanded(child: _recordingStrip(t))
            else ...[
              IconButton(
                onPressed: onAttach,
                icon: const Icon(Icons.attach_file, color: AppColors.primary),
              ),
              Expanded(
                child: TextField(
                  controller: controller,
                  focusNode: inputFocus,
                  style: AppTextStyles.body,
                  minLines: 1,
                  maxLines: 4,
                  decoration: InputDecoration(hintText: t.sendMessage),
                ),
              ),
            ],
            const SizedBox(width: 8),
            if (hasText && !recording)
              _circleBtn(icon: Icons.send, onTap: onSend)
            else
              // Hold-to-record (Telegram-style): press to start, release to
              // send, slide left to cancel. The button stays mounted across
              // the recording state so the pointer-up still reaches it.
              Listener(
                onPointerDown: (_) => onRecordStart(),
                onPointerMove: (e) => onRecordMove(e.delta.dx),
                onPointerUp: (_) => onRecordEnd(),
                onPointerCancel: (_) => onRecordCancel(),
                child: _circleBtn(
                    icon: recording ? Icons.send : Icons.mic, onTap: null),
              ),
          ],
        ),
      ),
    );
  }

  Widget _recordingStrip(AppLocalizations t) {
    return Row(
      children: [
        const _RecDot(),
        const SizedBox(width: 8),
        Text(_fmtSeconds(recSeconds), style: AppTextStyles.bodyBold),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            recDrag < -40 ? t.t('releaseToCancel') : t.t('slideToCancel'),
            overflow: TextOverflow.ellipsis,
            style: AppTextStyles.caption.copyWith(color: AppColors.error),
          ),
        ),
      ],
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
