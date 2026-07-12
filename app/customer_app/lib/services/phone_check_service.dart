import 'package:cloud_functions/cloud_functions.dart';

/// Asks the backend whether a phone number already belongs to a registered
/// customer (callable Cloud Function `phoneExists`).
class PhoneCheckService {
  PhoneCheckService._();
  static final PhoneCheckService instance = PhoneCheckService._();

  /// Returns true/false if known, or null when the check couldn't run (offline
  /// or the function isn't deployed). Callers must treat null as "unknown" and
  /// NOT block registration — the post-verification duplicate guard still
  /// catches it.
  Future<bool?> exists(String e164Phone) async {
    if (e164Phone.trim().isEmpty) return null;
    try {
      final res = await FirebaseFunctions.instance
          .httpsCallable('phoneExists')
          .call({'phone': e164Phone})
          .timeout(const Duration(seconds: 8));
      final data = res.data;
      if (data is Map && data['exists'] is bool) return data['exists'] as bool;
      return null;
    } catch (_) {
      return null;
    }
  }
}
