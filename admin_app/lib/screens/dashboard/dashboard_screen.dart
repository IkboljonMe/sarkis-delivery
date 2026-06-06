import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/order_model.dart';
import '../../providers/admin_auth_provider.dart';
import '../../providers/admin_order_provider.dart';
import '../../utils/constants.dart';
import '../auth/login_screen.dart';
import '../dates/delivery_dates_screen.dart';
import '../messages/messages_overview_screen.dart';
import '../orders/orders_screen.dart';
import '../products/products_screen.dart';
import '../settings/settings_screen.dart';
import 'summary_card_widget.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  bool _isToday(DateTime d) {
    final now = DateTime.now();
    return d.year == now.year && d.month == now.month && d.day == now.day;
  }

  Future<void> _logout(BuildContext context) async {
    await context.read<AdminAuthProvider>().logout();
    if (!context.mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.read<AdminOrderProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Sarkis Bread Admin'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => _logout(context),
          ),
        ],
      ),
      body: StreamBuilder<List<OrderModel>>(
        stream: provider.ordersStream(),
        builder: (context, snapshot) {
          final orders = snapshot.data ?? [];
          final pending = orders
              .where((o) => o.status == AppConstants.statusPending)
              .toList();
          final today =
              orders.where((o) => _isToday(o.deliveryDate)).length;
          final berlinPending = pending
              .where((o) => o.group == AppConstants.groupBerlin)
              .length;
          final hamburgPending = pending
              .where((o) => o.group == AppConstants.groupHamburg)
              .length;

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: 1.5,
                children: [
                  SummaryCardWidget(
                    title: 'Новые заказы',
                    value: '${pending.length}',
                    icon: Icons.fiber_new,
                    color: Colors.orange,
                  ),
                  SummaryCardWidget(
                    title: 'Заказов сегодня',
                    value: '$today',
                    icon: Icons.today,
                    color: Colors.blue,
                  ),
                  SummaryCardWidget(
                    title: 'Берлин (новые)',
                    value: '$berlinPending',
                    icon: Icons.location_city,
                    color: Colors.purple,
                  ),
                  SummaryCardWidget(
                    title: 'Гамбург (новые)',
                    value: '$hamburgPending',
                    icon: Icons.location_city,
                    color: Colors.teal,
                  ),
                ],
              ),
              const SizedBox(height: 24),
              _action(context, Icons.event, 'Даты доставки',
                  const DeliveryDatesScreen()),
              _action(context, Icons.receipt_long, 'Все заказы',
                  const OrdersScreen()),
              _action(context, Icons.bakery_dining, 'Товары',
                  const ProductsScreen()),
              _action(context, Icons.message, 'Сообщения',
                  const MessagesOverviewScreen()),
              _action(context, Icons.settings, 'Настройки',
                  const SettingsScreen()),
            ],
          );
        },
      ),
    );
  }

  Widget _action(
      BuildContext context, IconData icon, String label, Widget screen) {
    return Card(
      child: ListTile(
        leading: Icon(icon, color: const Color(0xFFC8860D)),
        title: Text(label,
            style: const TextStyle(fontWeight: FontWeight.w600)),
        trailing: const Icon(Icons.chevron_right),
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => screen),
        ),
      ),
    );
  }
}
