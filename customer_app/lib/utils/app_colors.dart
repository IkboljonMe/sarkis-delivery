import 'package:flutter/material.dart';

/// Central color palette for the Sarkis Bread dark premium design system.
class AppColors {
  AppColors._();

  static const Color background = Color(0xFF0A0A0A);
  static const Color surface = Color(0xFF141414);
  static const Color surfaceElevated = Color(0xFF1E1E1E);

  static const Color primary = Color(0xFFC8972A); // warm gold
  static const Color primaryLight = Color(0xFFE8B84B);
  static const Color primaryDark = Color(0xFFA07820);
  static const Color accent = Color(0xFFFF6B35); // orange CTA

  static const Color textPrimary = Color(0xFFF5F5F5);
  static const Color textSecondary = Color(0xFF9E9E9E);
  static const Color textMuted = Color(0xFF616161);

  static const Color success = Color(0xFF4CAF50);
  static const Color warning = Color(0xFFFF9800);
  static const Color error = Color(0xFFF44336);
  static const Color border = Color(0xFF2A2A2A);

  static const Color gradientStart = Color(0xFFC8972A);
  static const Color gradientEnd = Color(0xFFFF6B35);

  /// Primary -> Accent gradient at 135deg (used by GoldenButton, bubbles).
  static const LinearGradient goldGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [gradientStart, gradientEnd],
  );

  /// Status colors used by order badges across both apps.
  static Color statusColor(String status) {
    switch (status) {
      case 'pending':
        return warning;
      case 'confirmed':
        return const Color(0xFF42A5F5);
      case 'on_the_way':
        return const Color(0xFFAB47BC);
      case 'delivered':
        return success;
      case 'cancelled':
        return error;
      default:
        return textSecondary;
    }
  }
}
