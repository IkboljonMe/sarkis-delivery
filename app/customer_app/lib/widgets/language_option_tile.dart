import 'package:flutter/material.dart';

import '../utils/app_colors.dart';
import '../utils/app_text_styles.dart';

/// A single selectable language row: flag, native + English name, and a check
/// when selected. Shared by the app-language and chat-translation pickers so
/// the option markup lives in exactly one place.
class LanguageOptionTile extends StatelessWidget {
  const LanguageOptionTile({
    super.key,
    required this.lang,
    required this.selected,
    required this.onTap,
  });

  /// One entry from [AppConstants.languages] — keys: code, flag, native, name.
  final Map<String, String> lang;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: GestureDetector(
        onTap: onTap,
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
  }
}
