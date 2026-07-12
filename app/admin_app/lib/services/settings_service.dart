import 'package:cloud_firestore/cloud_firestore.dart';

class SettingsService {
  SettingsService._();
  static final SettingsService instance = SettingsService._();

  final DocumentReference<Map<String, dynamic>> _doc =
      FirebaseFirestore.instance.collection('settings').doc('config');

  Future<Map<String, dynamic>> get() async {
    try {
      final d = await _doc.get();
      return d.data() ?? {'maxQty': 10, 'minQty': 1, 'adminWhatsapp': ''};
    } catch (_) {
      return {'maxQty': 10, 'minQty': 1, 'adminWhatsapp': ''};
    }
  }

  Future<void> save(Map<String, dynamic> data) async {
    try {
      await _doc.set(data, SetOptions(merge: true));
    } catch (e) {
      throw Exception('Failed to save settings: $e');
    }
  }
}
