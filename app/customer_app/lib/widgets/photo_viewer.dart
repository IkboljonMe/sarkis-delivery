import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

/// Fullscreen, swipeable photo viewer (Telegram-style): pinch-zoom, swipe
/// left/right between photos in an album, back button top-left, page counter.
class PhotoViewer extends StatefulWidget {
  final List<String> urls;
  final int initialIndex;
  const PhotoViewer({super.key, required this.urls, this.initialIndex = 0});

  @override
  State<PhotoViewer> createState() => _PhotoViewerState();
}

class _PhotoViewerState extends State<PhotoViewer> {
  late final PageController _page =
      PageController(initialPage: widget.initialIndex);
  late int _index = widget.initialIndex;

  @override
  void dispose() {
    _page.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          PageView.builder(
            controller: _page,
            onPageChanged: (i) => setState(() => _index = i),
            itemCount: widget.urls.length,
            itemBuilder: (context, i) => InteractiveViewer(
              minScale: 1,
              maxScale: 4,
              child: Center(
                child: CachedNetworkImage(
                  imageUrl: widget.urls[i],
                  fit: BoxFit.contain,
                  placeholder: (_, __) => const Center(
                      child: CircularProgressIndicator(color: Colors.white)),
                  errorWidget: (_, __, ___) => const Icon(Icons.broken_image,
                      color: Colors.white54, size: 48),
                ),
              ),
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: Row(
                children: [
                  _circle(
                    Icons.arrow_back,
                    () => Navigator.pop(context),
                  ),
                  const Spacer(),
                  if (widget.urls.length > 1)
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.black54,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text('${_index + 1} / ${widget.urls.length}',
                          style: const TextStyle(color: Colors.white)),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _circle(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40,
        height: 40,
        decoration: const BoxDecoration(
            color: Colors.black54, shape: BoxShape.circle),
        child: Icon(icon, color: Colors.white),
      ),
    );
  }
}
