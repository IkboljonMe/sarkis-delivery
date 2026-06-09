import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../l10n/app_localizations.dart';
import '../../providers/auth_provider.dart';
import '../../providers/locale_provider.dart';
import '../../utils/app_colors.dart';
import '../../utils/app_text_styles.dart';
import '../../utils/constants.dart';
import '../orders/my_orders_screen.dart';
import 'account_settings_screen.dart';
import 'info_page.dart';
import 'language_settings_screen.dart';
import 'translate_language_screen.dart';

/// Customer settings menu — row-format submenus grouped into sections.
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  Future<void> _whatsApp() async {
    final uri = Uri.parse('https://wa.me/${AppConstants.adminWhatsappNumber}');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  Future<void> _logout(BuildContext context) async {
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
    if (ok == true && context.mounted) {
      await context.read<AuthProvider>().signOut();
      if (context.mounted) {
        Navigator.pushNamedAndRemoveUntil(context, '/phone', (r) => false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final user = context.watch<AuthProvider>().user;
    final locale = context.watch<LocaleProvider>();
    final langName = AppConstants.languages.firstWhere(
        (l) => l['code'] == locale.locale.languageCode,
        orElse: () => AppConstants.languages.first)['native'];
    final translateLangName = AppConstants.languages.firstWhere(
        (l) => l['code'] == locale.translateLang,
        orElse: () => AppConstants.languages.first)['native'];

    final initials =
        (user?.name.isNotEmpty ?? false) ? user!.name.trim()[0].toUpperCase() : '?';
    final memberSince =
        user?.createdAt != null ? DateFormat('MMM yyyy').format(user!.createdAt!) : '—';

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text(t.t('settings')),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Header
          Row(
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: const BoxDecoration(
                    shape: BoxShape.circle, gradient: AppColors.goldGradient),
                child: Center(
                  child: Text(initials,
                      style: AppTextStyles.headingL
                          .copyWith(color: Colors.white)),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(user?.name ?? '', style: AppTextStyles.headingM),
                    Text(user?.phone ?? '', style: AppTextStyles.caption),
                    Text('${t.t('memberSince')} $memberSince',
                        style: AppTextStyles.label),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          _section(t.t('account')),
          _group([
            _row(context, Icons.person_outline, t.t('accountSettings'),
                () => _push(context, const AccountSettingsScreen())),
            _row(context, Icons.receipt_long_outlined, t.t('latestOrders'),
                () => _push(context, const MyOrdersScreen())),
            _row(context, Icons.language, t.language,
                () => _push(context, const LanguageSettingsScreen()),
                trailingText: langName),
            _row(context, Icons.translate, t.t('translateLanguage'),
                () => _push(context, const TranslateLanguageScreen()),
                trailingText: translateLangName),
          ]),

          const SizedBox(height: 16),
          _section(t.t('support')),
          _group([
            _row(context, Icons.chat_outlined, t.t('contactUs'), _whatsApp),
            _row(context, Icons.description_outlined, t.t('termsOfService'),
                () => _push(
                    context,
                    InfoPage(
                        title: t.t('termsOfService'), body: t.t('termsBody')))),
            _row(context, Icons.privacy_tip_outlined, t.t('privacyPolicy'),
                () => _push(
                    context,
                    InfoPage(
                        title: t.t('privacyPolicy'),
                        body: t.t('privacyBody')))),
            _row(context, Icons.info_outline, t.t('aboutApp'),
                () => _showAbout(context)),
          ]),

          const SizedBox(height: 24),
          _group([
            _row(context, Icons.logout, t.logout, () => _logout(context),
                danger: true),
          ]),
          const SizedBox(height: 100),
        ],
      ),
    );
  }

  void _push(BuildContext context, Widget page) {
    Navigator.push(context, MaterialPageRoute(builder: (_) => page));
  }

  void _showAbout(BuildContext context) {
    final t = AppLocalizations.of(context);
    final today = DateFormat('d MMM yyyy').format(DateTime.now());
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(t.t('aboutApp')),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _aboutRow(t.appName, ''),
            _aboutRow(t.t('appVersionLabel'), AppConstants.appVersion),
            _aboutRow('Date', today),
          ],
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx), child: Text(t.continueLabel)),
        ],
      ),
    );
  }

  Widget _aboutRow(String k, String v) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          children: [
            Text(k, style: AppTextStyles.caption),
            const Spacer(),
            Text(v, style: AppTextStyles.body),
          ],
        ),
      );

  Widget _section(String title) => Padding(
        padding: const EdgeInsets.only(left: 4, bottom: 8),
        child: Text(title.toUpperCase(), style: AppTextStyles.label),
      );

  Widget _group(List<Widget> rows) {
    final children = <Widget>[];
    for (var i = 0; i < rows.length; i++) {
      children.add(rows[i]);
      if (i < rows.length - 1) {
        children.add(const Divider(height: 1, color: AppColors.border));
      }
    }
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(children: children),
    );
  }

  Widget _row(
    BuildContext context,
    IconData icon,
    String title,
    VoidCallback onTap, {
    String? subtitle,
    String? trailingText,
    bool danger = false,
    VoidCallback? onTapOverride,
  }) {
    final color = danger ? AppColors.error : AppColors.textPrimary;
    return ListTile(
      onTap: onTapOverride ?? onTap,
      leading: Icon(icon, color: danger ? AppColors.error : AppColors.primary),
      title: Text(title, style: AppTextStyles.body.copyWith(color: color)),
      subtitle: subtitle != null
          ? Text(subtitle, style: AppTextStyles.caption)
          : null,
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (trailingText != null)
            Text(trailingText, style: AppTextStyles.caption),
          const SizedBox(width: 4),
          if (!danger)
            const Icon(Icons.chevron_right, color: AppColors.textMuted),
        ],
      ),
    );
  }
}
