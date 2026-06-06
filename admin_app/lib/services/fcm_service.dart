import 'dart:convert';

import 'package:googleapis_auth/auth_io.dart';
import 'package:http/http.dart' as http;

import '../utils/constants.dart';

/// Sends push notifications to customers via the FCM HTTP v1 API.
///
/// NOTE: The HTTP v1 API requires an OAuth2 access token signed with a
/// service-account key. Shipping a service-account key inside a mobile app is
/// insecure — for production you should move this logic to a Cloud Function and
/// have the admin app call that function. This implementation is provided so the
/// flow is complete and testable; replace [_serviceAccountJson] with your key,
/// or point [sendNotificationToUser] at your Cloud Function endpoint.
class FcmService {
  FcmService._();
  static final FcmService instance = FcmService._();

  /// Paste the service-account JSON here (DO NOT commit a real key to git).
  static const Map<String, dynamic> _serviceAccountJson = {
    "type": "service_account",
    "project_id": "YOUR_FIREBASE_PROJECT_ID",
    "private_key_id": "YOUR_PRIVATE_KEY_ID",
    "private_key": "-----BEGIN PRIVATE KEY-----\\nYOUR_KEY\\n-----END PRIVATE KEY-----\\n",
    "client_email": "YOUR_SERVICE_ACCOUNT_EMAIL",
    "client_id": "YOUR_CLIENT_ID",
    "token_uri": "https://oauth2.googleapis.com/token",
  };

  static const _scopes = [
    'https://www.googleapis.com/auth/firebase.messaging',
  ];

  AccessCredentials? _cachedCredentials;

  Future<String?> _accessToken() async {
    try {
      final now = DateTime.now().toUtc();
      if (_cachedCredentials != null &&
          _cachedCredentials!.accessToken.expiry.isAfter(
              now.add(const Duration(minutes: 1)))) {
        return _cachedCredentials!.accessToken.data;
      }
      final accountCredentials =
          ServiceAccountCredentials.fromJson(_serviceAccountJson);
      final client = await clientViaServiceAccount(accountCredentials, _scopes);
      _cachedCredentials = client.credentials;
      final token = client.credentials.accessToken.data;
      client.close();
      return token;
    } catch (e) {
      return null;
    }
  }

  /// Sends a notification to a single device token. Returns true on success.
  Future<bool> sendNotificationToUser(
    String fcmToken,
    String title,
    String body, {
    Map<String, String>? data,
  }) async {
    if (fcmToken.isEmpty) return false;
    final accessToken = await _accessToken();
    if (accessToken == null) return false;

    final projectId = AppConstants.firebaseProjectId;
    final url = Uri.parse(
      'https://fcm.googleapis.com/v1/projects/$projectId/messages:send',
    );

    final payload = {
      'message': {
        'token': fcmToken,
        'notification': {'title': title, 'body': body},
        if (data != null) 'data': data,
        'android': {'priority': 'high'},
      },
    };

    try {
      final response = await http.post(
        url,
        headers: {
          'Authorization': 'Bearer $accessToken',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(payload),
      );
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }
}
