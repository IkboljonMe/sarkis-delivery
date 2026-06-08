import 'dart:convert';

import 'package:http/http.dart' as http;

import '../utils/constants.dart';

/// Google Cloud Translate (v2) wrapper for the in-chat translate button.
class TranslateService {
  TranslateService._();

  /// Translates [text] into [target] (an ISO code like 'ru', 'de').
  /// Returns null on failure or when the key is missing.
  static Future<String?> translate(String text, String target) async {
    final key = AppConstants.translateApiKey;
    if (key.isEmpty || text.trim().isEmpty) return null;
    final uri = Uri.https(
        'translation.googleapis.com', '/language/translate/v2', {'key': key});
    try {
      final res = await http
          .post(uri,
              headers: {'Content-Type': 'application/json'},
              body: jsonEncode({'q': text, 'target': target, 'format': 'text'}))
          .timeout(const Duration(seconds: 12));
      if (res.statusCode != 200) return null;
      final data = jsonDecode(res.body) as Map<String, dynamic>;
      final translations =
          (data['data']?['translations']) as List?;
      if (translations == null || translations.isEmpty) return null;
      return translations.first['translatedText'] as String?;
    } catch (_) {
      return null;
    }
  }
}
