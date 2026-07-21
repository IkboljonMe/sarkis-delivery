import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';

import 'l10n/admin_localizations.dart';
import 'providers/admin_auth_provider.dart';
import 'providers/group_provider.dart';
import 'providers/locale_provider.dart';
import 'services/api_client.dart';
import 'services/local_notifications.dart';
import 'screens/chats/chat_detail_screen.dart';
import 'screens/splash_screen.dart';
import 'utils/app_theme.dart';

/// Root navigator, used to open a chat when a notification is tapped.
final GlobalKey<NavigatorState> adminNavKey = GlobalKey<NavigatorState>();

/// Opens the relevant chat for a tapped notification's data payload.
void routeNotification(Map<String, dynamic> data) {
  if (data['type'] != 'chat') return;
  final topicId = (data['topicId'] as String?) ?? '';
  if (topicId.isEmpty) return;
  final name = (data['senderName'] as String?) ?? 'Чат';
  adminNavKey.currentState?.push(MaterialPageRoute(
    builder: (_) => ChatDetailScreen(topicId: topicId, userName: name),
  ));
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Lock the app to portrait — it is not designed for landscape.
  await SystemChrome.setPreferredOrientations(
      const [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);
  try {
    await dotenv.load(fileName: '.env');
  } catch (e) {
    debugPrint('.env not loaded: $e');
  }
  await LocalNotifications.init();
  LocalNotifications.onSelect = routeNotification;

  // Restore the API session (JWT) before the first screen decides where to go.
  await ApiClient.instance.init();

  final auth = AdminAuthProvider();
  await auth.loadPreferences();
  final group = GroupProvider();
  await group.load();
  final locale = LocaleProvider();
  await locale.load();

  runApp(AdminApp(auth: auth, group: group, locale: locale));
}

class AdminApp extends StatelessWidget {
  final AdminAuthProvider auth;
  final GroupProvider group;
  final LocaleProvider locale;
  const AdminApp(
      {super.key,
      required this.auth,
      required this.group,
      required this.locale});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: auth),
        ChangeNotifierProvider.value(value: group),
        ChangeNotifierProvider.value(value: locale),
      ],
      child: Consumer<LocaleProvider>(
        builder: (context, loc, _) => MaterialApp(
          title: 'Sarko Driver',
          navigatorKey: adminNavKey,
          debugShowCheckedModeBanner: false,
          theme: AppTheme.dark,
          locale: loc.locale,
          supportedLocales: LocaleProvider.supportedLocales,
          localizationsDelegates: const [
            AdminLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          home: const AdminSplashScreen(),
        ),
      ),
    );
  }
}
