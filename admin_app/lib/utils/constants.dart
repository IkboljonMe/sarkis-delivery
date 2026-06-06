/// App-wide constants for the admin app.
class AppConstants {
  AppConstants._();

  static const String adminUid = 'HjygD2zQpKZ0zakT0JZWFvc3GcA3';
  static const String adminWhatsappNumber = 'YOUR_NUMBER_HERE';

  // Firebase project id — used by fcm_service for the HTTP v1 endpoint.
  static const String firebaseProjectId = 'sarkisbread';

  static const String groupBerlin = 'Berlin';
  static const String groupHamburg = 'Hamburg';
  static const List<String> groups = [groupBerlin, groupHamburg];

  static const List<String> languageCodes = ['en', 'hy', 'ru', 'tr', 'de'];

  // Order statuses
  static const String statusPending = 'pending';
  static const String statusConfirmed = 'confirmed';
  static const String statusOnTheWay = 'on_the_way';
  static const String statusDelivered = 'delivered';
  static const String statusCancelled = 'cancelled';

  static const String appVersion = '1.0.0';

  // Russian status labels
  static const Map<String, String> statusLabelsRu = {
    statusPending: 'Новый',
    statusConfirmed: 'Подтверждён',
    statusOnTheWay: 'В пути',
    statusDelivered: 'Доставлен',
    statusCancelled: 'Отменён',
  };

  // Russian group labels
  static const Map<String, String> groupLabelsRu = {
    groupBerlin: 'Берлин',
    groupHamburg: 'Гамбург',
  };
}
