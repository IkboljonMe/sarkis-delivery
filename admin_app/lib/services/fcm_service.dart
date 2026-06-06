import 'dart:convert';

import 'package:googleapis_auth/auth_io.dart';
import 'package:http/http.dart' as http;

import '../utils/constants.dart';

/// Sends push notifications to customers via the FCM HTTP v1 API.
///
/// SECURITY: the HTTP v1 API needs an OAuth2 token signed by a service account.
/// Shipping a service-account key in an app is insecure — for production, move
/// this to a Cloud Function and call it from the app. Paste your key below for
/// local testing only; never commit a real key.
class FcmService {
  FcmService._();
  static final FcmService instance = FcmService._();

  static const Map<String, dynamic> _serviceAccount = {
    "type": "service_account",
    "project_id": "sarkisbread",
    "private_key_id": "YOUR_PRIVATE_KEY_ID",
    "private_key": "-----BEGIN PRIVATE KEY-----\\nYOUR_KEY\\n-----END PRIVATE KEY-----\\n",
    "client_email": "YOUR_SERVICE_ACCOUNT_EMAIL",
    "client_id": "YOUR_CLIENT_ID",
    "token_uri": "https://oauth2.googleapis.com/token",
  };

  static const _scopes = ['https://www.googleapis.com/auth/firebase.messaging'];

  Future<String?> _accessToken() async {
    try {
      final creds = ServiceAccountCredentials.fromJson(_serviceAccount);
      final client = await clientViaServiceAccount(creds, _scopes);
      final token = client.credentials.accessToken.data;
      client.close();
      return token;
    } catch (_) {
      return null;
    }
  }

  Future<bool> sendToUser(
    String fcmToken,
    String title,
    String body, {
    Map<String, String>? data,
  }) async {
    if (fcmToken.isEmpty) return false;
    final token = await _accessToken();
    if (token == null) return false;

    final url = Uri.parse(
      'https://fcm.googleapis.com/v1/projects/'
      '${AppConstants.firebaseProjectId}/messages:send',
    );
    try {
      final res = await http.post(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'message': {
            'token': fcmToken,
            'notification': {'title': title, 'body': body},
            if (data != null) 'data': data,
            'android': {'priority': 'high'},
          },
        }),
      );
      return res.statusCode == 200;
    } catch (_) {
      return false;
    }
  }

  /// Sends to many tokens (broadcast). Returns count of successful sends.
  Future<int> sendToMany(
    List<String> tokens,
    String title,
    String body,
  ) async {
    int ok = 0;
    for (final t in tokens) {
      if (await sendToUser(t, title, body)) ok++;
    }
    return ok;
  }
}
