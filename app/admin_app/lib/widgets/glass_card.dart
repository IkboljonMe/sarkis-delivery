import 'dart:ui';

import 'package:flutter/material.dart';

/// Frosted glass card using a BackdropFilter blur.
class GlassCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry? margin;
  final VoidCallback? onTap;
  final double blur;
  final double radius;

  const GlassCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.margin,
    this.onTap,
    this.blur = 10,
    this.radius = 20,
  });

  @override
  Widget build(BuildContext context) {
    final content = ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
        child: Container(
          padding: padding,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.04),
            borderRadius: BorderRadius.circular(radius),
            border: Border.all(color: Colors.white.withOpacity(0.08)),
          ),
          child: child,
        ),
      ),
    );

    final wrapped = Container(margin: margin, child: content);
    if (onTap == null) return wrapped;
    return GestureDetector(onTap: onTap, child: wrapped);
  }
}
