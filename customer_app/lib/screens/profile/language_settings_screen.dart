import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../l10n/app_localizations.dart';
import '../../providers/auth_provider.dart';
import '../../providers/locale_provider.dart';
import '../../utils/constants.dart';
import '../../widgets/language_option_tile.dart';

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
          return LanguageOptionTile(
            lang: lang,
            selected: locale.locale.languageCode == lang['code'],
            onTap: () {
              locale.setLocale(Locale(lang['code']!));
              auth.updateFields({'language': lang['code']});
            },
          );
        }).toList(),
      ),
    );
  }
}
