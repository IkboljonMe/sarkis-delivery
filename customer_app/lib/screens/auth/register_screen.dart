import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';

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

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  int _step = 0;
  final _name = TextEditingController();
  final _address = TextEditingController();
  final _city = TextEditingController();
  final _postal = TextEditingController();
  String? _group;

  @override
  void dispose() {
    _name.dispose();
    _address.dispose();
    _city.dispose();
    _postal.dispose();
    super.dispose();
  }

  void _next() {
    if (_step == 0 && _name.text.trim().isEmpty) {
      Fluttertoast.showToast(msg: 'Enter your name');
      return;
    }
    if (_step == 1) {
      if (_address.text.trim().isEmpty ||
          _city.text.trim().isEmpty ||
          _postal.text.trim().isEmpty) {
        Fluttertoast.showToast(msg: 'Fill all address fields');
        return;
      }
      _group = AppConstants.groupForPostalCode(_postal.text);
      setState(() {});
    }
    setState(() => _step = (_step + 1).clamp(0, 2));
  }

  void _back() => setState(() => _step = (_step - 1).clamp(0, 2));

  Future<void> _finish() async {
    final group = _group;
    if (group == null) {
      Fluttertoast.showToast(msg: 'Select your group');
      return;
    }
    final auth = context.read<AuthProvider>();
    final locale = context.read<LocaleProvider>();
    final ok = await auth.saveProfile(
      name: _name.text.trim(),
      address: _address.text.trim(),
      city: _city.text.trim(),
      postalCode: _postal.text.trim(),
      group: group,
      language: locale.locale.languageCode,
    );
    if (!mounted) return;
    if (ok) {
      Navigator.pushNamedAndRemoveUntil(context, '/main', (r) => false);
    } else {
      Fluttertoast.showToast(msg: auth.error ?? 'Failed to save');
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final auth = context.watch<AuthProvider>();

    return Scaffold(
      appBar: AppBar(
        leading: _step > 0
            ? IconButton(icon: const Icon(Icons.arrow_back), onPressed: _back)
            : null,
        automaticallyImplyLeading: false,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _progressDots(),
              const SizedBox(height: 24),
              Expanded(
                child: SingleChildScrollView(
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    child: _buildStep(t),
                  ),
                ),
              ),
              GoldenButton(
                label: _step < 2 ? t.continueLabel : t.confirmDetails,
                loading: auth.busy,
                onPressed: _step < 2 ? _next : _finish,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _progressDots() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(3, (i) {
        final active = i <= _step;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          margin: const EdgeInsets.symmetric(horizontal: 4),
          width: active ? 28 : 10,
          height: 10,
          decoration: BoxDecoration(
            color: active ? AppColors.primary : AppColors.border,
            borderRadius: BorderRadius.circular(5),
          ),
        );
      }),
    );
  }

  Widget _buildStep(AppLocalizations t) {
    switch (_step) {
      case 0:
        return Column(
          key: const ValueKey(0),
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(t.t('whatsName'), style: AppTextStyles.headingL),
            const SizedBox(height: 24),
            AppInputField(
              controller: _name,
              label: t.fullName,
              prefixIcon: Icons.person_outline,
              textCapitalization: TextCapitalization.words,
            ),
            const SizedBox(height: 16),
            AppInputField(
              label: t.phone,
              hint: context.read<AuthProvider>().phone ?? '',
              prefixIcon: Icons.phone_outlined,
              enabled: false,
            ),
          ],
        ).animate().fadeIn().slideX(begin: 0.1);
      case 1:
        return Column(
          key: const ValueKey(1),
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(t.t('whereDeliver'), style: AppTextStyles.headingL),
            const SizedBox(height: 24),
            AppInputField(
                controller: _address,
                label: t.yourAddress,
                prefixIcon: Icons.home_outlined),
            const SizedBox(height: 16),
            AppInputField(
                controller: _city,
                label: t.city,
                prefixIcon: Icons.location_city_outlined),
            const SizedBox(height: 16),
            AppInputField(
              controller: _postal,
              label: t.postalCode,
              prefixIcon: Icons.markunread_mailbox_outlined,
              keyboardType: TextInputType.number,
            ),
          ],
        ).animate().fadeIn().slideX(begin: 0.1);
      default:
        return Column(
          key: const ValueKey(2),
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(t.t('confirmDetails'), style: AppTextStyles.headingL),
            const SizedBox(height: 24),
            DarkCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _row(Icons.person_outline, _name.text),
                  const SizedBox(height: 12),
                  _row(Icons.home_outlined,
                      '${_address.text}, ${_postal.text} ${_city.text}'),
                  const SizedBox(height: 16),
                  if (_group != null)
                    GoldBadge(text: _group!, icon: Icons.location_on)
                  else
                    _groupSelector(),
                ],
              ),
            ),
          ],
        ).animate().fadeIn().slideX(begin: 0.1);
    }
  }

  Widget _groupSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Select your group', style: AppTextStyles.caption),
        const SizedBox(height: 8),
        Row(
          children: AppConstants.groups.map((g) {
            final sel = _group == g;
            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: ChoiceChip(
                label: Text(g),
                selected: sel,
                selectedColor: AppColors.primary.withOpacity(0.2),
                onSelected: (_) => setState(() => _group = g),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _row(IconData icon, String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: AppColors.primary),
        const SizedBox(width: 10),
        Expanded(child: Text(text, style: AppTextStyles.body)),
      ],
    );
  }
}
