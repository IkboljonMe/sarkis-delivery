import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
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

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
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
                  auth.draft = null;
                  Navigator.pushNamed(context, '/phone');
                },
                child: Text(t.t('login'),
                    style: const TextStyle(
                        color: AppColors.primary,
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
