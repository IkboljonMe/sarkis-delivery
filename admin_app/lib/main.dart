import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'demo_firebase_options.dart';
import 'providers/admin_auth_provider.dart';
import 'providers/group_provider.dart';
import 'services/local_notifications.dart';
import 'screens/splash_screen.dart';
import 'utils/app_theme.dart';

@pragma('vm:entry-point')
Future<void> _bgHandler(RemoteMessage message) async {
  await Firebase.initializeApp(options: DemoFirebaseOptions.current);
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await Firebase.initializeApp(options: DemoFirebaseOptions.current);
    FirebaseMessaging.onBackgroundMessage(_bgHandler);
    await LocalNotifications.init();
  } catch (e) {
    debugPrint('Firebase init skipped: $e');
  }

  final auth = AdminAuthProvider();
  await auth.loadPreferences();
  final group = GroupProvider();
  await group.load();

  runApp(AdminApp(auth: auth, group: group));
}

class AdminApp extends StatelessWidget {
  final AdminAuthProvider auth;
  final GroupProvider group;
  const AdminApp({super.key, required this.auth, required this.group});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: auth),
        ChangeNotifierProvider.value(value: group),
      ],
      child: MaterialApp(
        title: 'Sarkis Bread Admin',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.dark,
        home: const AdminSplashScreen(),
      ),
    );
  }
}
