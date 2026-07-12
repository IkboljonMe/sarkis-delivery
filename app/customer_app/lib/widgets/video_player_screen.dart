import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

import '../utils/app_colors.dart';

/// Minimal fullscreen video player (tap to play/pause, scrub bar, back button).
class VideoPlayerScreen extends StatefulWidget {
  final String url;
  const VideoPlayerScreen({super.key, required this.url});

  @override
  State<VideoPlayerScreen> createState() => _VideoPlayerScreenState();
}

class _VideoPlayerScreenState extends State<VideoPlayerScreen> {
  late final VideoPlayerController _c;
  bool _ready = false;

  @override
  void initState() {
    super.initState();
    _c = VideoPlayerController.networkUrl(Uri.parse(widget.url))
      ..initialize().then((_) {
        if (!mounted) return;
        setState(() => _ready = true);
        _c.play();
      });
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  void _toggle() {
    setState(() => _c.value.isPlaying ? _c.pause() : _c.play());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          Center(
            child: _ready
                ? GestureDetector(
                    onTap: _toggle,
                    child: AspectRatio(
                      aspectRatio: _c.value.aspectRatio == 0
                          ? 16 / 9
                          : _c.value.aspectRatio,
                      child: VideoPlayer(_c),
                    ),
                  )
                : const CircularProgressIndicator(color: AppColors.primary),
          ),
          if (_ready)
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: VideoProgressIndicator(
                _c,
                allowScrubbing: true,
                colors: const VideoProgressColors(
                    playedColor: AppColors.primary),
              ),
            ),
          if (_ready && !_c.value.isPlaying)
            const Center(
              child: Icon(Icons.play_circle_fill,
                  size: 72, color: Colors.white70),
            ),
          SafeArea(
            child: Align(
              alignment: Alignment.topLeft,
              child: IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () => Navigator.pop(context),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
