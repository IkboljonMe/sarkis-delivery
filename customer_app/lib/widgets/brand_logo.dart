import 'package:flutter/material.dart';

import '../utils/app_colors.dart';

/// Sarkis Bread brand mark: a gold-gradient rounded badge with a custom
/// painted wheat sheaf. Use [BrandLogo] for the badge alone, or
/// [BrandLogo.wordmark] for the badge beside the "Sarkis Bread" wordmark.
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
        padding: EdgeInsets.all(size * 0.22),
        child: CustomPaint(painter: _WheatPainter()),
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

/// Draws a symmetric wheat sheaf (central stalk + angled grain pairs) in white,
/// scaled to fill the given canvas.
class _WheatPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final cx = w / 2;
    final stroke = Paint()
      ..color = Colors.white
      ..strokeWidth = w * 0.06
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;
    final fill = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    // Central stalk.
    canvas.drawLine(
        Offset(cx, h * 0.18), Offset(cx, h * 0.96), stroke);

    // Grain pairs down the stalk.
    final grainLen = w * 0.30;
    final grainW = w * 0.13;
    for (var i = 0; i < 4; i++) {
      final y = h * (0.22 + i * 0.18);
      _grain(canvas, fill, Offset(cx, y), grainLen, grainW, left: true);
      _grain(canvas, fill, Offset(cx, y), grainLen, grainW, left: false);
    }
    // Top grain crowning the stalk.
    _topGrain(canvas, fill, Offset(cx, h * 0.16), grainW * 1.1, h * 0.20);
  }

  void _grain(Canvas canvas, Paint paint, Offset base, double len, double width,
      {required bool left}) {
    final dir = left ? -1.0 : 1.0;
    final tip = Offset(base.dx + dir * len * 0.78, base.dy - len * 0.62);
    final mid = Offset((base.dx + tip.dx) / 2, (base.dy + tip.dy) / 2);
    final perp = Offset(dir * width * 0.5, width * 0.5);
    final path = Path()
      ..moveTo(base.dx, base.dy)
      ..quadraticBezierTo(mid.dx + perp.dx, mid.dy + perp.dy, tip.dx, tip.dy)
      ..quadraticBezierTo(mid.dx - perp.dx, mid.dy - perp.dy, base.dx, base.dy)
      ..close();
    canvas.drawPath(path, paint);
  }

  void _topGrain(
      Canvas canvas, Paint paint, Offset top, double width, double len) {
    final base = Offset(top.dx, top.dy + len);
    final path = Path()
      ..moveTo(base.dx, base.dy)
      ..quadraticBezierTo(top.dx + width, (top.dy + base.dy) / 2, top.dx, top.dy)
      ..quadraticBezierTo(top.dx - width, (top.dy + base.dy) / 2, base.dx, base.dy)
      ..close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
