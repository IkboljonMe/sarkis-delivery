import 'package:flutter_dotenv/flutter_dotenv.dart';

import '../demo_firebase_options.dart' show DemoFirebaseOptions;

/// App-wide constants for the admin app (Russian primary).
class AppConstants {
  AppConstants._();

  /// Google Cloud Translate API key, loaded from the bundled .env.
  static String get translateApiKey =>
      dotenv.maybeGet('GOOGLE_TRANSLATE_API_KEY') ?? '';

  static const String adminWhatsappNumber = 'YOUR_NUMBER_HERE';
  static String get firebaseProjectId =>
      DemoFirebaseOptions.current.projectId;

  // Groups are now admin-defined map regions (see RegionGroupService /
  // GroupProvider). A group's identifier is its name, so labels are identity.
  // The only fixed pseudo-group is "all" (every region).
  static const String groupAll = 'all';

  static bool isAllGroups(String g) => g == groupAll;

  static const List<String> languageCodes = ['en', 'hy', 'ru', 'tr', 'de'];
  static const Map<String, String> languageLabels = {
    'en': 'English',
    'hy': 'Հայերեն',
    'ru': 'Русский',
    'tr': 'Türkçe',
    'de': 'Deutsch',
  };

  static const String statusPending = 'pending';
  static const String statusConfirmed = 'confirmed';
  static const String statusOnTheWay = 'on_the_way';
  static const String statusDelivered = 'delivered';
  static const String statusCancelled = 'cancelled';

  static const String appVersion = '2.0.0';

  static const Map<String, String> statusRu = {
    statusPending: 'Новый',
    statusConfirmed: 'Подтверждён',
    statusOnTheWay: 'В пути',
    statusDelivered: 'Доставлен',
    statusCancelled: 'Отменён',
  };

  /// A group's display label. "all" is localized to "Все"; every other group
  /// id is already its human-readable name, so it is shown verbatim.
  static String groupLabel(String g) => g == groupAll ? 'Все' : g;
  static String statusLabel(String s) => statusRu[s] ?? s;

  /// Formats a monetary amount for display with the euro sign, e.g. `€12.50`.
  /// Defaults to two decimals; pass [decimals] for summary figures.
  static String price(double amount, {int decimals = 2}) =>
      '€${amount.toStringAsFixed(decimals)}';
}
