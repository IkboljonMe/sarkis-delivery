import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../utils/app_colors.dart';
import 'photo_viewer.dart';

/// Inline chat photos with Telegram-like mosaics that avoid empty gaps on odd
/// counts. While an album is still uploading, [pendingCount] extra tiles show
/// a spinner until their URL arrives.
class ChatAlbum extends StatelessWidget {
  final List<String> urls;
  final int pendingCount;
  const ChatAlbum({super.key, required this.urls, this.pendingCount = 0});

  static const double _w = 224; // overall album width
  static const double _gap = 3;

  int get _total => urls.length + pendingCount;

  void _open(BuildContext context, int index) {
    if (index >= urls.length) return; // not uploaded yet
    Navigator.push(
      context,
      MaterialPageRoute(
          builder: (_) => PhotoViewer(urls: urls, initialIndex: index)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final n = _total;
    if (n == 0) return const SizedBox.shrink();

    if (n == 1) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: SizedBox(width: 220, height: 240, child: _slot(context, 0)),
      );
    }
    if (n == 2) {
      return SizedBox(
        width: _w,
        height: 130,
        child: Row(children: [
          Expanded(child: _slot(context, 0)),
          const SizedBox(width: _gap),
          Expanded(child: _slot(context, 1)),
        ]),
      );
    }
    if (n == 3) {
      // One tall photo on the left, two stacked on the right.
      return SizedBox(
        width: _w,
        height: 160,
        child: Row(children: [
          Expanded(flex: 3, child: _slot(context, 0)),
          const SizedBox(width: _gap),
          Expanded(
            flex: 2,
            child: Column(children: [
              Expanded(child: _slot(context, 1)),
              const SizedBox(height: _gap),
              Expanded(child: _slot(context, 2)),
            ]),
          ),
        ]),
      );
    }
    // 4+: a 2x2 grid; a 5th-and-beyond count collapses into a "+N" overlay.
    final extra = n - 4;
    return SizedBox(
      width: _w,
      height: _w,
      child: Column(children: [
        Expanded(
          child: Row(children: [
            Expanded(child: _slot(context, 0)),
            const SizedBox(width: _gap),
            Expanded(child: _slot(context, 1)),
          ]),
        ),
        const SizedBox(height: _gap),
        Expanded(
          child: Row(children: [
            Expanded(child: _slot(context, 2)),
            const SizedBox(width: _gap),
            Expanded(child: _slot(context, 3, extra: extra)),
          ]),
        ),
      ]),
    );
  }

  Widget _slot(BuildContext context, int i, {int extra = 0}) {
    final loaded = i < urls.length;
    return GestureDetector(
      onTap: () => _open(context, i),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Stack(
          fit: StackFit.expand,
          children: [
            if (loaded)
              _img(urls[i])
            else
              Container(
                color: AppColors.surfaceElevated,
                child: const Center(
                  child: SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(
                        strokeWidth: 2, color: AppColors.primary),
                  ),
                ),
              ),
            if (extra > 0 && loaded)
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
  }

  Widget _img(String url) => CachedNetworkImage(
        imageUrl: url,
        fit: BoxFit.cover,
        placeholder: (_, __) =>
            Container(color: AppColors.surfaceElevated),
        errorWidget: (_, __, ___) => Container(
          color: AppColors.surfaceElevated,
          child: const Icon(Icons.broken_image, color: AppColors.textMuted),
        ),
      );
}
