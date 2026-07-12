import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../l10n/app_localizations.dart';
import '../../providers/auth_provider.dart';
import '../../providers/locale_provider.dart';
import '../../services/user_service.dart';
import '../../utils/app_colors.dart';
import '../../utils/app_text_styles.dart';
import '../../utils/constants.dart';
import '../../widgets/verification_badge.dart';
import '../orders/my_orders_screen.dart';
import 'account_settings_screen.dart';
import 'language_settings_screen.dart';
import 'translate_language_screen.dart';

/// Customer settings menu — row-format submenus grouped into sections.
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  Future<void> _pickAvatar(BuildContext context) async {
    final x = await ImagePicker()
        .pickImage(source: ImageSource.gallery, imageQuality: 70, maxWidth: 600);
    if (x == null || !context.mounted) return;
    final auth = context.read<AuthProvider>();
    final uid = auth.user?.id;
    if (uid == null) return;
    final t = AppLocalizations.of(context);
    Fluttertoast.showToast(msg: t.t('uploadingPhoto'));
    try {
      final bytes = await x.readAsBytes();
      final url = await UserService.instance.uploadAvatar(uid, bytes);
      await auth.updateFields({'photoUrl': url});
      Fluttertoast.showToast(msg: t.t('photoUpdated'));
    } catch (_) {
      Fluttertoast.showToast(msg: t.t('photoUploadFailed'));
    }
  }

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
        Navigator.pushNamedAndRemoveUntil(context, '/welcome', (r) => false);
      }
    }
  }

  /// Opens a hosted legal/link URL in the browser (same links as registration).
  Future<void> _openLink(String url) async {
    final uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      Fluttertoast.showToast(msg: url);
    }
  }

  Future<void> _deleteAccount(BuildContext context) async {
    final t = AppLocalizations.of(context);
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(t.t('deleteAccount')),
        content: Text(t.t('deleteAccountConfirm')),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: Text(t.cancel)),
          TextButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: Text(t.t('deleteAccount'),
                  style: const TextStyle(color: AppColors.error))),
        ],
      ),
    );
    if (ok == true && context.mounted) {
      await context.read<AuthProvider>().deleteAccount();
      if (context.mounted) {
        Navigator.pushNamedAndRemoveUntil(context, '/welcome', (r) => false);
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
        padding: EdgeInsets.fromLTRB(
            16, 16, 16, 16 + 68 + 16 + MediaQuery.of(context).padding.bottom),
        children: [
          // Header
          Row(
            children: [
              GestureDetector(
                onTap: () => _pickAvatar(context),
                child: Stack(
                  children: [
                    Container(
                      width: 64,
                      height: 64,
                      decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: (user?.photoUrl ?? '').isEmpty
                              ? AppColors.goldGradient
                              : null),
                      clipBehavior: Clip.antiAlias,
                      child: (user?.photoUrl ?? '').isEmpty
                          ? Center(
                              child: Text(initials,
                                  style: AppTextStyles.headingL
                                      .copyWith(color: Colors.white)),
                            )
                          : CachedNetworkImage(
                              imageUrl: user!.photoUrl,
                              fit: BoxFit.cover,
                              errorWidget: (_, __, ___) => Center(
                                  child: Text(initials,
                                      style: AppTextStyles.headingL
                                          .copyWith(color: Colors.white))),
                            ),
                    ),
                    Positioned(
                      right: 0,
                      bottom: 0,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          shape: BoxShape.circle,
                          border:
                              Border.all(color: AppColors.background, width: 2),
                        ),
                        child: const Icon(Icons.camera_alt,
                            size: 12, color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(user?.name ?? '',
                              style: AppTextStyles.headingM,
                              overflow: TextOverflow.ellipsis),
                        ),
                        VerificationBadge(
                            verified: user?.isVerified ?? false, size: 18),
                      ],
                    ),
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
                () => _openLink(AppConstants.termsUrl)),
            _row(context, Icons.privacy_tip_outlined, t.t('privacyPolicy'),
                () => _openLink(AppConstants.privacyUrl)),
            _row(context, Icons.info_outline, t.t('aboutApp'),
                () => _showAbout(context)),
          ]),

          const SizedBox(height: 24),
          _group([
            _row(context, Icons.logout, t.logout, () => _logout(context),
                danger: true),
            _row(context, Icons.delete_forever, t.t('deleteAccount'),
                () => _deleteAccount(context),
                danger: true),
          ]),
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
            _aboutRow(t.t('date'), today),
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
