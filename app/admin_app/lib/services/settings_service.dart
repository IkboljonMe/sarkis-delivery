import 'api_client.dart';

class SettingsService {
  SettingsService._();
  static final SettingsService instance = SettingsService._();

  final ApiClient _api = ApiClient.instance;

  static const _defaults = {'maxQty': 10, 'minQty': 1, 'adminWhatsapp': ''};

  Future<Map<String, dynamic>> get() async {
    try {
      final res = await _api.get('/v1/admin/settings');
      final data = Map<String, dynamic>.from(res as Map);
      return {..._defaults, ...data};
    } catch (_) {
      return Map<String, dynamic>.from(_defaults);
    }
  }

  Future<void> save(Map<String, dynamic> data) async {
    final current = await get();
    await _api.put('/v1/admin/settings', {...current, ...data});
  }
}
