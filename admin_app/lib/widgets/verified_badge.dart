import 'package:flutter/material.dart';

import '../utils/app_colors.dart';

/// Small verification indicator shown next to a name: a blue "verified" seal
/// when [verified] is true, or a red X when the customer is not verified. Can
/// be dropped inline anywhere.
class VerifiedBadge extends StatelessWidget {
  final bool verified;
  final double size;
  const VerifiedBadge({super.key, required this.verified, this.size = 16});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 4),
      child: verified
          ? Icon(Icons.verified, size: size, color: const Color(0xFF1DA1F2))
          : Icon(Icons.cancel, size: size, color: AppColors.error),
    );
  }
}
