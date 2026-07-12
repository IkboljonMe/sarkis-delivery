import 'package:flutter/material.dart';

import '../utils/app_colors.dart';
import '../utils/app_text_styles.dart';

/// Primary CTA button: gold->accent gradient, spring scale on press.
class GoldenButton extends StatefulWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool loading;
  final IconData? icon;
  final double height;

  const GoldenButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.loading = false,
    this.icon,
    this.height = 56,
  });

  @override
  State<GoldenButton> createState() => _GoldenButtonState();
}

class _GoldenButtonState extends State<GoldenButton> {
  double _scale = 1.0;

  void _setPressed(bool pressed) {
    if (widget.onPressed == null || widget.loading) return;
    setState(() => _scale = pressed ? 0.96 : 1.0);
  }

  @override
  Widget build(BuildContext context) {
    final enabled = widget.onPressed != null && !widget.loading;
    return GestureDetector(
      onTapDown: (_) => _setPressed(true),
      onTapUp: (_) => _setPressed(false),
      onTapCancel: () => _setPressed(false),
      onTap: enabled ? widget.onPressed : null,
      child: AnimatedScale(
        scale: _scale,
        duration: const Duration(milliseconds: 120),
        curve: Curves.easeOut,
        child: Opacity(
          opacity: enabled ? 1 : 0.5,
          child: Container(
            height: widget.height,
            decoration: BoxDecoration(
              gradient: AppColors.goldGradient,
              borderRadius: BorderRadius.circular(14),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withOpacity(0.35),
                  blurRadius: 24,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Center(
              child: widget.loading
                  ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                          color: Colors.white, strokeWidth: 2.4),
                    )
                  : Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (widget.icon != null) ...[
                          Icon(widget.icon, color: Colors.white, size: 20),
                          const SizedBox(width: 8),
                        ],
                        Text(widget.label, style: AppTextStyles.button),
                      ],
                    ),
            ),
          ),
        ),
      ),
    );
  }
}
