import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../main.dart';
import '../l10n/app_localizations.dart';
import '../providers/auth_provider.dart';
import '../providers/message_provider.dart';
import '../realtime/socket_service.dart';
import '../services/local_notifications.dart';
import '../widgets/bottom_nav_bar.dart';
import 'chats/chats_screen.dart';
import 'home/home_screen.dart';
import 'orders/my_orders_screen.dart';
import 'profile/settings_screen.dart';

/// Authenticated shell hosting the 4 customer tabs with a floating nav bar.
class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _index = 0;
  final List<StreamSubscription> _subs = [];

  @override
  void initState() {
    super.initState();
    _subs.add(SocketService.instance.events.listen((event) {
      if (event.name != 'notification:created') return;
      LocalNotifications.showFromPayload(
        Map<String, dynamic>.from(event.payload as Map),
      );
    }));
    // Notification taps set kRequestedTab; switch to it.
    kRequestedTab.addListener(_onRequestedTab);
    if (kRequestedTab.value != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _onRequestedTab());
    }
  }

  void _onRequestedTab() {
    final tab = kRequestedTab.value;
    if (tab != null && mounted) {
      setState(() => _index = tab);
      kRequestedTab.value = null;
    }
  }

  @override
  void dispose() {
    kRequestedTab.removeListener(_onRequestedTab);
    for (final s in _subs) {
      s.cancel();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final uid = context.watch<AuthProvider>().uid;

    final pages = const [
      HomeScreen(),
      MyOrdersScreen(),
      ChatsScreen(),
      SettingsScreen(),
    ];

    final items = [
      NavItem(Icons.home_outlined, Icons.home, t.home),
      NavItem(Icons.receipt_long_outlined, Icons.receipt_long, t.myOrders),
      NavItem(Icons.chat_bubble_outline, Icons.chat_bubble, t.chats),
      NavItem(Icons.settings_outlined, Icons.settings, t.t('settings')),
    ];

    return Scaffold(
      extendBody: true,
      body: IndexedStack(index: _index, children: pages),
      bottomNavigationBar: uid == null
          ? BottomNavBar(
              currentIndex: _index,
              onTap: (i) => setState(() => _index = i),
              items: items,
            )
          : StreamBuilder<int>(
              stream: context.read<MessageProvider>().unreadStream(uid),
              builder: (context, snap) => BottomNavBar(
                currentIndex: _index,
                onTap: (i) => setState(() => _index = i),
                items: items,
                unreadChats: snap.data ?? 0,
              ),
            ),
    );
  }
}
