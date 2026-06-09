import 'package:flutter/material.dart';

import '../utils/app_colors.dart';
import 'video_player_screen.dart';

/// A video message preview: a dark tile with a play button (or a spinner while
/// uploading). Tapping opens the fullscreen player.
class VideoBubble extends StatelessWidget {
  final String url;
  final int sizeBytes;
  final bool uploading;
  const VideoBubble({
    super.key,
    required this.url,
    this.sizeBytes = 0,
    this.uploading = false,
  });

  String get _sizeLabel {
    if (sizeBytes <= 0) return 'Видео';
    final mb = sizeBytes / (1024 * 1024);
    return mb >= 1
        ? '🎥 ${mb.toStringAsFixed(1)} MB'
        : '🎥 ${(sizeBytes / 1024).toStringAsFixed(0)} KB';
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: (uploading || url.isEmpty)
          ? null
          : () => Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (_) => VideoPlayerScreen(url: url)),
              ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: Container(
          width: 220,
          height: 150,
          color: Colors.black,
          child: Stack(
            fit: StackFit.expand,
            children: [
              Center(
                child: uploading
                    ? const SizedBox(
                        width: 30,
                        height: 30,
                        child: CircularProgressIndicator(
                            strokeWidth: 2.5, color: Colors.white),
                      )
                    : const Icon(Icons.play_circle_fill,
                        size: 56, color: Colors.white),
              ),
              Positioned(
                left: 8,
                bottom: 8,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.black54,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(_sizeLabel,
                      style: const TextStyle(
                          color: Colors.white, fontSize: 11)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
