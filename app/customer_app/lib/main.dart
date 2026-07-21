import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';

import 'l10n/app_localizations.dart';
import 'providers/auth_provider.dart';
import 'providers/cart_provider.dart';
import 'providers/locale_provider.dart';
import 'providers/message_provider.dart';
import 'providers/order_provider.dart';
import 'services/api_client.dart';
import 'services/local_notifications.dart';
import 'screens/auth/language_screen.dart';
import 'screens/auth/otp_screen.dart';
import 'screens/auth/phone_screen.dart';
import 'screens/auth/register_screen.dart';
import 'screens/auth/welcome_screen.dart';
import 'screens/main_shell.dart';
import 'screens/splash_screen.dart';
import 'utils/app_theme.dart';

/// When a notification is tapped, the requested tab index for MainShell
/// (2 = chats, 1 = orders). MainShell listens and switches.
final ValueNotifier<int?> kRequestedTab = ValueNotifier<int?>(null);

void routeNotification(Map<String, dynamic> data) {
  final type = data['type'];
  if (type == 'chat') {
    kRequestedTab.value = 2;
  } else if (type == 'order') {
    kRequestedTab.value = 1;
  }
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Lock the app to portrait — it is not designed for landscape.
  await SystemChrome.setPreferredOrientations(
      const [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);
  // Loads GOOGLE_GEOCODING_API_KEY (used for address geocoding + static maps).
  try {
    await dotenv.load(fileName: '.env');
  } catch (e) {
    debugPrint('.env not loaded: $e');
  }
  await LocalNotifications.init();
  LocalNotifications.onSelect = routeNotification;

  // Restore the API session (JWT) before the first screen decides where to go.
  await ApiClient.instance.init();

  final localeProvider = LocaleProvider();
  await localeProvider.load();
  final cartProvider = CartProvider();
  await cartProvider.loadPersisted();

  runApp(SarkoApp(localeProvider: localeProvider, cartProvider: cartProvider));
}

class SarkoApp extends StatelessWidget {
  final LocaleProvider localeProvider;
  final CartProvider cartProvider;
  const SarkoApp({
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
          title: 'Sarko Delivery',
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
            '/welcome': (_) => const WelcomeScreen(),
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
