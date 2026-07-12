import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';

import '../utils/app_colors.dart';

/// Telegram-style voice player: play/pause, an amplitude waveform you can tap
/// to seek, duration + file size, and a playback-speed toggle. Shows a spinner
/// instead of play while the audio is still uploading.
class VoiceBubble extends StatefulWidget {
  final String url;
  final int durationMs;
  final bool mine;
  final List<int> waveform;
  final int sizeBytes;
  final bool uploading;
  const VoiceBubble({
    super.key,
    required this.url,
    required this.durationMs,
    required this.mine,
    this.waveform = const [],
    this.sizeBytes = 0,
    this.uploading = false,
  });

  @override
  State<VoiceBubble> createState() => _VoiceBubbleState();
}

class _VoiceBubbleState extends State<VoiceBubble> {
  AudioPlayer? _player;
  bool _playing = false;
  Duration _pos = Duration.zero;
  late Duration _total = Duration(milliseconds: widget.durationMs);
  double _speed = 1.0;

  @override
  void dispose() {
    _player?.dispose();
    super.dispose();
  }

  Future<void> _toggle() async {
    if (widget.uploading || widget.url.isEmpty) return;
    final p = _player ??= _createPlayer();
    if (_playing) {
      await p.pause();
      setState(() => _playing = false);
    } else {
      await p.play(UrlSource(widget.url));
      await p.setPlaybackRate(_speed);
      setState(() => _playing = true);
    }
  }

  Future<void> _cycleSpeed() async {
    _speed = _speed == 1.0
        ? 1.5
        : _speed == 1.5
            ? 2.0
            : 1.0;
    await _player?.setPlaybackRate(_speed);
    setState(() {});
  }

  Future<void> _seekFraction(double f) async {
    final p = _player;
    if (p == null) return;
    final ms = (_total.inMilliseconds * f.clamp(0, 1)).round();
    await p.seek(Duration(milliseconds: ms));
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

  String get _sizeLabel {
    if (widget.sizeBytes <= 0) return '';
    final kb = widget.sizeBytes / 1024;
    return kb >= 1024
        ? '${(kb / 1024).toStringAsFixed(1)} MB'
        : '${kb.toStringAsFixed(1)} KB';
  }

  @override
  Widget build(BuildContext context) {
    final fg = widget.mine ? Colors.white : AppColors.primary;
    final track = widget.mine ? Colors.white38 : AppColors.border;
    final total = _total.inMilliseconds == 0 ? 1 : _total.inMilliseconds;
    final progress = (_pos.inMilliseconds / total).clamp(0.0, 1.0);
    final muted = widget.mine ? Colors.white70 : AppColors.textSecondary;

    return SizedBox(
      width: 216,
      child: Row(
        children: [
          GestureDetector(
            onTap: _toggle,
            child: widget.uploading
                ? SizedBox(
                    width: 34,
                    height: 34,
                    child: Padding(
                      padding: const EdgeInsets.all(6),
                      child: CircularProgressIndicator(
                          strokeWidth: 2.5, color: fg),
                    ),
                  )
                : Icon(
                    _playing
                        ? Icons.pause_circle_filled
                        : Icons.play_circle_fill,
                    color: fg,
                    size: 34),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                LayoutBuilder(
                  builder: (context, c) => GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTapDown: (d) =>
                        _seekFraction(d.localPosition.dx / c.maxWidth),
                    child: _Waveform(
                      bars: widget.waveform,
                      progress: progress,
                      active: fg,
                      track: track,
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Text(
                      _playing || _pos > Duration.zero
                          ? _fmt(_pos)
                          : _fmt(_total),
                      style: TextStyle(fontSize: 11, color: muted),
                    ),
                    if (_sizeLabel.isNotEmpty) ...[
                      Text('  ·  ',
                          style: TextStyle(fontSize: 11, color: muted)),
                      Text(_sizeLabel,
                          style: TextStyle(fontSize: 11, color: muted)),
                    ],
                  ],
                ),
              ],
            ),
          ),
          if (_playing)
            GestureDetector(
              onTap: _cycleSpeed,
              child: Container(
                margin: const EdgeInsets.only(left: 6),
                padding:
                    const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: fg.withOpacity(0.18),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                    _speed == 1.0
                        ? '1x'
                        : _speed == 1.5
                            ? '1.5x'
                            : '2x',
                    style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: fg)),
              ),
            ),
        ],
      ),
    );
  }
}

/// A row of amplitude bars; bars left of [progress] use [active], rest [track].
class _Waveform extends StatelessWidget {
  final List<int> bars;
  final double progress;
  final Color active;
  final Color track;
  const _Waveform({
    required this.bars,
    required this.progress,
    required this.active,
    required this.track,
  });

  @override
  Widget build(BuildContext context) {
    final data = bars.isEmpty ? List.filled(28, 24) : bars;
    return SizedBox(
      height: 26,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: List.generate(data.length, (i) {
          final h = (data[i] / 100 * 24).clamp(3.0, 24.0);
          final played = (i / data.length) <= progress;
          return Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 0.7),
              child: Container(
                height: h,
                decoration: BoxDecoration(
                  color: played ? active : track,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}
