import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

/// Bundled open-source Lottie animations (lottie-flutter examples, MIT).
/// Single source of truth for animation asset paths.
class AppAnim {
  AppAnim._();
  static const _base = 'assets/animations';
  static const success = '$_base/success.json'; // celebratory burst
  static const loading = '$_base/loading.json'; // lightweight loader
  static const thumbsUp = '$_base/thumbs_up.json'; // friendly empty state
  static const envelope = '$_base/envelope.json'; // empty chat / messages
}

/// Thin, consistent wrapper around [Lottie.asset] so sizing/looping is uniform
/// across the app and callers don't repeat boilerplate.
class LottieView extends StatelessWidget {
  const LottieView(
    this.asset, {
    super.key,
    this.size = 140,
    this.repeat = true,
  });

  final String asset;
  final double size;
  final bool repeat;

  @override
  Widget build(BuildContext context) {
    return Lottie.asset(
      asset,
      width: size,
      height: size,
      repeat: repeat,
      fit: BoxFit.contain,
    );
  }
}

/// Small inline loading animation, a drop-in for CircularProgressIndicator.
class AppLoader extends StatelessWidget {
  const AppLoader({super.key, this.size = 64});

  final double size;

  @override
  Widget build(BuildContext context) {
    return Center(child: LottieView(AppAnim.loading, size: size));
  }
}
