import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Admin app language (Russian default, English optional), persisted locally.
class LocaleProvider extends ChangeNotifier {
  static const _prefKey = 'admin_locale';
  static const supportedLocales = [Locale('ru'), Locale('en')];

  Locale _locale = const Locale('ru');
  Locale get locale => _locale;

  Future<void> load() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final code = prefs.getString(_prefKey);
      if (code == 'en' || code == 'ru') {
        _locale = Locale(code!);
        notifyListeners();
      }
    } catch (_) {}
  }

  Future<void> setLocale(String code) async {
    if (code != 'en' && code != 'ru') return;
    _locale = Locale(code);
    notifyListeners();
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_prefKey, code);
    } catch (_) {}
  }
}
