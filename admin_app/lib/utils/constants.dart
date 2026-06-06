import '../demo_firebase_options.dart' show DemoFirebaseOptions;

/// App-wide constants for the admin app (Russian primary).
class AppConstants {
  AppConstants._();

  static const String adminWhatsappNumber = 'YOUR_NUMBER_HERE';
  static String get firebaseProjectId =>
      DemoFirebaseOptions.current.projectId;

  static const String groupBerlin = 'Berlin';
  static const String groupHamburg = 'Hamburg';
  static const List<String> groups = [groupBerlin, groupHamburg];

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

  static const Map<String, String> groupRu = {
    groupBerlin: 'Берлин',
    groupHamburg: 'Гамбург',
  };

  static String groupLabel(String g) => groupRu[g] ?? g;
  static String statusLabel(String s) => statusRu[s] ?? s;
}
