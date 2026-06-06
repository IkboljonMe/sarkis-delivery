import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../utils/constants.dart';

class LocaleProvider extends ChangeNotifier {
  static const _prefKey = 'app_locale';

  Locale _locale = const Locale('en');
  Locale get locale => _locale;
  bool _chosen = false;
  bool get hasChosenLanguage => _chosen;

  static const List<Locale> supportedLocales = [
    Locale('en'),
    Locale('hy'),
    Locale('ru'),
    Locale('tr'),
    Locale('de'),
  ];

  Future<void> load() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final code = prefs.getString(_prefKey);
      if (code != null && AppConstants.supportedLanguages.contains(code)) {
        _locale = Locale(code);
        _chosen = true;
        notifyListeners();
      }
    } catch (_) {}
  }

  Future<void> setLocale(Locale locale) async {
    if (!AppConstants.supportedLanguages.contains(locale.languageCode)) return;
    _locale = locale;
    _chosen = true;
    notifyListeners();
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_prefKey, locale.languageCode);
    } catch (_) {}
  }
}
