import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';

import '../../l10n/app_localizations.dart';
import '../../providers/auth_provider.dart';
import '../../utils/app_colors.dart';
import '../../widgets/brand_logo.dart';
import '../../utils/app_text_styles.dart';
import '../../utils/constants.dart';
import '../../widgets/golden_button.dart';

class PhoneScreen extends StatefulWidget {
  const PhoneScreen({super.key});

  @override
  State<PhoneScreen> createState() => _PhoneScreenState();
}

class _PhoneScreenState extends State<PhoneScreen> {
  final _controller = TextEditingController();
  String _code = '+49';

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _continue() async {
    if (_controller.text.trim().isEmpty) {
      Fluttertoast.showToast(msg: 'Enter your phone number');
      return;
    }
    FocusScope.of(context).unfocus();
    final number = AuthProvider.buildE164(_code, _controller.text);
    final auth = context.read<AuthProvider>();
    await auth.startPhoneVerification(number);
    if (!mounted) return;
    if (auth.status == AuthStatus.codeSent) {
      Navigator.pushNamed(context, '/otp', arguments: number);
    } else if (auth.status == AuthStatus.authenticated) {
      // Instant verification — skip the code screen and route by profile.
      final user = auth.user ?? await auth.loadCurrentUser();
      if (!mounted) return;
      Navigator.pushNamedAndRemoveUntil(
          context, user == null ? '/register' : '/main', (r) => false);
    } else if (auth.error != null) {
      Fluttertoast.showToast(msg: auth.error!);
      auth.resetError();
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final auth = context.watch<AuthProvider>();

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 24),
              const Center(child: BrandLogo(size: 84)),
              const SizedBox(height: 24),
              Text(t.welcome,
                  textAlign: TextAlign.center, style: AppTextStyles.headingL),
              const SizedBox(height: 8),
              Text(t.enterPhone,
                  textAlign: TextAlign.center, style: AppTextStyles.caption),
              const SizedBox(height: 28),
              Row(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: AppColors.surfaceElevated,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: _code,
                        dropdownColor: AppColors.surfaceElevated,
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        style: AppTextStyles.body,
                        items: AppConstants.countryCodes
                            .map((c) => DropdownMenuItem(
                                  value: c['code'],
                                  child: Text('${c['flag']} ${c['code']}'),
                                ))
                            .toList(),
                        onChanged: (v) => setState(() => _code = v!),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      keyboardType: TextInputType.phone,
                      style: AppTextStyles.body,
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(RegExp(r'[0-9 ]')),
                      ],
                      decoration: const InputDecoration(hintText: '170 1234567'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              GoldenButton(
                label: t.continueWithSms,
                icon: Icons.sms_outlined,
                loading: auth.busy,
                onPressed: _continue,
              ),
            ],
          ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.05),
        ),
      ),
    );
  }
}
