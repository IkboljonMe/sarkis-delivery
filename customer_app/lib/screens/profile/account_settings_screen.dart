import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';

import '../../l10n/app_localizations.dart';
import '../../providers/auth_provider.dart';
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
  final _address = TextEditingController();
  final _city = TextEditingController();
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final u = context.read<AuthProvider>().user;
    _name.text = u?.name ?? '';
    _address.text = u?.address ?? '';
    _city.text = u?.city ?? '';
  }

  @override
  void dispose() {
    _name.dispose();
    _address.dispose();
    _city.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    setState(() => _saving = true);
    await context.read<AuthProvider>().updateFields({
      'name': _name.text.trim(),
      'address': _address.text.trim(),
      'city': _city.text.trim(),
    });
    if (!mounted) return;
    setState(() => _saving = false);
    Fluttertoast.showToast(msg: AppLocalizations.of(context).save);
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
                    label: t.phone,
                    hint: u?.phone ?? '',
                    enabled: false,
                    prefixIcon: Icons.phone_outlined),
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
