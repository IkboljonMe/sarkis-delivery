import 'dart:async';
import 'dart:typed_data';

import 'package:cross_file/cross_file.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';

/// Result of a finished recording.
class VoiceRecording {
  final Uint8List bytes;
  final int durationMs;
  final String ext;
  final String contentType;
  final List<int> waveform; // 0-100 amplitude bars for the player UI
  VoiceRecording(this.bytes, this.durationMs, this.ext, this.contentType,
      this.waveform);

  int get sizeBytes => bytes.length;
}

/// Thin wrapper over `record` that yields uploadable bytes + duration + a
/// sampled amplitude waveform, on both web (webm/opus) and mobile (m4a/aac).
class VoiceRecorder {
  final AudioRecorder _rec = AudioRecorder();
  DateTime? _startedAt;
  StreamSubscription<Amplitude>? _ampSub;
  final List<double> _amps = []; // raw dBFS samples while recording

  Future<bool> hasPermission() => _rec.hasPermission();

  Future<void> start() async {
    final config = RecordConfig(
        encoder: kIsWeb ? AudioEncoder.opus : AudioEncoder.aacLc);
    String path = '';
    if (!kIsWeb) {
      final dir = await getTemporaryDirectory();
      path = '${dir.path}/voice_${DateTime.now().millisecondsSinceEpoch}.m4a';
    }
    await _rec.start(config, path: path);
    _startedAt = DateTime.now();
    _amps.clear();
    _ampSub = _rec
        .onAmplitudeChanged(const Duration(milliseconds: 120))
        .listen((a) => _amps.add(a.current));
  }

  /// Stops and returns the recording, or null if nothing was captured.
  Future<VoiceRecording?> stop() async {
    await _ampSub?.cancel();
    _ampSub = null;
    final path = await _rec.stop();
    final ms = _startedAt == null
        ? 0
        : DateTime.now().difference(_startedAt!).inMilliseconds;
    _startedAt = null;
    if (path == null || path.isEmpty) return null;
    final bytes = await XFile(path).readAsBytes();
    final wave = _buildWaveform();
    return VoiceRecording(
      bytes,
      ms,
      kIsWeb ? 'webm' : 'm4a',
      kIsWeb ? 'audio/webm' : 'audio/mp4',
      wave,
    );
  }

  /// Normalizes the raw dBFS samples into ~44 bars of height 6..100.
  List<int> _buildWaveform() {
    const bars = 44;
    const floor = -50.0; // dBFS treated as silence
    final norm = _amps
        .map((db) => ((db - floor) / -floor).clamp(0.0, 1.0))
        .toList();
    if (norm.isEmpty) return List.filled(bars, 8);
    final out = <int>[];
    final bucket = norm.length / bars;
    for (var i = 0; i < bars; i++) {
      final start = (i * bucket).floor();
      final end = ((i + 1) * bucket).ceil().clamp(start + 1, norm.length);
      var sum = 0.0;
      for (var j = start; j < end; j++) {
        sum += norm[j];
      }
      final avg = sum / (end - start);
      out.add((6 + avg * 94).round().clamp(6, 100));
    }
    return out;
  }

  Future<void> cancel() async {
    await _ampSub?.cancel();
    _ampSub = null;
    try {
      await _rec.stop();
    } catch (_) {}
    _startedAt = null;
  }

  Future<void> dispose() async {
    await _ampSub?.cancel();
    return _rec.dispose();
  }
}
