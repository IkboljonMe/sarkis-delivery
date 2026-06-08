import 'package:flutter/material.dart';

import '../utils/app_colors.dart';

/// A chat image thumbnail that opens fullscreen (pinch-to-zoom) on tap.
class ChatImage extends StatelessWidget {
  final String url;
  const ChatImage({super.key, required this.url});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _open(context),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: Image.network(
          url,
          width: 200,
          fit: BoxFit.cover,
          loadingBuilder: (c, child, p) => p == null
              ? child
              : Container(
                  width: 200,
                  height: 150,
                  color: AppColors.surfaceElevated,
                  alignment: Alignment.center,
                  child: const CircularProgressIndicator(strokeWidth: 2),
                ),
          errorBuilder: (c, e, s) => Container(
            width: 200,
            height: 120,
            color: AppColors.surfaceElevated,
            alignment: Alignment.center,
            child: const Icon(Icons.broken_image, color: AppColors.textMuted),
          ),
        ),
      ),
    );
  }

  void _open(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        backgroundColor: Colors.black,
        insetPadding: const EdgeInsets.all(8),
        child: Stack(
          alignment: Alignment.center,
          children: [
            InteractiveViewer(
              maxScale: 5,
              child: Center(child: Image.network(url)),
            ),
            Positioned(
              top: 8,
              right: 8,
              child: IconButton(
                icon: const Icon(Icons.close, color: Colors.white),
                onPressed: () => Navigator.pop(ctx),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
