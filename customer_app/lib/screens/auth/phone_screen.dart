import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../providers/auth_provider.dart';
import '../../utils/constants.dart';

class PhoneScreen extends StatefulWidget {
  const PhoneScreen({super.key});

  @override
  State<PhoneScreen> createState() => _PhoneScreenState();
}

class _PhoneScreenState extends State<PhoneScreen> {
  final TextEditingController _phoneController = TextEditingController();
  String _countryCode = '+49';

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  String get _fullNumber {
    final digits = _phoneController.text.trim().replaceAll(RegExp(r'\D'), '');
    // Strip the German trunk "0" only for real numbers (those with a non-zero
    // digit). Leave all-zero test numbers like 000000000 untouched.
    final hasNonZero = digits.replaceAll('0', '').isNotEmpty;
    final trimmed =
        (digits.startsWith('0') && hasNonZero) ? digits.substring(1) : digits;
    return '$_countryCode$trimmed';
  }

  Future<void> _continueViaSms() async {
    if (_phoneController.text.trim().isEmpty) {
      Fluttertoast.showToast(msg: 'Enter your phone number');
      return;
    }
    final auth = context.read<AuthProvider>();
    await auth.startPhoneVerification(_fullNumber);
    if (!mounted) return;

    if (auth.status == AuthStatus.codeSent) {
      Navigator.of(context).pushNamed('/otp', arguments: _fullNumber);
    } else if (auth.errorMessage != null) {
      Fluttertoast.showToast(msg: auth.errorMessage!);
      auth.resetError();
    }
  }

  Future<void> _continueViaWhatsApp() async {
    final uri = Uri.parse(
        'https://wa.me/?text=I+want+to+register+on+Sarkis+Bread');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      Fluttertoast.showToast(msg: 'Could not open WhatsApp');
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text('Sarkis Bread')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 12),
              const Icon(Icons.bakery_dining, size: 64, color: Color(0xFFC8860D)),
              const SizedBox(height: 24),
              const Text(
                'Enter your phone number',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFFE0D6C2)),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: _countryCode,
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        items: AppConstants.countryCodes.map((c) {
                          return DropdownMenuItem<String>(
                            value: c['code'],
                            child: Text('${c['flag']} ${c['code']}'),
                          );
                        }).toList(),
                        onChanged: (v) => setState(() => _countryCode = v!),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextField(
                      controller: _phoneController,
                      keyboardType: TextInputType.phone,
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(RegExp(r'[0-9 ]')),
                      ],
                      decoration: const InputDecoration(hintText: '170 1234567'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: auth.busy ? null : _continueViaSms,
                icon: auth.busy
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                            color: Colors.white, strokeWidth: 2),
                      )
                    : const Icon(Icons.sms),
                label: const Text('Continue via SMS'),
              ),
              const SizedBox(height: 12),
              OutlinedButton.icon(
                onPressed: _continueViaWhatsApp,
                icon: const Icon(Icons.chat),
                label: const Text('Continue via WhatsApp'),
              ),
              const SizedBox(height: 24),
              const Text(
                'Cash on delivery • Berlin & Hamburg',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.black54, fontSize: 12),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
