import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/auth_provider.dart';
import '../utils/theme.dart';

/// Shows the brand briefly, then routes based on auth + profile state.
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _decideRoute());
  }

  Future<void> _decideRoute() async {
    await Future.delayed(const Duration(milliseconds: 900));
    if (!mounted) return;

    final auth = context.read<AuthProvider>();
    if (!auth.isLoggedIn) {
      Navigator.of(context).pushReplacementNamed('/phone');
      return;
    }

    final user = await auth.loadCurrentUser();
    if (!mounted) return;
    if (user == null) {
      // Logged in but no profile yet.
      Navigator.of(context).pushReplacementNamed('/profileSetup');
    } else {
      Navigator.of(context).pushReplacementNamed('/home');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.primary,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: const [
            Icon(Icons.bakery_dining, size: 96, color: Colors.white),
            SizedBox(height: 16),
            Text(
              'Sarkis Bread',
              style: TextStyle(
                color: Colors.white,
                fontSize: 30,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.5,
              ),
            ),
            SizedBox(height: 24),
            SizedBox(
              width: 28,
              height: 28,
              child: CircularProgressIndicator(
                  color: Colors.white, strokeWidth: 3),
            ),
          ],
        ),
      ),
    );
  }
}
