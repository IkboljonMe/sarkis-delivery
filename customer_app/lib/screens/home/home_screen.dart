import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../l10n/app_localizations.dart';
import '../../models/delivery_date_model.dart';
import '../../providers/auth_provider.dart';
import '../../services/firebase_service.dart';
import '../../widgets/bottom_nav_bar.dart';
import '../my_orders/my_orders_screen.dart';
import '../orders/order_screen.dart';
import '../profile/profile_screen.dart';
import 'date_card_widget.dart';

/// Root authenticated screen hosting the three bottom-nav tabs.
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    final pages = const [
      _DeliveryDatesTab(),
      MyOrdersScreen(),
      ProfileScreen(),
    ];

    return Scaffold(
      body: IndexedStack(index: _index, children: pages),
      bottomNavigationBar: AppBottomNavBar(
        currentIndex: _index,
        onTap: (i) => setState(() => _index = i),
      ),
    );
  }
}

class _DeliveryDatesTab extends StatelessWidget {
  const _DeliveryDatesTab();

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final user = context.watch<AuthProvider>().user;

    return Scaffold(
      appBar: AppBar(title: Text(t.appName)),
      body: user == null
          ? Center(child: Text(t.loading))
          : StreamBuilder<List<DeliveryDateModel>>(
              stream: FirebaseService.instance
                  .openDeliveryDatesStream(user.group),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return _ErrorState(message: t.error);
                }
                final dates = snapshot.data ?? [];
                if (dates.isEmpty) {
                  return _EmptyState(message: t.noDeliveryDates);
                }
                return RefreshIndicator(
                  onRefresh: () async {
                    // Stream auto-refreshes; small delay for UX.
                    await Future.delayed(const Duration(milliseconds: 400));
                  },
                  child: ListView.builder(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    itemCount: dates.length,
                    itemBuilder: (context, i) {
                      final d = dates[i];
                      return DateCardWidget(
                        deliveryDate: d,
                        onOrder: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => OrderScreen(deliveryDate: d),
                            ),
                          );
                        },
                      );
                    },
                  ),
                );
              },
            ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final String message;
  const _EmptyState({required this.message});

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        const SizedBox(height: 120),
        const Icon(Icons.event_busy, size: 64, color: Colors.black26),
        const SizedBox(height: 16),
        Text(
          message,
          textAlign: TextAlign.center,
          style: const TextStyle(color: Colors.black54, fontSize: 16),
        ),
      ],
    );
  }
}

class _ErrorState extends StatelessWidget {
  final String message;
  const _ErrorState({required this.message});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.error_outline, size: 56, color: Colors.redAccent),
          const SizedBox(height: 12),
          Text(message),
        ],
      ),
    );
  }
}
