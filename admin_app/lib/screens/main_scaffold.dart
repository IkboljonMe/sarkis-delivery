import 'dart:async';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';

import '../providers/admin_auth_provider.dart';
import '../providers/group_provider.dart';
import '../services/fcm_service.dart';
import '../utils/app_colors.dart';
import '../utils/app_text_styles.dart';
import '../utils/constants.dart';
import '../widgets/brand_logo.dart';
import 'auth/login_screen.dart';
import 'chats/chats_screen.dart';
import 'coupons/coupons_screen.dart';
import 'dashboard/dashboard_screen.dart';
import 'orders/orders_screen.dart';
import 'products/products_screen.dart';
import 'reports/reports_screen.dart';
import 'route/route_screen.dart';
import 'settings/settings_screen.dart';
import 'shifts/shifts_screen.dart';

/// Admin shell: a NavigationDrawer selects the active section.
class MainScaffold extends StatefulWidget {
  const MainScaffold({super.key});

  @override
  State<MainScaffold> createState() => _MainScaffoldState();
}

class _MainScaffoldState extends State<MainScaffold> {
  int _index = 0;
  static const _chatsIndex = 4;
  final List<StreamSubscription> _subs = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _initMessaging());
  }

  void _initMessaging() {
    final uid = context.read<AdminAuthProvider>().uid;
    if (uid != null) FcmService.instance.registerToken(uid);

    _subs.add(FcmService.instance.onForegroundMessage.listen((m) {
      final n = m.notification;
      if (n != null) {
        Fluttertoast.showToast(
            msg: '${n.title ?? ''}: ${n.body ?? ''}'.trim());
      }
    }));
    _subs.add(FcmService.instance.onMessageOpened.listen((m) {
      if (m.data['type'] == 'chat' && mounted) {
        setState(() => _index = _chatsIndex);
      }
    }));
  }

  @override
  void dispose() {
    for (final s in _subs) {
      s.cancel();
    }
    super.dispose();
  }

  static const _titles = [
    'Главная',
    'Заказы',
    'Товары',
    'Купоны',
    'Чаты',
    'Смены',
    'Маршрут',
    'Отчёты',
    'Настройки',
  ];

  static const _icons = [
    Icons.dashboard_outlined,
    Icons.receipt_long_outlined,
    Icons.storefront_outlined,
    Icons.local_offer_outlined,
    Icons.chat_bubble_outline,
    Icons.event_note_outlined,
    Icons.alt_route_outlined,
    Icons.insights_outlined,
    Icons.settings_outlined,
  ];

  List<Widget> get _pages => const [
        DashboardScreen(),
        OrdersScreen(),
        ProductsScreen(),
        CouponsScreen(),
        ChatsScreen(),
        ShiftsScreen(),
        RouteScreen(),
        ReportsScreen(),
        SettingsScreen(),
      ];

  Future<void> _switchGroup() async {
    final group = context.read<GroupProvider>();
    await showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surfaceElevated,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Сменить группу', style: AppTextStyles.headingM),
            const SizedBox(height: 16),
            ...AppConstants.groupsWithAll.map((g) {
              final sel = group.group == g;
              return ListTile(
                leading: Icon(Icons.location_city,
                    color: sel ? AppColors.primary : AppColors.textSecondary),
                title: Text(AppConstants.groupLabel(g),
                    style: AppTextStyles.body),
                trailing: sel
                    ? const Icon(Icons.check_circle, color: AppColors.primary)
                    : null,
                onTap: () {
                  group.setGroup(g);
                  Navigator.pop(ctx);
                },
              );
            }),
          ],
        ),
      ),
    );
  }

  Future<void> _logout() async {
    await context.read<AdminAuthProvider>().logout();
    if (!mounted) return;
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (r) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final group = context.watch<GroupProvider>();
    return Scaffold(
      appBar: AppBar(
        title: Text(_titles[_index]),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: ActionChip(
              avatar: const Icon(Icons.location_city,
                  size: 16, color: AppColors.primary),
              label: Text(group.label),
              backgroundColor: AppColors.surface,
              onPressed: _switchGroup,
            ),
          ),
        ],
      ),
      drawer: _drawer(group),
      body: IndexedStack(index: _index, children: _pages),
    );
  }

  Widget _drawer(GroupProvider group) {
    return Drawer(
      backgroundColor: AppColors.surface,
      child: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  const BrandLogo(size: 44),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Sarkis Bread', style: AppTextStyles.headingM),
                        Text('Admin', style: AppTextStyles.caption),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const Divider(color: AppColors.border),
            Expanded(
              child: ListView.builder(
                itemCount: _titles.length,
                itemBuilder: (context, i) {
                  final sel = i == _index;
                  return ListTile(
                    leading: Icon(_icons[i],
                        color: sel
                            ? AppColors.primary
                            : AppColors.textSecondary),
                    title: Text(_titles[i],
                        style: AppTextStyles.body.copyWith(
                            color: sel
                                ? AppColors.primary
                                : AppColors.textPrimary)),
                    selected: sel,
                    onTap: () {
                      setState(() => _index = i);
                      Navigator.pop(context);
                    },
                  );
                },
              ),
            ),
            const Divider(color: AppColors.border),
            ListTile(
              leading: const Icon(Icons.swap_horiz, color: AppColors.primary),
              title: Text('Группа: ${group.label}',
                  style: AppTextStyles.body),
              onTap: () {
                Navigator.pop(context);
                _switchGroup();
              },
            ),
            ListTile(
              leading: const Icon(Icons.logout, color: AppColors.error),
              title: Text('Выйти',
                  style: AppTextStyles.body
                      .copyWith(color: AppColors.error)),
              onTap: _logout,
            ),
          ],
        ),
      ),
    );
  }
}
