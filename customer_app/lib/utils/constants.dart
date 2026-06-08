import 'package:flutter_dotenv/flutter_dotenv.dart';

import '../demo_firebase_options.dart' show DemoFirebaseOptions;

/// App-wide constants and configuration.
class AppConstants {
  AppConstants._();

  // --- External keys / accounts (replace for production) ---
  static const String adminWhatsappNumber = 'YOUR_NUMBER_HERE';
  static const String adminUid = 'HjygD2zQpKZ0zakT0JZWFvc3GcA3';

  /// Google Geocoding + Static Maps API key, loaded from the bundled .env.
  static String get googleApiKey =>
      dotenv.maybeGet('GOOGLE_GEOCODING_API_KEY') ?? '';

  /// Google Cloud Translate API key, loaded from the bundled .env.
  static String get translateApiKey =>
      dotenv.maybeGet('GOOGLE_TRANSLATE_API_KEY') ?? '';

  // Firebase project id (mirrors DemoFirebaseOptions.current.projectId).
  static String get firebaseProjectId =>
      DemoFirebaseOptions.current.projectId;

  // --- Groups (Germany split into 4 big delivery regions) ---
  static const String groupBerlin = 'Berlin';
  static const String groupHamburg = 'Hamburg';
  static const String groupFrankfurt = 'Frankfurt';
  static const String groupMunich = 'München';
  static const List<String> groups = [
    groupBerlin,
    groupHamburg,
    groupFrankfurt,
    groupMunich,
  ];

  /// Postal-code ranges per group (German PLZ leading digits).
  static const Map<String, List<List<int>>> groupPostalRanges = {
    groupBerlin: [
      [10000, 14199]
    ],
    groupHamburg: [
      [20000, 22999]
    ],
    groupFrankfurt: [
      [60000, 65999]
    ],
    groupMunich: [
      [80000, 85999]
    ],
  };

  /// Display label for a group (currently the city name itself).
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

  /// Maps a German postal code to a delivery group, or null if outside ranges.
  static String? groupForPostalCode(String postalCode) {
    final code = int.tryParse(postalCode.trim());
    if (code == null) return null;
    for (final entry in groupPostalRanges.entries) {
      for (final range in entry.value) {
        if (code >= range[0] && code <= range[1]) return entry.key;
      }
    }
    return null;
  }

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
