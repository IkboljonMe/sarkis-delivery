import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';

import '../../l10n/app_localizations.dart';
import '../../providers/auth_provider.dart';
import '../../utils/app_colors.dart';
import '../../utils/app_text_styles.dart';
import '../../widgets/brand_logo.dart';
import '../../widgets/golden_button.dart';

/// First screen for a logged-out / freshly installed app: choose to register a
/// new account or log in to an existing one.
class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  /// Google sign-in from the welcome screen. A returning Google user (already
  /// has a delivery address) goes straight in; a brand new one is sent to the
  /// registration flow to set their delivery location — nothing else is asked.
  Future<void> _continueWithGoogle(BuildContext context) async {
    final t = AppLocalizations.of(context);
    final auth = context.read<AuthProvider>();
    final ok = await auth.signInWithGoogle();
    if (!context.mounted) return;
    if (!ok) {
      if (auth.error != null) {
        Fluttertoast.showToast(msg: auth.error!);
        auth.resetError();
      }
      return; // cancelled or failed
    }
    if (auth.hasDeliveryAddress) {
      Navigator.pushNamedAndRemoveUntil(context, '/main', (r) => false);
    } else {
      auth.authMode = 'register';
      Fluttertoast.showToast(msg: t.t('setDeliveryLocation'));
      Navigator.pushNamedAndRemoveUntil(context, '/register', (r) => false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final auth = context.watch<AuthProvider>();
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Spacer(),
              const Center(child: BrandLogo(size: 104)),
              const SizedBox(height: 24),
              Text(t.welcome,
                  textAlign: TextAlign.center, style: AppTextStyles.headingL),
              const SizedBox(height: 8),
              Text(t.t('welcomeSubtitle'),
                  textAlign: TextAlign.center, style: AppTextStyles.caption),
              const SizedBox(height: 12),
              Text(t.t('welcomeBridge'),
                  textAlign: TextAlign.center,
                  style: AppTextStyles.caption
                      .copyWith(color: AppColors.primary)),
              const Spacer(),
              GoldenButton(
                label: t.t('register'),
                icon: Icons.person_add_alt_1,
                onPressed: () {
                  context.read<AuthProvider>().authMode = 'register';
                  Navigator.pushNamed(context, '/register');
                },
              ),
              const SizedBox(height: 12),
              OutlinedButton(
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size.fromHeight(56),
                  side: const BorderSide(color: AppColors.primary),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16)),
                ),
                onPressed: () {
                  final auth = context.read<AuthProvider>();
                  auth.authMode = 'login';
                  auth.clearDraft();
                  Navigator.pushNamed(context, '/phone');
                },
                child: Text(t.t('login'),
                    style: const TextStyle(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w600)),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  const Expanded(child: Divider(color: AppColors.border)),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Text(t.t('orDivider'), style: AppTextStyles.caption),
                  ),
                  const Expanded(child: Divider(color: AppColors.border)),
                ],
              ),
              const SizedBox(height: 20),
              OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size.fromHeight(56),
                  side: const BorderSide(color: AppColors.border),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16)),
                ),
                onPressed:
                    auth.busy ? null : () => _continueWithGoogle(context),
                icon: auth.busy
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: AppColors.primary),
                      )
                    : const Icon(Icons.g_mobiledata, size: 28),
                label: Text(t.t('continueWithGoogle'),
                    style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w600)),
              ),
              const SizedBox(height: 24),
            ],
          ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.05),
        ),
      ),
    );
  }
}
