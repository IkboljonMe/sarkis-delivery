import 'package:flutter/material.dart';

import '../utils/app_colors.dart';

/// Sarko Driver brand mark: the rounded "S-route" logo image. Use [BrandLogo]
/// for the mark alone, or [BrandLogo.wordmark] for the mark beside the
/// "Sarko / DRIVER" lockup.
class BrandLogo extends StatelessWidget {
  final double size;
  final bool showWordmark;

  const BrandLogo({super.key, this.size = 56}) : showWordmark = false;
  const BrandLogo.wordmark({super.key, this.size = 44}) : showWordmark = true;

  @override
  Widget build(BuildContext context) {
    final mark = Image.asset(
      'assets/icon/logo_s.png',
      width: size,
      height: size,
      fit: BoxFit.contain,
      filterQuality: FilterQuality.high,
    );

    if (!showWordmark) return mark;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        mark,
        SizedBox(width: size * 0.24),
        Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Sarko',
              style: TextStyle(
                fontSize: size * 0.46,
                height: 1.0,
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimary,
                letterSpacing: 0.2,
              ),
            ),
            Text(
              'DRIVER',
              style: TextStyle(
                fontSize: size * 0.24,
                height: 1.3,
                fontWeight: FontWeight.w700,
                color: AppColors.brandOrange,
                letterSpacing: size * 0.085,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
