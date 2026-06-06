import 'package:flutter/material.dart';

import 'strings_en.dart';
import 'strings_hy.dart';
import 'strings_ru.dart';
import 'strings_tr.dart';
import 'strings_de.dart';

/// Hand-written localization for the customer app. Strings are sourced from the
/// per-language maps (which mirror the lib/l10n/app_*.arb files).
class AppLocalizations {
  final Locale locale;
  late final Map<String, String> _strings;

  AppLocalizations(this.locale) {
    _strings = _all[locale.languageCode] ?? stringsEn;
  }

  static const Map<String, Map<String, String>> _all = {
    'en': stringsEn,
    'hy': stringsHy,
    'ru': stringsRu,
    'tr': stringsTr,
    'de': stringsDe,
  };

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations) ??
        AppLocalizations(const Locale('en'));
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  String _s(String key) => _strings[key] ?? stringsEn[key] ?? key;

  String get appName => _s('appName');
  String get home => _s('home');
  String get myOrders => _s('myOrders');
  String get messages => _s('messages');
  String get profile => _s('profile');
  String get placeOrder => _s('placeOrder');
  String get orderPlaced => _s('orderPlaced');
  String get orderSuccess => _s('orderSuccess');
  String get orderTotal => _s('orderTotal');
  String get deliveryDate => _s('deliveryDate');
  String get group => _s('group');
  String get status => _s('status');
  String get quantity => _s('quantity');
  String get price => _s('price');
  String get pending => _s('pending');
  String get confirmed => _s('confirmed');
  String get onTheWay => _s('onTheWay');
  String get delivered => _s('delivered');
  String get cancelled => _s('cancelled');
  String get noDeliveryDates => _s('noDeliveryDates');
  String get contactWhatsApp => _s('contactWhatsApp');
  String get logout => _s('logout');
  String get logoutConfirm => _s('logoutConfirm');
  String get isThisYourAddress => _s('isThisYourAddress');
  String get yes => _s('yes');
  String get no => _s('no');
  String get edit => _s('edit');
  String get save => _s('save');
  String get cancel => _s('cancel');
  String get enterPhone => _s('enterPhone');
  String get enterOTP => _s('enterOTP');
  String get resendCode => _s('resendCode');
  String get nextButton => _s('nextButton');
  String get yourName => _s('yourName');
  String get yourAddress => _s('yourAddress');
  String get yourCity => _s('yourCity');
  String get yourPostalCode => _s('yourPostalCode');
  String get selectLanguage => _s('selectLanguage');
  String get berlin => _s('berlin');
  String get hamburg => _s('hamburg');
  String get cashOnDelivery => _s('cashOnDelivery');
  String get unreadMessages => _s('unreadMessages');
  String get loading => _s('loading');
  String get error => _s('error');
  String get retry => _s('retry');
  String get noOrders => _s('noOrders');
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) =>
      ['en', 'hy', 'ru', 'tr', 'de'].contains(locale.languageCode);

  @override
  Future<AppLocalizations> load(Locale locale) async =>
      AppLocalizations(locale);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}
