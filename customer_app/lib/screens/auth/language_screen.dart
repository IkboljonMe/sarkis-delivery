import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';

import '../../providers/locale_provider.dart';
import '../../utils/app_colors.dart';
import '../../utils/app_text_styles.dart';
import '../../utils/constants.dart';
import '../../widgets/golden_button.dart';

class LanguageScreen extends StatefulWidget {
  const LanguageScreen({super.key});

  @override
  State<LanguageScreen> createState() => _LanguageScreenState();
}

class _LanguageScreenState extends State<LanguageScreen> {
  String _selected = 'en';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 20),
              Text('Choose your language', style: AppTextStyles.headingL),
              Text('Ընտրեք լեզուն · Выберите язык · Dil seçin · Sprache',
                  style: AppTextStyles.caption),
              const SizedBox(height: 24),
              Expanded(
                child: ListView.builder(
                  itemCount: AppConstants.languages.length,
                  itemBuilder: (context, i) {
                    final lang = AppConstants.languages[i];
                    final selected = _selected == lang['code'];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: GestureDetector(
                        onTap: () =>
                            setState(() => _selected = lang['code']!),
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: AppColors.surface,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: selected
                                  ? AppColors.primary
                                  : AppColors.border,
                              width: selected ? 1.5 : 1,
                            ),
                          ),
                          child: Row(
                            children: [
                              Text(lang['flag']!,
                                  style: const TextStyle(fontSize: 28)),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  children: [
                                    Text(lang['native']!,
                                        style: AppTextStyles.headingM),
                                    Text(lang['name']!,
                                        style: AppTextStyles.caption),
                                  ],
                                ),
                              ),
                              if (selected)
                                const Icon(Icons.check_circle,
                                    color: AppColors.primary),
                            ],
                          ),
                        ),
                      ),
                    )
                        .animate()
                        .fadeIn(delay: (80 * i).ms, duration: 350.ms)
                        .slideX(begin: 0.1);
                  },
                ),
              ),
              GoldenButton(
                label: 'Continue',
                onPressed: () async {
                  await context
                      .read<LocaleProvider>()
                      .setLocale(Locale(_selected));
                  if (context.mounted) {
                    Navigator.pushReplacementNamed(context, '/phone');
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
