import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../utils/app_colors.dart';
import '../utils/app_text_styles.dart';

/// Friendly empty-state placeholder used on list screens.
class EmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;

  const EmptyState({
    super.key,
    this.icon = Icons.bakery_dining_outlined,
    required this.title,
    this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.primary.withOpacity(0.08),
                border: Border.all(color: AppColors.primary.withOpacity(0.2)),
              ),
              child: Icon(icon, size: 48, color: AppColors.primary),
            ),
            const SizedBox(height: 20),
            Text(title,
                textAlign: TextAlign.center, style: AppTextStyles.headingM),
            if (subtitle != null) ...[
              const SizedBox(height: 8),
              Text(subtitle!,
                  textAlign: TextAlign.center, style: AppTextStyles.caption),
            ],
          ],
        ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.05),
      ),
    );
  }
}
