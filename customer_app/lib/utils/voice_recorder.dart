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
  VoiceRecording(this.bytes, this.durationMs, this.ext, this.contentType);
}

/// Thin wrapper over `record` that yields uploadable bytes + duration and
/// works on both web (webm/opus) and mobile (m4a/aac).
class VoiceRecorder {
  final AudioRecorder _rec = AudioRecorder();
  DateTime? _startedAt;

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
  }

  /// Stops and returns the recording, or null if nothing was captured.
  Future<VoiceRecording?> stop() async {
    final path = await _rec.stop();
    final ms = _startedAt == null
        ? 0
        : DateTime.now().difference(_startedAt!).inMilliseconds;
    _startedAt = null;
    if (path == null || path.isEmpty) return null;
    final bytes = await XFile(path).readAsBytes();
    return VoiceRecording(
      bytes,
      ms,
      kIsWeb ? 'webm' : 'm4a',
      kIsWeb ? 'audio/webm' : 'audio/mp4',
    );
  }

  Future<void> cancel() async {
    try {
      await _rec.stop();
    } catch (_) {}
    _startedAt = null;
  }

  Future<void> dispose() => _rec.dispose();
}
