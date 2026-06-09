import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';

import '../../providers/admin_auth_provider.dart';
import '../../services/settings_service.dart';
import '../../utils/app_colors.dart';
import '../../utils/app_text_styles.dart';
import '../../utils/constants.dart';
import '../../widgets/app_input_field.dart';
import '../../widgets/dark_card.dart';
import '../../widgets/golden_button.dart';
import '../auth/login_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final _minQty = TextEditingController();
  final _maxQty = TextEditingController();
  final _whatsapp = TextEditingController();
  final _phone = TextEditingController();
  bool _autoAccept = false;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _minQty.dispose();
    _maxQty.dispose();
    _whatsapp.dispose();
    _phone.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    final s = await SettingsService.instance.get();
    if (!mounted) return;
    _minQty.text = '${s['minQty'] ?? 1}';
    _maxQty.text = '${s['maxQty'] ?? 10}';
    _whatsapp.text = '${s['adminWhatsapp'] ?? ''}';
    _phone.text = '${s['adminPhone'] ?? ''}';
    _autoAccept = s['autoAcceptOrders'] == true;
    setState(() => _loading = false);
  }

  Future<void> _save() async {
    await SettingsService.instance.save({
      'minQty': int.tryParse(_minQty.text) ?? 1,
      'maxQty': int.tryParse(_maxQty.text) ?? 10,
      'adminWhatsapp': _whatsapp.text.trim(),
      'adminPhone': _phone.text.trim(),
      'autoAcceptOrders': _autoAccept,
    });
    Fluttertoast.showToast(msg: 'Сохранено');
  }

  Future<void> _logout() async {
    await context.read<AdminAuthProvider>().logout();
    if (!mounted) return;
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (r) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text('Заказы', style: AppTextStyles.headingM),
        const SizedBox(height: 8),
        DarkCard(
          child: Column(
            children: [
              AppInputField(
                  controller: _minQty,
                  label: 'Мин. количество',
                  keyboardType: TextInputType.number),
              const SizedBox(height: 12),
              AppInputField(
                  controller: _maxQty,
                  label: 'Макс. количество',
                  keyboardType: TextInputType.number),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Text('Заказы — приём', style: AppTextStyles.headingM),
        const SizedBox(height: 8),
        DarkCard(
          child: SwitchListTile(
            contentPadding: EdgeInsets.zero,
            activeColor: AppColors.primary,
            value: _autoAccept,
            title: Text('Авто-приём заказов', style: AppTextStyles.body),
            subtitle: Text(
                'Новые заказы подтверждаются автоматически. Иначе их нужно '
                'принять во вкладке «Заявки».',
                style: AppTextStyles.caption),
            onChanged: (v) => setState(() => _autoAccept = v),
          ),
        ),
        const SizedBox(height: 16),
        Text('Контакты', style: AppTextStyles.headingM),
        const SizedBox(height: 8),
        DarkCard(
          child: Column(
            children: [
              AppInputField(
                  controller: _whatsapp,
                  label: 'WhatsApp номер',
                  keyboardType: TextInputType.phone),
              const SizedBox(height: 12),
              AppInputField(
                  controller: _phone,
                  label: 'Телефон',
                  keyboardType: TextInputType.phone),
            ],
          ),
        ),
        const SizedBox(height: 16),
        GoldenButton(label: 'Сохранить', onPressed: _save),
        const SizedBox(height: 16),
        Text('Приложение', style: AppTextStyles.headingM),
        const SizedBox(height: 8),
        DarkCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _info('Версия', AppConstants.appVersion),
              const SizedBox(height: 8),
              _info('Firebase', AppConstants.firebaseProjectId),
              const SizedBox(height: 8),
              _info('Среда', 'Production'),
            ],
          ),
        ),
        const SizedBox(height: 16),
        DarkCard(
          borderColor: AppColors.error,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text('Опасная зона',
                  style: AppTextStyles.bodyBold
                      .copyWith(color: AppColors.error)),
              const SizedBox(height: 12),
              OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.error,
                  side: const BorderSide(color: AppColors.error),
                ),
                onPressed: _logout,
                icon: const Icon(Icons.logout),
                label: const Text('Выйти'),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _info(String label, String value) => Row(
        children: [
          Text(label, style: AppTextStyles.caption),
          const Spacer(),
          Text(value, style: AppTextStyles.body),
        ],
      );
}
