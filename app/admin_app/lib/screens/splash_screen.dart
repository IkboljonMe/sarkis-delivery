import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';

import '../providers/admin_auth_provider.dart';
import '../services/push_service.dart';
import '../sync/sync_engine.dart';
import '../utils/app_colors.dart';
import '../utils/app_text_styles.dart';
import '../widgets/brand_logo.dart';
import 'auth/login_screen.dart';
import 'main_scaffold.dart';

class AdminSplashScreen extends StatefulWidget {
  const AdminSplashScreen({super.key});

  @override
  State<AdminSplashScreen> createState() => _AdminSplashScreenState();
}

class _AdminSplashScreenState extends State<AdminSplashScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _route());
  }

  Future<void> _route() async {
    await Future.delayed(const Duration(seconds: 2));
    if (!mounted) return;
    final loggedIn = context.read<AdminAuthProvider>().isLoggedIn;
    if (loggedIn) {
      SyncEngine.instance.fullSync().catchError((_) {});
      SyncEngine.instance.start();
      PushService.instance.register(); // background/closed-app push
    }
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => loggedIn ? const MainScaffold() : const LoginScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const BrandLogo(size: 96)
                .animate()
                .scale(duration: 500.ms, curve: Curves.easeOutBack),
            const SizedBox(height: 20),
            Text('Sarko Driver', style: AppTextStyles.headingXL)
                .animate()
                .fadeIn(delay: 300.ms),
            Text('Admin Panel', style: AppTextStyles.caption)
                .animate()
                .fadeIn(delay: 500.ms),
          ],
        ),
      ),
    );
  }
}
