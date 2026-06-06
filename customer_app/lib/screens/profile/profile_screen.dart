import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../l10n/app_localizations.dart';
import '../../providers/auth_provider.dart';
import '../../providers/locale_provider.dart';
import '../../utils/constants.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _nameController = TextEditingController();
  final _addressController = TextEditingController();
  final _cityController = TextEditingController();
  bool _editing = false;
  bool _initialized = false;

  static const _languages = [
    {'code': 'en', 'flag': '🇬🇧', 'label': 'English'},
    {'code': 'hy', 'flag': '🇦🇲', 'label': 'Հայերեն'},
    {'code': 'ru', 'flag': '🇷🇺', 'label': 'Русский'},
    {'code': 'tr', 'flag': '🇹🇷', 'label': 'Türkçe'},
    {'code': 'de', 'flag': '🇩🇪', 'label': 'Deutsch'},
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _addressController.dispose();
    _cityController.dispose();
    super.dispose();
  }

  void _syncControllers() {
    final user = context.read<AuthProvider>().user;
    if (user != null && !_initialized) {
      _nameController.text = user.name;
      _addressController.text = user.address;
      _cityController.text = user.city;
      _initialized = true;
    }
  }

  Future<void> _save() async {
    final auth = context.read<AuthProvider>();
    await auth.updateProfileFields({
      'name': _nameController.text.trim(),
      'address': _addressController.text.trim(),
      'city': _cityController.text.trim(),
    });
    if (!mounted) return;
    setState(() => _editing = false);
    Fluttertoast.showToast(msg: AppLocalizations.of(context).save);
  }

  Future<void> _openWhatsApp() async {
    final number = AppConstants.adminWhatsappNumber;
    final uri = Uri.parse('https://wa.me/$number');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      Fluttertoast.showToast(msg: 'Could not open WhatsApp');
    }
  }

  Future<void> _confirmLogout() async {
    final t = AppLocalizations.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(t.logout),
        content: Text(t.logoutConfirm),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: Text(t.cancel)),
          ElevatedButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: Text(t.logout)),
        ],
      ),
    );
    if (confirmed == true && mounted) {
      await context.read<AuthProvider>().signOut();
      if (!mounted) return;
      Navigator.of(context)
          .pushNamedAndRemoveUntil('/phone', (route) => false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final auth = context.watch<AuthProvider>();
    final locale = context.watch<LocaleProvider>();
    final user = auth.user;
    _syncControllers();

    return Scaffold(
      appBar: AppBar(
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
                _field(t.yourName, _nameController, _editing),
                _readOnlyField('Phone', user.phone),
                _field(t.yourAddress, _addressController, _editing),
                _field(t.yourCity, _cityController, _editing),
                _readOnlyField(t.group, user.group),
                if (_editing) ...[
                  const SizedBox(height: 12),
                  ElevatedButton(onPressed: _save, child: Text(t.save)),
                ],
                const SizedBox(height: 24),
                Text(t.selectLanguage,
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 16)),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  children: _languages.map((lang) {
                    final selected =
                        locale.locale.languageCode == lang['code'];
                    return ChoiceChip(
                      label: Text('${lang['flag']} ${lang['label']}'),
                      selected: selected,
                      onSelected: (_) {
                        locale.setLocale(Locale(lang['code']!));
                        auth.updateProfileFields({'language': lang['code']});
                      },
                    );
                  }).toList(),
                ),
                const SizedBox(height: 24),
                OutlinedButton.icon(
                  onPressed: _openWhatsApp,
                  icon: const Icon(Icons.chat),
                  label: Text(t.contactWhatsApp),
                ),
                const SizedBox(height: 12),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red.shade400),
                  onPressed: _confirmLogout,
                  icon: const Icon(Icons.logout),
                  label: Text(t.logout),
                ),
              ],
            ),
    );
  }

  Widget _field(
      String label, TextEditingController controller, bool enabled) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextField(
        controller: controller,
        enabled: enabled,
        decoration: InputDecoration(labelText: label),
      ),
    );
  }

  Widget _readOnlyField(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextField(
        enabled: false,
        decoration: InputDecoration(
          labelText: label,
          hintText: value,
          hintStyle: const TextStyle(color: Colors.black87),
        ),
      ),
    );
  }
}
