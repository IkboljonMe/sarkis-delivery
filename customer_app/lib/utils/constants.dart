import '../demo_firebase_options.dart' show DemoFirebaseOptions;

/// App-wide constants and configuration.
class AppConstants {
  AppConstants._();

  // --- External keys / accounts (replace for production) ---
  static const String adminWhatsappNumber = 'YOUR_NUMBER_HERE';
  static const String adminUid = 'HjygD2zQpKZ0zakT0JZWFvc3GcA3';

  // Firebase project id (mirrors DemoFirebaseOptions.current.projectId).
  static String get firebaseProjectId =>
      DemoFirebaseOptions.current.projectId;

  // --- Groups ---
  static const String groupBerlin = 'Berlin';
  static const String groupHamburg = 'Hamburg';
  static const List<String> groups = [groupBerlin, groupHamburg];

  // --- Postal ranges ---
  static const int berlinMin = 10000;
  static const int berlinMax = 14999;
  static const int hamburgMin = 20000;
  static const int hamburgMax = 22999;

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
    if (code >= berlinMin && code <= berlinMax) return groupBerlin;
    if (code >= hamburgMin && code <= hamburgMax) return groupHamburg;
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
