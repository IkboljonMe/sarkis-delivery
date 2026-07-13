import 'api_client.dart';

/// Asks the backend whether a phone number already belongs to a registered
/// customer (`GET /v1/users/phone-exists`).
class PhoneCheckService {
  PhoneCheckService._();
  static final PhoneCheckService instance = PhoneCheckService._();

  final ApiClient _api = ApiClient.instance;

  /// Returns true/false if known, or null when the check couldn't run
  /// (offline). Callers must treat null as "unknown" and NOT block
  /// registration.
  Future<bool?> exists(String e164Phone) async {
    if (e164Phone.trim().isEmpty) return null;
    try {
      final res = await _api
          .get('/v1/users/phone-exists?phone=${Uri.encodeComponent(e164Phone)}');
      final data = res;
      if (data is Map && data['exists'] is bool) return data['exists'] as bool;
      return null;
    } catch (_) {
      return null;
    }
  }
}
