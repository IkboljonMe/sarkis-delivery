import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../l10n/app_localizations.dart';
import '../../providers/locale_provider.dart';
import '../../utils/app_text_styles.dart';
import '../../utils/constants.dart';
import '../../widgets/language_option_tile.dart';

/// Lets the customer pick which language incoming chat messages are
/// translated into. Defaults to the app language until changed.
class TranslateLanguageScreen extends StatelessWidget {
  const TranslateLanguageScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final locale = context.watch<LocaleProvider>();

    return Scaffold(
      appBar: AppBar(title: Text(t.t('translateLanguage'))),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 4, bottom: 12),
            child: Text(t.t('translateLanguageHint'),
                style: AppTextStyles.caption),
          ),
          ...AppConstants.languages.map((lang) {
            return LanguageOptionTile(
              lang: lang,
              selected: locale.translateLang == lang['code'],
              onTap: () => locale.setTranslateLang(lang['code']!),
            );
          }),
        ],
      ),
    );
  }
}
