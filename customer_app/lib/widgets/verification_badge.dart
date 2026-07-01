import 'package:flutter/material.dart';

import '../utils/app_colors.dart';

/// Account verification mark: a blue seal when verified, a red X when not.
/// Small enough to drop inline next to a name.
class VerificationBadge extends StatelessWidget {
  final bool verified;
  final double size;
  const VerificationBadge({super.key, required this.verified, this.size = 18});

  static const Color verifiedBlue = Color(0xFF1DA1F2);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 6),
      child: Icon(
        verified ? Icons.verified : Icons.cancel,
        size: size,
        color: verified ? verifiedBlue : AppColors.error,
      ),
    );
  }
}
