import 'dart:async';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import 'package:provider/provider.dart';

import '../../l10n/app_localizations.dart';
import '../../providers/auth_provider.dart';
import '../../utils/app_colors.dart';
import '../../utils/app_text_styles.dart';
import '../../widgets/golden_button.dart';

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
    code = code.trim();
    // Guard against the duplicate trigger from onCompleted + manual submit.
    if (code.length != 6 || _verifying) return;
    setState(() => _verifying = true);
    final auth = context.read<AuthProvider>();

    // A single retry covers transient sign-in failures that previously forced
    // the user to submit the code twice.
    bool ok = await auth.verifyOtp(code);
    if (!ok && _isTransient(auth.error)) {
      await Future.delayed(const Duration(milliseconds: 400));
      ok = await auth.verifyOtp(code);
    }

    if (!mounted) return;
    setState(() => _verifying = false);
    if (ok) {
      Navigator.pushNamedAndRemoveUntil(
          context, auth.user == null ? '/register' : '/main', (r) => false);
    } else {
      Fluttertoast.showToast(msg: auth.error ?? 'Invalid code');
      auth.resetError();
      // Keep the entered digits so the user can just press Verify again
      // instead of re-typing the whole code.
    }
  }

  /// Network / internal errors are worth an automatic retry; a wrong code is
  /// not (the result would be identical).
  bool _isTransient(String? error) {
    if (error == null) return false;
    final e = error.toLowerCase();
    if (e.contains('invalid') || e.contains('expired') || e.contains('code')) {
      return false;
    }
    return e.contains('network') ||
        e.contains('timeout') ||
        e.contains('internal') ||
        e.contains('unavailable');
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
              // The global InputDecorationTheme has filled:true, which the
              // pin field's underlying text field inherited and painted as a
              // grey band behind the boxes. Override it to transparent here.
              Theme(
                data: Theme.of(context).copyWith(
                  inputDecorationTheme: const InputDecorationTheme(
                    filled: false,
                    fillColor: Colors.transparent,
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                  ),
                ),
                // Constrain the width so the 6 boxes stay compact and evenly
                // spaced instead of sprawling across a wide (web) window.
                child: Center(
                  child: SizedBox(
                    width: 340,
                    child: PinCodeTextField(
                      appContext: context,
                      length: 6,
                      controller: _pin,
                      autoFocus: true,
                      keyboardType: TextInputType.number,
                      textStyle: AppTextStyles.headingM,
                      // Clean bordered boxes, no filled background.
                      enableActiveFill: false,
                      backgroundColor: Colors.transparent,
                      showCursor: true,
                      cursorColor: AppColors.primary,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      onChanged: (_) {},
                      onCompleted: _verify,
                      pinTheme: PinTheme(
                        shape: PinCodeFieldShape.box,
                        borderRadius: BorderRadius.circular(12),
                        fieldHeight: 52,
                        fieldWidth: 46,
                        borderWidth: 1.4,
                        activeColor: AppColors.primary,
                        selectedColor: AppColors.primary,
                        inactiveColor: AppColors.border,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              GoldenButton(
                label: t.t('verify'),
                loading: _verifying,
                onPressed: () => _verify(_pin.text),
              ),
              const SizedBox(height: 16),
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
                            style: const TextStyle(color: AppColors.primary)),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
