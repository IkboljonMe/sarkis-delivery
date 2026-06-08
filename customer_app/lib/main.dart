import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';

import 'demo_firebase_options.dart';
import 'l10n/app_localizations.dart';
import 'providers/auth_provider.dart';
import 'providers/cart_provider.dart';
import 'providers/locale_provider.dart';
import 'providers/message_provider.dart';
import 'providers/order_provider.dart';
import 'screens/auth/language_screen.dart';
import 'screens/auth/otp_screen.dart';
import 'screens/auth/phone_screen.dart';
import 'screens/auth/register_screen.dart';
import 'screens/main_shell.dart';
import 'screens/splash_screen.dart';
import 'utils/app_theme.dart';

@pragma('vm:entry-point')
Future<void> _bgHandler(RemoteMessage message) async {
  await Firebase.initializeApp(options: DemoFirebaseOptions.current);
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Loads GOOGLE_GEOCODING_API_KEY (used for address geocoding + static maps).
  try {
    await dotenv.load(fileName: '.env');
  } catch (e) {
    debugPrint('.env not loaded: $e');
  }
  try {
    await Firebase.initializeApp(options: DemoFirebaseOptions.current);
    FirebaseMessaging.onBackgroundMessage(_bgHandler);
  } catch (e) {
    debugPrint('Firebase init skipped: $e');
  }

  final localeProvider = LocaleProvider();
  await localeProvider.load();
  final cartProvider = CartProvider();
  await cartProvider.loadPersisted();

  runApp(SarkisApp(localeProvider: localeProvider, cartProvider: cartProvider));
}

class SarkisApp extends StatelessWidget {
  final LocaleProvider localeProvider;
  final CartProvider cartProvider;
  const SarkisApp({
    super.key,
    required this.localeProvider,
    required this.cartProvider,
  });

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => OrderProvider()),
        ChangeNotifierProvider(create: (_) => MessageProvider()),
        ChangeNotifierProvider.value(value: cartProvider),
        ChangeNotifierProvider.value(value: localeProvider),
      ],
      child: Consumer<LocaleProvider>(
        builder: (context, locale, _) => MaterialApp(
          title: 'Sarkis Bread',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.dark,
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
            '/language': (_) => const LanguageScreen(),
            '/phone': (_) => const PhoneScreen(),
            '/otp': (_) => const OtpScreen(),
            '/register': (_) => const RegisterScreen(),
            '/main': (_) => const MainShell(),
          },
        ),
      ),
    );
  }
}
