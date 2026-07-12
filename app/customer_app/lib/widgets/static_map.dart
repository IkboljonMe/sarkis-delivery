import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../utils/app_colors.dart';

/// A non-interactive Google Static Map showing a single marker. Used to let the
/// customer confirm the geocoded address is correct.
class StaticMap extends StatelessWidget {
  final double lat;
  final double lng;
  final String apiKey;
  final int zoom;
  final double height;

  const StaticMap({
    super.key,
    required this.lat,
    required this.lng,
    required this.apiKey,
    this.zoom = 16,
    this.height = 180,
  });

  String get _url {
    final center = '$lat,$lng';
    return Uri.https('maps.googleapis.com', '/maps/api/staticmap', {
      'center': center,
      'zoom': '$zoom',
      'size': '640x360',
      'scale': '2',
      'maptype': 'roadmap',
      'markers': 'color:0xD4AF37|$center',
      'key': apiKey,
    }).toString();
  }

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: CachedNetworkImage(
        imageUrl: _url,
        height: height,
        width: double.infinity,
        fit: BoxFit.cover,
        placeholder: (_, __) => Container(
          height: height,
          color: AppColors.surfaceElevated,
          child: const Center(child: CircularProgressIndicator()),
        ),
        errorWidget: (_, __, ___) => Container(
          height: height,
          color: AppColors.surfaceElevated,
          alignment: Alignment.center,
          child: const Icon(Icons.map_outlined,
              color: AppColors.textMuted, size: 40),
        ),
      ),
    );
  }
}
