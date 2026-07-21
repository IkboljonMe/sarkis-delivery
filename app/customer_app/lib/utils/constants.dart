import 'package:flutter_dotenv/flutter_dotenv.dart';

/// App-wide constants and configuration.
class AppConstants {
  AppConstants._();

  // --- External keys / accounts (replace for production) ---
  /// Admin contact number in international format. REPLACE before release.
  /// Used for both the WhatsApp link and the direct phone call.
  static const String adminPhoneNumber = '+48 600 516 406';

  /// Digits-only form for wa.me links (no '+', spaces or symbols).
  static String get adminPhoneDigits =>
      adminPhoneNumber.replaceAll(RegExp(r'\D'), '');

  /// Back-compat alias used by the settings WhatsApp shortcut.
  static String get adminWhatsappNumber => adminPhoneDigits;

  /// Public website (Next.js). REPLACE with the deployed domain after hosting
  /// the `landing/` project. Used for the shareable download link and the
  /// Privacy / Terms links shown in registration and settings.
  static const String webBaseUrl = 'https://sarkis-delivery.vercel.app';
  static const String termsUrl = '$webBaseUrl/terms';
  static const String privacyUrl = '$webBaseUrl/privacy';

  /// Base URL of the backend API (no trailing slash). Override via the
  /// bundled .env (API_BASE_URL) — e.g. the laptop's LAN IP during device
  /// testing, the VPS domain in production. 10.0.2.2 reaches the host from
  /// the Android emulator.
  static String get apiBaseUrl =>
      dotenv.maybeGet('API_BASE_URL') ?? 'http://10.0.2.2:3000';

  /// Google Geocoding + Static Maps API key, loaded from the bundled .env.
  static String get googleApiKey =>
      dotenv.maybeGet('GOOGLE_GEOCODING_API_KEY') ?? '';

  /// Google Cloud Translate API key, loaded from the bundled .env.
  static String get translateApiKey =>
      dotenv.maybeGet('GOOGLE_TRANSLATE_API_KEY') ?? '';

  // --- Groups ---
  // Delivery groups are now admin-drawn map regions (collection
  // `regionGroups`), resolved by point-in-polygon. A group's id is its name.

  /// Display label for a group (the group name itself).
  static String groupLabel(String g) => g;

  static const int defaultMinQty = 1;
  static const int defaultMaxQty = 10;

  static const List<String> supportedLanguages = ['en', 'hy', 'ru', 'tr', 'de'];

  // --- Order statuses ---
  static const String statusPending = 'pending';
  static const String statusConfirmed = 'confirmed';
  static const String statusOnTheWay = 'on_the_way';
  static const String statusDelivered = 'delivered';
  static const String statusCancelled = 'cancelled';

  static const String appVersion = '2.0.0';

  static const List<Map<String, String>> countryCodes = [
    {'code': '+49', 'flag': '🇩🇪', 'name': 'DE'},
    {'code': '+374', 'flag': '🇦🇲', 'name': 'AM'},
    {'code': '+7', 'flag': '🇷🇺', 'name': 'RU'},
    {'code': '+90', 'flag': '🇹🇷', 'name': 'TR'},
  ];

  static const List<Map<String, String>> languages = [
    {'code': 'en', 'flag': '🇬🇧', 'name': 'English', 'native': 'English'},
    {'code': 'hy', 'flag': '🇦🇲', 'name': 'Armenian', 'native': 'Հայերեն'},
    {'code': 'ru', 'flag': '🇷🇺', 'name': 'Russian', 'native': 'Русский'},
    {'code': 'tr', 'flag': '🇹🇷', 'name': 'Turkish', 'native': 'Türkçe'},
    {'code': 'de', 'flag': '🇩🇪', 'name': 'German', 'native': 'Deutsch'},
  ];
}
