import 'dart:async';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import 'package:provider/provider.dart';

import '../../providers/auth_provider.dart';
import '../../utils/theme.dart';

class OtpScreen extends StatefulWidget {
  const OtpScreen({super.key});

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  final TextEditingController _pinController = TextEditingController();
  Timer? _timer;
  int _secondsLeft = 60;
  bool _verifying = false;

  @override
  void initState() {
    super.initState();
    _startCountdown();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pinController.dispose();
    super.dispose();
  }

  void _startCountdown() {
    _timer?.cancel();
    setState(() => _secondsLeft = 60);
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (_secondsLeft <= 0) {
        t.cancel();
      } else {
        setState(() => _secondsLeft--);
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
      final user = auth.user;
      if (user == null) {
        Navigator.of(context).pushNamedAndRemoveUntil(
            '/profileSetup', (route) => false);
      } else {
        Navigator.of(context)
            .pushNamedAndRemoveUntil('/home', (route) => false);
      }
    } else {
      Fluttertoast.showToast(msg: auth.errorMessage ?? 'Invalid code');
      auth.resetError();
      _pinController.clear();
    }
  }

  Future<void> _resend(String phoneNumber) async {
    final auth = context.read<AuthProvider>();
    await auth.startPhoneVerification(phoneNumber);
    if (!mounted) return;
    if (auth.status == AuthStatus.codeSent) {
      Fluttertoast.showToast(msg: 'Code resent');
      _startCountdown();
    }
  }

  @override
  Widget build(BuildContext context) {
    final phoneNumber =
        ModalRoute.of(context)?.settings.arguments as String? ?? '';

    return Scaffold(
      appBar: AppBar(title: const Text('Verify code')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 16),
              Text(
                'Enter the 6-digit code sent to\n$phoneNumber',
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 32),
              PinCodeTextField(
                appContext: context,
                length: 6,
                controller: _pinController,
                keyboardType: TextInputType.number,
                animationType: AnimationType.fade,
                autoFocus: true,
                onChanged: (_) {},
                onCompleted: _verify,
                pinTheme: PinTheme(
                  shape: PinCodeFieldShape.box,
                  borderRadius: BorderRadius.circular(10),
                  fieldHeight: 52,
                  fieldWidth: 44,
                  activeColor: AppTheme.primary,
                  selectedColor: AppTheme.primary,
                  inactiveColor: const Color(0xFFE0D6C2),
                ),
              ),
              const SizedBox(height: 16),
              if (_verifying)
                const Center(child: CircularProgressIndicator())
              else
                Center(
                  child: _secondsLeft > 0
                      ? Text('Resend code in $_secondsLeft s',
                          style: const TextStyle(color: Colors.black54))
                      : TextButton(
                          onPressed: () => _resend(phoneNumber),
                          child: const Text('Resend code'),
                        ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
