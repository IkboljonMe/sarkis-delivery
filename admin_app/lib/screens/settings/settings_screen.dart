import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

import '../../services/firebase_service.dart';
import '../../utils/constants.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final _maxQtyController = TextEditingController();
  final _minQtyController = TextEditingController();
  final _whatsappController = TextEditingController();
  bool _loading = true;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _maxQtyController.dispose();
    _minQtyController.dispose();
    _whatsappController.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    final settings = await FirebaseService.instance.getSettings();
    if (!mounted) return;
    _maxQtyController.text = '${settings['maxQty'] ?? 10}';
    _minQtyController.text = '${settings['minQty'] ?? 1}';
    _whatsappController.text = '${settings['whatsappNumber'] ?? ''}';
    setState(() => _loading = false);
  }

  Future<void> _save() async {
    setState(() => _saving = true);
    try {
      await FirebaseService.instance.saveSettings({
        'maxQty': int.tryParse(_maxQtyController.text) ?? 10,
        'minQty': int.tryParse(_minQtyController.text) ?? 1,
        'whatsappNumber': _whatsappController.text.trim(),
      });
      Fluttertoast.showToast(msg: 'Сохранено');
    } catch (e) {
      Fluttertoast.showToast(msg: 'Ошибка: $e');
    }
    if (mounted) setState(() => _saving = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Настройки')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                TextField(
                  controller: _minQtyController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                      labelText: 'Мин. количество на товар'),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _maxQtyController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                      labelText: 'Макс. количество на товар'),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _whatsappController,
                  keyboardType: TextInputType.phone,
                  decoration: const InputDecoration(
                      labelText: 'WhatsApp номер админа (49...)'),
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: _saving ? null : _save,
                  child: _saving
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                              color: Colors.white, strokeWidth: 2))
                      : const Text('Сохранить'),
                ),
                const SizedBox(height: 24),
                Center(
                  child: Text(
                    'Версия / Version ${AppConstants.appVersion}',
                    style: const TextStyle(color: Colors.black45),
                  ),
                ),
              ],
            ),
    );
  }
}
