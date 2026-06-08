import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';

import '../utils/app_colors.dart';

/// A voice-message player: play/pause + progress + duration.
class VoiceBubble extends StatefulWidget {
  final String url;
  final int durationMs;
  final bool mine;
  const VoiceBubble({
    super.key,
    required this.url,
    required this.durationMs,
    required this.mine,
  });

  @override
  State<VoiceBubble> createState() => _VoiceBubbleState();
}

class _VoiceBubbleState extends State<VoiceBubble> {
  AudioPlayer? _player;
  bool _playing = false;
  Duration _pos = Duration.zero;
  late Duration _total = Duration(milliseconds: widget.durationMs);

  @override
  void dispose() {
    _player?.dispose();
    super.dispose();
  }

  Future<void> _toggle() async {
    final p = _player ??= _createPlayer();
    if (_playing) {
      await p.pause();
      setState(() => _playing = false);
    } else {
      await p.play(UrlSource(widget.url));
      setState(() => _playing = true);
    }
  }

  AudioPlayer _createPlayer() {
    final p = AudioPlayer();
    p.onPositionChanged.listen((d) {
      if (mounted) setState(() => _pos = d);
    });
    p.onDurationChanged.listen((d) {
      if (mounted && d > Duration.zero) setState(() => _total = d);
    });
    p.onPlayerComplete.listen((_) {
      if (mounted) {
        setState(() {
          _playing = false;
          _pos = Duration.zero;
        });
      }
    });
    return p;
  }

  String _fmt(Duration d) {
    final m = d.inMinutes.remainder(60).toString();
    final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  @override
  Widget build(BuildContext context) {
    final fg = widget.mine ? Colors.white : AppColors.primary;
    final track = widget.mine ? Colors.white30 : AppColors.border;
    final total = _total.inMilliseconds == 0 ? 1 : _total.inMilliseconds;
    final progress = (_pos.inMilliseconds / total).clamp(0.0, 1.0);

    return SizedBox(
      width: 190,
      child: Row(
        children: [
          GestureDetector(
            onTap: _toggle,
            child: Icon(
                _playing ? Icons.pause_circle_filled : Icons.play_circle_fill,
                color: fg,
                size: 34),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(2),
                  child: LinearProgressIndicator(
                    value: progress,
                    minHeight: 4,
                    backgroundColor: track,
                    valueColor: AlwaysStoppedAnimation(fg),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _playing || _pos > Duration.zero
                      ? '${_fmt(_pos)} / ${_fmt(_total)}'
                      : _fmt(_total),
                  style: TextStyle(
                      fontSize: 11,
                      color: widget.mine
                          ? Colors.white70
                          : AppColors.textSecondary),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
