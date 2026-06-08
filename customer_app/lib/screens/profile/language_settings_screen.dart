import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../l10n/app_localizations.dart';
import '../../providers/auth_provider.dart';
import '../../providers/locale_provider.dart';
import '../../utils/app_colors.dart';
import '../../utils/app_text_styles.dart';
import '../../utils/constants.dart';

class LanguageSettingsScreen extends StatelessWidget {
  const LanguageSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final locale = context.watch<LocaleProvider>();
    final auth = context.read<AuthProvider>();

    return Scaffold(
      appBar: AppBar(title: Text(t.language)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: AppConstants.languages.map((lang) {
          final selected = locale.locale.languageCode == lang['code'];
          return Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: GestureDetector(
              onTap: () {
                locale.setLocale(Locale(lang['code']!));
                auth.updateFields({'language': lang['code']});
              },
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: selected ? AppColors.primary : AppColors.border,
                    width: selected ? 1.5 : 1,
                  ),
                ),
                child: Row(
                  children: [
                    Text(lang['flag']!, style: const TextStyle(fontSize: 26)),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(lang['native']!, style: AppTextStyles.headingM),
                          Text(lang['name']!, style: AppTextStyles.caption),
                        ],
                      ),
                    ),
                    if (selected)
                      const Icon(Icons.check_circle, color: AppColors.primary),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
