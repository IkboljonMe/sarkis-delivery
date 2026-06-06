import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';

/// Shared bottom navigation used by the customer's main tabs.
class AppBottomNavBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const AppBottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    return BottomNavigationBar(
      currentIndex: currentIndex,
      onTap: onTap,
      type: BottomNavigationBarType.fixed,
      selectedItemColor: Theme.of(context).primaryColor,
      unselectedItemColor: Colors.grey,
      items: [
        BottomNavigationBarItem(
          icon: const Icon(Icons.home_outlined),
          activeIcon: const Icon(Icons.home),
          label: t.home,
        ),
        BottomNavigationBarItem(
          icon: const Icon(Icons.receipt_long_outlined),
          activeIcon: const Icon(Icons.receipt_long),
          label: t.myOrders,
        ),
        BottomNavigationBarItem(
          icon: const Icon(Icons.person_outline),
          activeIcon: const Icon(Icons.person),
          label: t.profile,
        ),
      ],
    );
  }
}
