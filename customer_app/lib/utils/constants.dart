/// App-wide constants and configuration values.
/// Replace placeholder values before shipping (see docs/ and .env.example).
class AppConstants {
  AppConstants._();

  // --- External keys / accounts (replace these) ---
  static const String googleGeocodingApiKey = 'YOUR_KEY_HERE';
  static const String adminWhatsappNumber = 'YOUR_NUMBER_HERE'; // e.g. 49170...
  static const String adminUid = 'HjygD2zQpKZ0zakT0JZWFvc3GcA3';

  // --- Groups ---
  static const String groupBerlin = 'Berlin';
  static const String groupHamburg = 'Hamburg';

  // --- Postal code ranges ---
  static const int berlinPostalMin = 10000;
  static const int berlinPostalMax = 14999;
  static const int hamburgPostalMin = 20000;
  static const int hamburgPostalMax = 22999;

  // --- Order quantity defaults (overridden by settings/config) ---
  static const int defaultMinQty = 1;
  static const int defaultMaxQty = 10;

  // --- Supported languages ---
  static const List<String> supportedLanguages = ['en', 'hy', 'ru', 'tr', 'de'];

  /// Maps a German postal code to a delivery group, or null if outside ranges.
  static String? groupForPostalCode(String postalCode) {
    final code = int.tryParse(postalCode.trim());
    if (code == null) return null;
    if (code >= berlinPostalMin && code <= berlinPostalMax) return groupBerlin;
    if (code >= hamburgPostalMin && code <= hamburgPostalMax) {
      return groupHamburg;
    }
    return null;
  }

  // --- Country codes for phone login ---
  static const List<Map<String, String>> countryCodes = [
    {'code': '+49', 'flag': '🇩🇪', 'name': 'DE'},
    {'code': '+374', 'flag': '🇦🇲', 'name': 'AM'},
    {'code': '+7', 'flag': '🇷🇺', 'name': 'RU'},
    {'code': '+90', 'flag': '🇹🇷', 'name': 'TR'},
  ];

  // --- Order statuses ---
  static const String statusPending = 'pending';
  static const String statusConfirmed = 'confirmed';
  static const String statusOnTheWay = 'on_the_way';
  static const String statusDelivered = 'delivered';
  static const String statusCancelled = 'cancelled';
}
