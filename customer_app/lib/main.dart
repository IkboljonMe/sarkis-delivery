import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';

import 'demo_firebase_options.dart';
import 'l10n/app_localizations.dart';
import 'providers/auth_provider.dart';
import 'providers/locale_provider.dart';
import 'providers/order_provider.dart';
import 'screens/auth/otp_screen.dart';
import 'screens/auth/phone_screen.dart';
import 'screens/auth/profile_setup_screen.dart';
import 'screens/home/home_screen.dart';
import 'screens/splash_screen.dart';
import 'utils/theme.dart';

/// Background FCM handler must be a top-level function.
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

  final localeProvider = LocaleProvider();
  await localeProvider.load();

  runApp(SarkisBreadApp(localeProvider: localeProvider));
}

class SarkisBreadApp extends StatelessWidget {
  final LocaleProvider localeProvider;
  const SarkisBreadApp({super.key, required this.localeProvider});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => OrderProvider()),
        ChangeNotifierProvider.value(value: localeProvider),
      ],
      child: Consumer<LocaleProvider>(
        builder: (context, locale, _) {
          return MaterialApp(
            title: 'Sarkis Bread',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.light,
            locale: locale.locale,
            supportedLocales: LocaleProvider.supportedLocales,
            localizationsDelegates: const [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            initialRoute: '/',
            routes: {
              '/': (_) => const SplashScreen(),
              '/phone': (_) => const PhoneScreen(),
              '/otp': (_) => const OtpScreen(),
              '/profileSetup': (_) => const ProfileSetupScreen(),
              '/home': (_) => const HomeScreen(),
            },
          );
        },
      ),
    );
  }
}
