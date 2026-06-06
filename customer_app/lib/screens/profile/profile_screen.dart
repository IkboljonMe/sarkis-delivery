import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../l10n/app_localizations.dart';
import '../../providers/auth_provider.dart';
import '../../providers/locale_provider.dart';
import '../../utils/app_colors.dart';
import '../../utils/app_text_styles.dart';
import '../../utils/constants.dart';
import '../../widgets/app_input_field.dart';
import '../../widgets/dark_card.dart';
import '../../widgets/gold_badge.dart';
import '../../widgets/golden_button.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _name = TextEditingController();
  final _address = TextEditingController();
  final _city = TextEditingController();
  bool _editing = false;
  bool _init = false;

  @override
  void dispose() {
    _name.dispose();
    _address.dispose();
    _city.dispose();
    super.dispose();
  }

  void _sync() {
    final user = context.read<AuthProvider>().user;
    if (user != null && !_init) {
      _name.text = user.name;
      _address.text = user.address;
      _city.text = user.city;
      _init = true;
    }
  }

  Future<void> _save() async {
    await context.read<AuthProvider>().updateFields({
      'name': _name.text.trim(),
      'address': _address.text.trim(),
      'city': _city.text.trim(),
    });
    if (!mounted) return;
    setState(() => _editing = false);
    Fluttertoast.showToast(msg: AppLocalizations.of(context).save);
  }

  Future<void> _whatsApp() async {
    final uri = Uri.parse('https://wa.me/${AppConstants.adminWhatsappNumber}');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  Future<void> _logout() async {
    final t = AppLocalizations.of(context);
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(t.logout),
        content: Text(t.logoutConfirm),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: Text(t.cancel)),
          TextButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: Text(t.logout,
                  style: const TextStyle(color: AppColors.error))),
        ],
      ),
    );
    if (ok == true && mounted) {
      await context.read<AuthProvider>().signOut();
      if (mounted) {
        Navigator.pushNamedAndRemoveUntil(context, '/phone', (r) => false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final auth = context.watch<AuthProvider>();
    final locale = context.watch<LocaleProvider>();
    final user = auth.user;
    _sync();

    final initials = (user?.name.isNotEmpty ?? false)
        ? user!.name.trim()[0].toUpperCase()
        : '?';

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text(t.profile),
        actions: [
          IconButton(
            icon: Icon(_editing ? Icons.close : Icons.edit),
            onPressed: () => setState(() => _editing = !_editing),
          ),
        ],
      ),
      body: user == null
          ? Center(child: Text(t.loading))
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Center(
                  child: Column(
                    children: [
                      Container(
                        width: 88,
                        height: 88,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: AppColors.goldGradient,
                        ),
                        child: Center(
                          child: Text(initials,
                              style: AppTextStyles.headingXL
                                  .copyWith(color: Colors.white)),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(user.name, style: AppTextStyles.headingM),
                      Text(user.phone, style: AppTextStyles.caption),
                      const SizedBox(height: 8),
                      GoldBadge(text: user.group, icon: Icons.location_on),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                DarkCard(
                  child: Column(
                    children: [
                      AppInputField(
                          controller: _name,
                          label: t.name,
                          enabled: _editing,
                          prefixIcon: Icons.person_outline),
                      const SizedBox(height: 12),
                      AppInputField(
                          controller: _address,
                          label: t.address,
                          enabled: _editing,
                          prefixIcon: Icons.home_outlined),
                      const SizedBox(height: 12),
                      AppInputField(
                          controller: _city,
                          label: t.city,
                          enabled: _editing,
                          prefixIcon: Icons.location_city_outlined),
                      if (_editing) ...[
                        const SizedBox(height: 16),
                        GoldenButton(label: t.save, onPressed: _save),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Text(t.language, style: AppTextStyles.headingM),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: AppConstants.languages.map((lang) {
                    final sel = locale.locale.languageCode == lang['code'];
                    return ChoiceChip(
                      label: Text('${lang['flag']} ${lang['native']}'),
                      selected: sel,
                      selectedColor: AppColors.primary.withOpacity(0.2),
                      onSelected: (_) {
                        locale.setLocale(Locale(lang['code']!));
                        auth.updateFields({'language': lang['code']});
                      },
                    );
                  }).toList(),
                ),
                const SizedBox(height: 24),
                GoldenButton(
                  label: t.contactAdmin,
                  icon: Icons.chat,
                  onPressed: _whatsApp,
                ),
                const SizedBox(height: 12),
                OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.error,
                    side: const BorderSide(color: AppColors.error),
                    minimumSize: const Size.fromHeight(52),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14)),
                  ),
                  onPressed: _logout,
                  icon: const Icon(Icons.logout),
                  label: Text(t.logout),
                ),
                const SizedBox(height: 16),
                Center(
                  child: Text('v${AppConstants.appVersion}',
                      style: AppTextStyles.label),
                ),
                const SizedBox(height: 100),
              ],
            ),
    );
  }
}
