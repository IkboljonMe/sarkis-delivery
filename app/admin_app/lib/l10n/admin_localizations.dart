import 'package:flutter/material.dart';

import 'admin_strings.dart';

/// Hand-written localization for the admin app. `t(key)` looks up the active
/// language (ru | en) and falls back to Russian.
class AdminLocalizations {
  final Locale locale;
  late final Map<String, String> _s;

  AdminLocalizations(this.locale) {
    _s = locale.languageCode == 'en' ? kEn : kRu;
  }

  static AdminLocalizations of(BuildContext context) =>
      Localizations.of<AdminLocalizations>(context, AdminLocalizations) ??
      AdminLocalizations(const Locale('ru'));

  static const LocalizationsDelegate<AdminLocalizations> delegate = _Delegate();

  String t(String key) => _s[key] ?? kRu[key] ?? key;
}

class _Delegate extends LocalizationsDelegate<AdminLocalizations> {
  const _Delegate();

  @override
  bool isSupported(Locale locale) => ['ru', 'en'].contains(locale.languageCode);

  @override
  Future<AdminLocalizations> load(Locale locale) async =>
      AdminLocalizations(locale);

  @override
  bool shouldReload(_Delegate old) => false;
}
