import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';

import '../../l10n/admin_localizations.dart';
import '../../providers/admin_auth_provider.dart';
import '../../providers/locale_provider.dart';
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
  final _deliveryFee = TextEditingController();
  final _minOrder = TextEditingController();
  final _cancelDays = TextEditingController();
  final _editDays = TextEditingController();
  bool _autoAccept = false;
  bool _acceptingOrders = true;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    for (final c in [
      _minQty,
      _maxQty,
      _whatsapp,
      _phone,
      _deliveryFee,
      _minOrder,
      _cancelDays,
      _editDays,
    ]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _load() async {
    final s = await SettingsService.instance.get();
    if (!mounted) return;
    _minQty.text = '${s['minQty'] ?? 1}';
    _maxQty.text = '${s['maxQty'] ?? 10}';
    _whatsapp.text = '${s['adminWhatsapp'] ?? ''}';
    _phone.text = '${s['adminPhone'] ?? ''}';
    _deliveryFee.text = '${s['deliveryFee'] ?? 0}';
    _minOrder.text = '${s['minOrderTotal'] ?? 0}';
    _cancelDays.text = '${s['defaultCancelDays'] ?? 3}';
    _editDays.text = '${s['defaultEditDays'] ?? 4}';
    _autoAccept = s['autoAcceptOrders'] == true;
    _acceptingOrders = s['acceptingOrders'] != false; // default true
    setState(() => _loading = false);
  }

  Future<void> _save() async {
    final t = AdminLocalizations.of(context);
    await SettingsService.instance.save({
      'minQty': int.tryParse(_minQty.text) ?? 1,
      'maxQty': int.tryParse(_maxQty.text) ?? 10,
      'adminWhatsapp': _whatsapp.text.trim(),
      'adminPhone': _phone.text.trim(),
      'deliveryFee': double.tryParse(_deliveryFee.text) ?? 0,
      'minOrderTotal': double.tryParse(_minOrder.text) ?? 0,
      'defaultCancelDays': int.tryParse(_cancelDays.text) ?? 3,
      'defaultEditDays': int.tryParse(_editDays.text) ?? 4,
      'autoAcceptOrders': _autoAccept,
      'acceptingOrders': _acceptingOrders,
    });
    Fluttertoast.showToast(msg: t.t('saved'));
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
    final t = AdminLocalizations.of(context);
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Language
        Text(t.t('setLanguage'), style: AppTextStyles.headingM),
        const SizedBox(height: 8),
        DarkCard(child: _languageRow()),
        const SizedBox(height: 16),

        // Order control
        Text(t.t('setOrdersControl'), style: AppTextStyles.headingM),
        const SizedBox(height: 8),
        _ordersControlCard(t),
        const SizedBox(height: 16),

        // Orders (qty + money)
        Text(t.t('setOrders'), style: AppTextStyles.headingM),
        const SizedBox(height: 8),
        _orderLimitsCard(t),
        const SizedBox(height: 16),

        // Contacts
        Text(t.t('setContacts'), style: AppTextStyles.headingM),
        const SizedBox(height: 8),
        _contactsCard(t),
        const SizedBox(height: 16),
        GoldenButton(label: t.t('save'), onPressed: _save),
        const SizedBox(height: 16),

        // App info
        Text(t.t('setApp'), style: AppTextStyles.headingM),
        const SizedBox(height: 8),
        _appInfoCard(t),
        const SizedBox(height: 16),
        _dangerCard(t),
      ],
    );
  }

  Widget _ordersControlCard(AdminLocalizations t) {
    return DarkCard(
      child: Column(
        children: [
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            activeColor: AppColors.primary,
            value: _acceptingOrders,
            title: Text(t.t('setAcceptingOrders'), style: AppTextStyles.body),
            subtitle: Text(t.t('setAcceptingOrdersSub'),
                style: AppTextStyles.caption),
            onChanged: (v) => setState(() => _acceptingOrders = v),
          ),
          const Divider(color: AppColors.border),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            activeColor: AppColors.primary,
            value: _autoAccept,
            title: Text(t.t('setAutoAccept'), style: AppTextStyles.body),
            subtitle:
                Text(t.t('setAutoAcceptSub'), style: AppTextStyles.caption),
            onChanged: (v) => setState(() => _autoAccept = v),
          ),
          const SizedBox(height: 8),
          Row(children: [
            Expanded(
                child: AppInputField(
                    controller: _cancelDays,
                    label: t.t('setCancelDays'),
                    keyboardType: TextInputType.number)),
            const SizedBox(width: 12),
            Expanded(
                child: AppInputField(
                    controller: _editDays,
                    label: t.t('setEditDays'),
                    keyboardType: TextInputType.number)),
          ]),
        ],
      ),
    );
  }

  Widget _orderLimitsCard(AdminLocalizations t) {
    return DarkCard(
      child: Column(
        children: [
          Row(children: [
            Expanded(
                child: AppInputField(
                    controller: _minQty,
                    label: t.t('setMinQty'),
                    keyboardType: TextInputType.number)),
            const SizedBox(width: 12),
            Expanded(
                child: AppInputField(
                    controller: _maxQty,
                    label: t.t('setMaxQty'),
                    keyboardType: TextInputType.number)),
          ]),
          const SizedBox(height: 12),
          Row(children: [
            Expanded(
                child: AppInputField(
                    controller: _deliveryFee,
                    label: t.t('setDeliveryFee'),
                    keyboardType: TextInputType.number)),
            const SizedBox(width: 12),
            Expanded(
                child: AppInputField(
                    controller: _minOrder,
                    label: t.t('setMinOrder'),
                    keyboardType: TextInputType.number)),
          ]),
        ],
      ),
    );
  }

  Widget _contactsCard(AdminLocalizations t) {
    return DarkCard(
      child: Column(
        children: [
          AppInputField(
              controller: _whatsapp,
              label: t.t('setWhatsapp'),
              keyboardType: TextInputType.phone),
          const SizedBox(height: 12),
          AppInputField(
              controller: _phone,
              label: t.t('setPhone'),
              keyboardType: TextInputType.phone),
        ],
      ),
    );
  }

  Widget _appInfoCard(AdminLocalizations t) {
    return DarkCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _info(t.t('setVersion'), AppConstants.appVersion),
          const SizedBox(height: 8),
          _info(t.t('setApi'), AppConstants.apiBaseUrl),
          const SizedBox(height: 8),
          _info(t.t('setEnv'), 'Production'),
        ],
      ),
    );
  }

  Widget _dangerCard(AdminLocalizations t) {
    return DarkCard(
      borderColor: AppColors.error,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(t.t('setDanger'),
              style: AppTextStyles.bodyBold.copyWith(color: AppColors.error)),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.error,
              side: const BorderSide(color: AppColors.error),
            ),
            onPressed: _logout,
            icon: const Icon(Icons.logout),
            label: Text(t.t('logout')),
          ),
        ],
      ),
    );
  }

  Widget _languageRow() {
    final loc = context.watch<LocaleProvider>();
    final code = loc.locale.languageCode;
    return Row(
      children: [
        Expanded(child: _langChip('Русский', 'ru', code == 'ru')),
        const SizedBox(width: 8),
        Expanded(child: _langChip('English', 'en', code == 'en')),
      ],
    );
  }

  Widget _langChip(String label, String code, bool selected) {
    return GestureDetector(
      onTap: () => context.read<LocaleProvider>().setLocale(code),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: selected
              ? AppColors.primary.withOpacity(0.15)
              : AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
              color: selected ? AppColors.primary : AppColors.border,
              width: selected ? 1.5 : 1),
        ),
        child: Text(label,
            style: AppTextStyles.body.copyWith(
                color: selected ? AppColors.primary : AppColors.textPrimary,
                fontWeight: selected ? FontWeight.bold : FontWeight.normal)),
      ),
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
