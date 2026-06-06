import 'package:flutter/material.dart';

import 'app_strings.dart';

/// Hand-written localization. `t(key)` looks up the active language and falls
/// back to English. Named getters cover the commonly used keys.
class AppLocalizations {
  final Locale locale;
  late final Map<String, String> _s;

  AppLocalizations(this.locale) {
    _s = _all[locale.languageCode] ?? kEn;
  }

  static const Map<String, Map<String, String>> _all = {
    'en': kEn,
    'hy': kHy,
    'ru': kRu,
    'tr': kTr,
    'de': kDe,
  };

  static AppLocalizations of(BuildContext context) =>
      Localizations.of<AppLocalizations>(context, AppLocalizations) ??
      AppLocalizations(const Locale('en'));

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _Delegate();

  /// Generic lookup with English fallback.
  String t(String key) => _s[key] ?? kEn[key] ?? key;

  // Convenience getters (safe Dart names).
  String get appName => t('appName');
  String get welcome => t('welcome');
  String get chooseLanguage => t('chooseLanguage');
  String get continueLabel => t('continue');
  String get back => t('back');
  String get save => t('save');
  String get cancel => t('cancel');
  String get orderPlaced => t('orderPlaced');
  String get orderSuccess => t('orderSuccess');
  String get orderTotal => t('orderTotal');
  String get orderId => t('orderId');
  String get myOrders => t('myOrders');
  String get activeOrders => t('activeOrders');
  String get completedOrders => t('completedOrders');
  String get noOrders => t('noOrders');
  String get deliveries => t('deliveries');
  String get noDeliveries => t('noDeliveries');
  String get products => t('products');
  String get categories => t('categories');
  String get cart => t('cart');
  String get cartEmpty => t('cartEmpty');
  String get quantity => t('quantity');
  String get total => t('total');
  String get free => t('free');
  String get delivery => t('delivery');
  String get cashOnDelivery => t('cashOnDelivery');
  String get orderNow => t('orderNow');
  String get viewCart => t('viewCart');
  String get clearCart => t('clearCart');
  String get placeOrder => t('placeOrder');
  String get areYouSure => t('areYouSure');
  String get yesConfirm => t('yesConfirm');
  String get noGoBack => t('noGoBack');
  String get chats => t('chats');
  String get messages => t('messages');
  String get sendMessage => t('sendMessage');
  String get noMessages => t('noMessages');
  String get profile => t('profile');
  String get name => t('name');
  String get phone => t('phone');
  String get address => t('address');
  String get city => t('city');
  String get postalCode => t('postalCode');
  String get yourGroup => t('yourGroup');
  String get contactAdmin => t('contactAdmin');
  String get logout => t('logout');
  String get logoutConfirm => t('logoutConfirm');
  String get language => t('language');
  String get enterPhone => t('enterPhone');
  String get enterOtp => t('enterOtp');
  String get resendCode => t('resendCode');
  String get fullName => t('fullName');
  String get yourAddress => t('yourAddress');
  String get confirmDetails => t('confirmDetails');
  String get loading => t('loading');
  String get error => t('error');
  String get retry => t('retry');
  String get copied => t('copied');
  String get driverComing => t('driverComing');
  String get home => t('home');
  String get continueWithSms => t('continueWithSms');
  String get contactWhatsApp => t('contactWhatsApp');

  String statusLabel(String status) {
    switch (status) {
      case 'pending':
        return t('statusPending');
      case 'confirmed':
        return t('statusConfirmed');
      case 'on_the_way':
        return t('statusOnTheWay');
      case 'delivered':
        return t('statusDelivered');
      case 'cancelled':
        return t('statusCancelled');
      default:
        return status;
    }
  }
}

class _Delegate extends LocalizationsDelegate<AppLocalizations> {
  const _Delegate();

  @override
  bool isSupported(Locale locale) =>
      ['en', 'hy', 'ru', 'tr', 'de'].contains(locale.languageCode);

  @override
  Future<AppLocalizations> load(Locale locale) async =>
      AppLocalizations(locale);

  @override
  bool shouldReload(_Delegate old) => false;
}
