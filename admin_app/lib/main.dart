import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'demo_firebase_options.dart';
import 'providers/admin_auth_provider.dart';
import 'providers/admin_order_provider.dart';
import 'screens/auth/login_screen.dart';
import 'screens/dashboard/dashboard_screen.dart';
import 'utils/theme.dart';

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Guarded init so the app boots even without real Firebase config / envs.
  try {
    await Firebase.initializeApp(options: DemoFirebaseOptions.current);
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  } catch (e) {
    debugPrint('Firebase init skipped/failed (demo mode): $e');
  }

  final authProvider = AdminAuthProvider();
  await authProvider.loadPreferences();

  runApp(AdminApp(authProvider: authProvider));
}

class AdminApp extends StatelessWidget {
  final AdminAuthProvider authProvider;
  const AdminApp({super.key, required this.authProvider});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: authProvider),
        ChangeNotifierProvider(create: (_) => AdminOrderProvider()),
      ],
      child: MaterialApp(
        title: 'Sarkis Bread Admin',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light,
        home: authProvider.isLoggedIn
            ? const DashboardScreen()
            : const LoginScreen(),
        routes: {
          '/login': (_) => const LoginScreen(),
          '/dashboard': (_) => const DashboardScreen(),
        },
      ),
    );
  }
}
