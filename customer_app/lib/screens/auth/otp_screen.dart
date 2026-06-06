import 'dart:async';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import 'package:provider/provider.dart';

import '../../l10n/app_localizations.dart';
import '../../providers/auth_provider.dart';
import '../../utils/app_colors.dart';
import '../../utils/app_text_styles.dart';

class OtpScreen extends StatefulWidget {
  const OtpScreen({super.key});

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  final _pin = TextEditingController();
  Timer? _timer;
  int _left = 60;
  bool _verifying = false;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pin.dispose();
    super.dispose();
  }

  void _startTimer() {
    _timer?.cancel();
    setState(() => _left = 60);
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (_left <= 0) {
        t.cancel();
      } else {
        setState(() => _left--);
      }
    });
  }

  Future<void> _verify(String code) async {
    if (code.length != 6 || _verifying) return;
    setState(() => _verifying = true);
    final auth = context.read<AuthProvider>();
    final ok = await auth.verifyOtp(code);
    if (!mounted) return;
    setState(() => _verifying = false);
    if (ok) {
      Navigator.pushNamedAndRemoveUntil(
          context, auth.user == null ? '/register' : '/main', (r) => false);
    } else {
      Fluttertoast.showToast(msg: auth.error ?? 'Invalid code');
      auth.resetError();
      _pin.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final number = ModalRoute.of(context)?.settings.arguments as String? ?? '';

    return Scaffold(
      appBar: AppBar(),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(t.enterOtp, style: AppTextStyles.headingL),
              const SizedBox(height: 8),
              Text(number, style: AppTextStyles.caption),
              const SizedBox(height: 32),
              PinCodeTextField(
                appContext: context,
                length: 6,
                controller: _pin,
                autoFocus: true,
                keyboardType: TextInputType.number,
                textStyle: AppTextStyles.headingM,
                onChanged: (_) {},
                onCompleted: _verify,
                pinTheme: PinTheme(
                  shape: PinCodeFieldShape.box,
                  borderRadius: BorderRadius.circular(12),
                  fieldHeight: 54,
                  fieldWidth: 46,
                  activeColor: AppColors.primary,
                  selectedColor: AppColors.primary,
                  inactiveColor: AppColors.border,
                  activeFillColor: AppColors.surfaceElevated,
                  selectedFillColor: AppColors.surfaceElevated,
                  inactiveFillColor: AppColors.surfaceElevated,
                ),
                enableActiveFill: true,
              ),
              const SizedBox(height: 16),
              if (_verifying)
                const Center(child: CircularProgressIndicator())
              else
                Center(
                  child: _left > 0
                      ? Text('${t.resendCode} ($_left)',
                          style: AppTextStyles.caption)
                      : TextButton(
                          onPressed: () {
                            context
                                .read<AuthProvider>()
                                .startPhoneVerification(number);
                            _startTimer();
                          },
                          child: Text(t.resendCode,
                              style:
                                  const TextStyle(color: AppColors.primary)),
                        ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
