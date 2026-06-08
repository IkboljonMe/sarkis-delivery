import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';

import '../../providers/admin_auth_provider.dart';
import '../../utils/app_colors.dart';
import '../../utils/app_text_styles.dart';
import '../../widgets/brand_logo.dart';
import '../../widgets/app_input_field.dart';
import '../../widgets/golden_button.dart';
import '../main_scaffold.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _obscure = true;
  bool _shake = false;

  @override
  void initState() {
    super.initState();
    _email.text = context.read<AdminAuthProvider>().savedEmail;
  }

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;
    final auth = context.read<AdminAuthProvider>();
    final ok = await auth.login(_email.text.trim(), _password.text);
    if (!mounted) return;
    if (ok) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const MainScaffold()),
      );
    } else {
      setState(() => _shake = true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AdminAuthProvider>();

    Widget form = Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Center(child: BrandLogo(size: 84)),
          const SizedBox(height: 16),
          Text('Sarkis Bread',
              textAlign: TextAlign.center, style: AppTextStyles.headingXL),
          Text('Панель управления',
              textAlign: TextAlign.center, style: AppTextStyles.caption),
          const SizedBox(height: 32),
          AppInputField(
            controller: _email,
            label: 'Email',
            prefixIcon: Icons.email_outlined,
            keyboardType: TextInputType.emailAddress,
            validator: (v) =>
                (v == null || !v.contains('@')) ? 'Email?' : null,
          ),
          const SizedBox(height: 16),
          AppInputField(
            controller: _password,
            label: 'Пароль / Password',
            prefixIcon: Icons.lock_outline,
            obscureText: _obscure,
            validator: (v) => (v == null || v.isEmpty) ? 'Пароль?' : null,
            suffix: IconButton(
              icon: Icon(
                  _obscure ? Icons.visibility : Icons.visibility_off,
                  color: AppColors.textSecondary),
              onPressed: () => setState(() => _obscure = !_obscure),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Checkbox(
                value: auth.rememberMe,
                onChanged: (v) => auth.setRememberMe(v ?? false),
                activeColor: AppColors.primary,
              ),
              Text('Запомнить меня', style: AppTextStyles.caption),
            ],
          ),
          if (auth.error != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Text(auth.error!,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: AppColors.error)),
            ),
          const SizedBox(height: 8),
          GoldenButton(
            label: 'Войти / Login',
            loading: auth.busy,
            onPressed: _login,
          ),
        ],
      ),
    );

    if (_shake) {
      form = form
          .animate(onComplete: (_) => setState(() => _shake = false))
          .shakeX(amount: 6, duration: 400.ms);
    }

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: form,
          ),
        ),
      ),
    );
  }
}
