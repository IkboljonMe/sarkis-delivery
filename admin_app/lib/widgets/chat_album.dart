import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../utils/app_colors.dart';
import 'photo_viewer.dart';

/// Inline chat photos: a single compact thumbnail, or a 2-column mosaic for an
/// album. Tapping any photo opens the swipeable fullscreen [PhotoViewer].
class ChatAlbum extends StatelessWidget {
  final List<String> urls;
  const ChatAlbum({super.key, required this.urls});

  void _open(BuildContext context, int index) {
    Navigator.push(
      context,
      MaterialPageRoute(
          builder: (_) => PhotoViewer(urls: urls, initialIndex: index)),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (urls.isEmpty) return const SizedBox.shrink();

    if (urls.length == 1) {
      return GestureDetector(
        onTap: () => _open(context, 0),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 220, maxHeight: 280),
            child: _img(urls.first),
          ),
        ),
      );
    }

    // Album: show up to 4 tiles, "+N" overlay on the last when there are more.
    final shown = urls.length > 4 ? 4 : urls.length;
    return SizedBox(
      width: 230,
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        padding: EdgeInsets.zero,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 3,
          mainAxisSpacing: 3,
        ),
        itemCount: shown,
        itemBuilder: (context, i) {
          final extra = (i == shown - 1) ? urls.length - shown : 0;
          return GestureDetector(
            onTap: () => _open(context, i),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  _img(urls[i]),
                  if (extra > 0)
                    Container(
                      color: Colors.black54,
                      alignment: Alignment.center,
                      child: Text('+$extra',
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 22,
                              fontWeight: FontWeight.bold)),
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _img(String url) => CachedNetworkImage(
        imageUrl: url,
        fit: BoxFit.cover,
        placeholder: (_, __) =>
            Container(color: AppColors.surfaceElevated, height: 110),
        errorWidget: (_, __, ___) => Container(
          color: AppColors.surfaceElevated,
          child: const Icon(Icons.broken_image, color: AppColors.textMuted),
        ),
      );
}
