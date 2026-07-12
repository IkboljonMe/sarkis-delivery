import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:fluttertoast/fluttertoast.dart';

import '../../l10n/app_localizations.dart';
import '../../utils/app_colors.dart';
import '../../utils/app_text_styles.dart';
import '../../widgets/app_lottie.dart';
import '../../widgets/golden_button.dart';

class OrderSuccessScreen extends StatefulWidget {
  final String orderId;
  const OrderSuccessScreen({super.key, required this.orderId});

  @override
  State<OrderSuccessScreen> createState() => _OrderSuccessScreenState();
}

class _OrderSuccessScreenState extends State<OrderSuccessScreen> {
  late final ConfettiController _confetti;

  @override
  void initState() {
    super.initState();
    _confetti = ConfettiController(duration: const Duration(seconds: 3));
    _confetti.play();
  }

  @override
  void dispose() {
    _confetti.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final shortId = widget.orderId
        .substring(0, widget.orderId.length < 6 ? widget.orderId.length : 6)
        .toUpperCase();

    return Scaffold(
      body: Stack(
        alignment: Alignment.topCenter,
        children: [
          // Celebratory burst behind the success card (plays once).
          Positioned(
            top: 40,
            child: IgnorePointer(
              child: LottieView(AppAnim.success, size: 320, repeat: false),
            ),
          ),
          Center(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.all(28),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.success.withOpacity(0.15),
                      border: Border.all(
                          color: AppColors.success.withOpacity(0.4)),
                    ),
                    child: const Icon(Icons.check_rounded,
                        size: 72, color: AppColors.success),
                  )
                      .animate()
                      .scale(duration: 500.ms, curve: Curves.easeOutBack),
                  const SizedBox(height: 24),
                  Text(t.orderPlaced, style: AppTextStyles.headingXL)
                      .animate()
                      .fadeIn(delay: 300.ms),
                  const SizedBox(height: 8),
                  Text(t.orderSuccess,
                      textAlign: TextAlign.center,
                      style: AppTextStyles.caption),
                  const SizedBox(height: 16),
                  GestureDetector(
                    onTap: () {
                      Clipboard.setData(ClipboardData(text: widget.orderId));
                      Fluttertoast.showToast(msg: t.copied);
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text('${t.orderId}: #$shortId',
                              style: AppTextStyles.body),
                          const SizedBox(width: 8),
                          const Icon(Icons.copy,
                              size: 16, color: AppColors.primary),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                  GoldenButton(
                    label: t.myOrders,
                    onPressed: () => Navigator.pushNamedAndRemoveUntil(
                        context, '/main', (r) => false),
                  ),
                  const SizedBox(height: 8),
                  TextButton(
                    onPressed: () => Navigator.pushNamedAndRemoveUntil(
                        context, '/main', (r) => false),
                    child: Text(t.home,
                        style:
                            const TextStyle(color: AppColors.textSecondary)),
                  ),
                ],
              ),
            ),
          ),
          ConfettiWidget(
            confettiController: _confetti,
            blastDirectionality: BlastDirectionality.explosive,
            colors: const [
              AppColors.primary,
              AppColors.accent,
              AppColors.primaryLight,
              Colors.white,
            ],
          ),
        ],
      ),
    );
  }
}
