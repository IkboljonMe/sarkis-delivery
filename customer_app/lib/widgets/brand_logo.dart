import 'package:flutter/material.dart';

import '../utils/app_colors.dart';

/// Sarkis Delivery brand mark: a gold-gradient rounded badge with a custom
/// painted delivery location-pin. Use [BrandLogo] for the badge alone, or
/// [BrandLogo.wordmark] for the badge beside the "Sarkis Delivery" wordmark.
class BrandLogo extends StatelessWidget {
  final double size;
  final bool showWordmark;

  const BrandLogo({super.key, this.size = 56}) : showWordmark = false;
  const BrandLogo.wordmark({super.key, this.size = 44}) : showWordmark = true;

  @override
  Widget build(BuildContext context) {
    final badge = Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        gradient: AppColors.goldGradient,
        borderRadius: BorderRadius.circular(size * 0.28),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.35),
            blurRadius: size * 0.25,
            offset: Offset(0, size * 0.08),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.all(size * 0.24),
        child: CustomPaint(painter: _PinPainter()),
      ),
    );

    if (!showWordmark) return badge;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        badge,
        SizedBox(width: size * 0.32),
        Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Sarkis',
              style: TextStyle(
                fontSize: size * 0.46,
                height: 1.0,
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimary,
                letterSpacing: 0.2,
              ),
            ),
            Text(
              'DELIVERY',
              style: TextStyle(
                fontSize: size * 0.26,
                height: 1.2,
                fontWeight: FontWeight.w600,
                color: AppColors.primary,
                letterSpacing: size * 0.10,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

/// Draws a rounded location pin (teardrop head + point) in white with a
/// gold "hole", scaled to fill the canvas.
class _PinPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final cx = w / 2;
    final white = Paint()
      ..color = Colors.white
      ..isAntiAlias = true
      ..style = PaintingStyle.fill;

    final headC = Offset(cx, h * 0.36);
    final headR = w * 0.34;
    final tip = Offset(cx, h * 0.98);

    // Teardrop = head circle + triangle converging to the tip.
    final dx = headR * 0.80;
    final shoulderY = headC.dy + headR * 0.55;
    final body = Path()
      ..moveTo(cx - dx, shoulderY)
      ..lineTo(cx + dx, shoulderY)
      ..lineTo(tip.dx, tip.dy)
      ..close();
    canvas.drawPath(body, white);
    canvas.drawCircle(headC, headR, white);

    // Gold hole so it reads as a pin.
    canvas.drawCircle(headC, headR * 0.40, Paint()..color = AppColors.primary);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
