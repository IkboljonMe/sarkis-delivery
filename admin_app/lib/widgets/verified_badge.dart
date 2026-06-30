import 'package:flutter/material.dart';

import '../utils/app_colors.dart';

/// Small "verified customer" check shown next to a name. Renders nothing when
/// [verified] is false so it can be dropped inline anywhere.
class VerifiedBadge extends StatelessWidget {
  final bool verified;
  final double size;
  const VerifiedBadge({super.key, required this.verified, this.size = 16});

  @override
  Widget build(BuildContext context) {
    if (!verified) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(left: 4),
      child: Icon(Icons.verified, size: size, color: AppColors.primary),
    );
  }
}
