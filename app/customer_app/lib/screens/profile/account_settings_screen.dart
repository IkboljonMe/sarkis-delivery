import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';

import '../../l10n/app_localizations.dart';
import '../../providers/auth_provider.dart';
import '../../services/approval_service.dart';
import '../../utils/app_colors.dart';
import '../../utils/app_text_styles.dart';
import '../../widgets/app_input_field.dart';
import '../../widgets/dark_card.dart';
import '../../widgets/gold_badge.dart';
import '../../widgets/golden_button.dart';

class AccountSettingsScreen extends StatefulWidget {
  const AccountSettingsScreen({super.key});

  @override
  State<AccountSettingsScreen> createState() => _AccountSettingsScreenState();
}

class _AccountSettingsScreenState extends State<AccountSettingsScreen> {
  final _name = TextEditingController();
  final _phone = TextEditingController();
  final _address = TextEditingController();
  final _city = TextEditingController();
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final u = context.read<AuthProvider>().user;
    _name.text = u?.name ?? '';
    _phone.text = u?.phone ?? '';
    _address.text = u?.address ?? '';
    _city.text = u?.city ?? '';
  }

  @override
  void dispose() {
    _name.dispose();
    _phone.dispose();
    _address.dispose();
    _city.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final t = AppLocalizations.of(context);
    final auth = context.read<AuthProvider>();
    final u = auth.user;
    setState(() => _saving = true);

    // Address / city apply immediately.
    await auth.updateFields({
      'address': _address.text.trim(),
      'city': _city.text.trim(),
    });

    // Name / phone changes need admin approval.
    final changes = <String, dynamic>{};
    if (_name.text.trim() != (u?.name ?? '')) {
      changes['name'] = _name.text.trim();
    }
    if (_phone.text.trim() != (u?.phone ?? '')) {
      changes['phone'] = _phone.text.trim();
    }
    if (changes.isNotEmpty && u != null) {
      await ApprovalService.instance.requestProfileChange(
        userId: u.id,
        userName: u.fullName.isEmpty ? u.name : u.fullName,
        changes: changes,
      );
    }

    if (!mounted) return;
    setState(() => _saving = false);
    Fluttertoast.showToast(
        msg: changes.isEmpty ? t.save : t.t('changesSentForApproval'));
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final u = context.watch<AuthProvider>().user;

    return Scaffold(
      appBar: AppBar(title: Text(t.t('accountSettings'))),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          DarkCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppInputField(
                    controller: _name,
                    label: t.fullName,
                    prefixIcon: Icons.person_outline),
                const SizedBox(height: 12),
                AppInputField(
                    controller: _phone,
                    label: t.phone,
                    keyboardType: TextInputType.phone,
                    prefixIcon: Icons.phone_outlined),
                const SizedBox(height: 6),
                Row(
                  children: [
                    const Icon(Icons.info_outline,
                        size: 13, color: AppColors.textMuted),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(t.t('namePhoneNeedApproval'),
                          style: AppTextStyles.label),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                AppInputField(
                    controller: _address,
                    label: t.yourAddress,
                    prefixIcon: Icons.home_outlined),
                const SizedBox(height: 12),
                AppInputField(
                    controller: _city,
                    label: t.city,
                    prefixIcon: Icons.location_city_outlined),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Text('${t.yourGroup}: ', style: AppTextStyles.caption),
                    GoldBadge(text: u?.group ?? '', icon: Icons.location_on),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          GoldenButton(label: t.save, loading: _saving, onPressed: _save),
        ],
      ),
    );
  }
}
