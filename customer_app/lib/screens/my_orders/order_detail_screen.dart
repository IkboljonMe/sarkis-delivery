import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../l10n/app_localizations.dart';
import '../../models/order_model.dart';
import '../../services/firebase_service.dart';
import '../messages/messages_screen.dart';
import 'order_status_badge.dart';

class OrderDetailScreen extends StatelessWidget {
  final String orderId;
  const OrderDetailScreen({super.key, required this.orderId});

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final locale = Localizations.localeOf(context).languageCode;

    return Scaffold(
      appBar: AppBar(title: Text(t.myOrders)),
      body: StreamBuilder<OrderModel?>(
        stream: FirebaseService.instance.orderStream(orderId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          final order = snapshot.data;
          if (order == null) {
            return Center(child: Text(t.error));
          }
          final dateLabel = DateFormat('EEEE, d MMM yyyy', locale)
              .format(order.deliveryDate);

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _infoRow(Icons.event, '${t.deliveryDate}: $dateLabel'),
                      const SizedBox(height: 8),
                      _infoRow(Icons.location_on_outlined,
                          '${t.group}: ${order.group}'),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Text('${t.status}: '),
                          OrderStatusBadge(status: order.status),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(t.orderTotal,
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Card(
                child: Column(
                  children: [
                    ...order.items.map((item) => ListTile(
                          dense: true,
                          title: Text(item.name),
                          subtitle: Text(
                              '${item.qty} × €${item.price.toStringAsFixed(2)}'),
                          trailing: Text(
                              '€${item.subtotal.toStringAsFixed(2)}',
                              style: const TextStyle(
                                  fontWeight: FontWeight.w600)),
                        )),
                    const Divider(height: 1),
                    ListTile(
                      title: Text(t.orderTotal,
                          style: const TextStyle(
                              fontWeight: FontWeight.bold)),
                      trailing: Text(
                        '€${order.totalPrice.toStringAsFixed(2)}',
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                    ),
                  ],
                ),
              ),
              if (order.adminNote.isNotEmpty) ...[
                const SizedBox(height: 16),
                Card(
                  color: const Color(0xFFFFF3D6),
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Text(order.adminNote),
                  ),
                ),
              ],
              const SizedBox(height: 16),
              Text(t.messages,
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(4),
                  child: MessagesScreen(orderId: order.id),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _infoRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 18, color: const Color(0xFF9A6500)),
        const SizedBox(width: 8),
        Expanded(child: Text(text)),
      ],
    );
  }
}
