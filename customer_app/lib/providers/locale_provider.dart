import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../utils/constants.dart';

class LocaleProvider extends ChangeNotifier {
  static const _prefKey = 'app_locale';
  static const _translatePrefKey = 'translate_lang';

  Locale _locale = const Locale('en');
  Locale get locale => _locale;
  bool _chosen = false;
  bool get hasChosenLanguage => _chosen;

  // Language that incoming chat messages are translated to.
  // Defaults to the app language until the user picks one explicitly.
  String? _translateLang;
  String get translateLang => _translateLang ?? _locale.languageCode;

  Future<void> setTranslateLang(String code) async {
    if (!AppConstants.supportedLanguages.contains(code)) return;
    _translateLang = code;
    notifyListeners();
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_translatePrefKey, code);
    } catch (_) {}
  }

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
      }
      final tr = prefs.getString(_translatePrefKey);
      if (tr != null && AppConstants.supportedLanguages.contains(tr)) {
        _translateLang = tr;
      }
      notifyListeners();
    } catch (_) {}
  }

  /// When the user hasn't explicitly picked a language yet, default to the
  /// phone's language if we support it, otherwise English.
  void initFromDevice() {
    if (_chosen) return;
    final code =
        WidgetsBinding.instance.platformDispatcher.locale.languageCode;
    _locale = AppConstants.supportedLanguages.contains(code)
        ? Locale(code)
        : const Locale('en');
    notifyListeners();
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
