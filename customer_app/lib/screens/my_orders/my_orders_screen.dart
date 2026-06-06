import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../l10n/app_localizations.dart';
import '../../models/message_model.dart';
import '../../models/order_model.dart';
import '../../providers/auth_provider.dart';
import '../../services/firebase_service.dart';
import 'order_detail_screen.dart';
import 'order_status_badge.dart';

class MyOrdersScreen extends StatelessWidget {
  const MyOrdersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final user = context.watch<AuthProvider>().user;

    return Scaffold(
      appBar: AppBar(title: Text(t.myOrders)),
      body: user == null
          ? Center(child: Text(t.loading))
          : StreamBuilder<List<OrderModel>>(
              stream: FirebaseService.instance.userOrdersStream(user.id),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(child: Text(t.error));
                }
                final orders = snapshot.data ?? [];
                if (orders.isEmpty) {
                  return _Empty(message: t.noOrders);
                }
                return ListView.builder(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  itemCount: orders.length,
                  itemBuilder: (context, i) =>
                      _OrderCard(order: orders[i]),
                );
              },
            ),
    );
  }
}

class _OrderCard extends StatelessWidget {
  final OrderModel order;
  const _OrderCard({required this.order});

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final locale = Localizations.localeOf(context).languageCode;
    final dateLabel =
        DateFormat('EEE, d MMM yyyy', locale).format(order.deliveryDate);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: ListTile(
        contentPadding: const EdgeInsets.all(12),
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => OrderDetailScreen(orderId: order.id),
            ),
          );
        },
        title: Row(
          children: [
            Expanded(
              child: Text(dateLabel,
                  style: const TextStyle(fontWeight: FontWeight.w600)),
            ),
            OrderStatusBadge(status: order.status),
          ],
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 6),
          child: Row(
            children: [
              Text('${order.group} • ${order.itemCount} × ${t.quantity}'),
              const Spacer(),
              Text('€${order.totalPrice.toStringAsFixed(2)}',
                  style: const TextStyle(fontWeight: FontWeight.bold)),
            ],
          ),
        ),
        trailing: _UnreadBadge(orderId: order.id),
      ),
    );
  }
}

/// Live count of unread admin messages for an order.
class _UnreadBadge extends StatelessWidget {
  final String orderId;
  const _UnreadBadge({required this.orderId});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<MessageModel>>(
      stream: FirebaseService.instance.messagesStream(orderId),
      builder: (context, snapshot) {
        final unread = (snapshot.data ?? [])
            .where((m) => m.fromAdmin && !m.isRead)
            .length;
        if (unread == 0) return const SizedBox(width: 8);
        return Container(
          padding: const EdgeInsets.all(6),
          decoration: const BoxDecoration(
            color: Colors.redAccent,
            shape: BoxShape.circle,
          ),
          child: Text('$unread',
              style: const TextStyle(color: Colors.white, fontSize: 12)),
        );
      },
    );
  }
}

class _Empty extends StatelessWidget {
  final String message;
  const _Empty({required this.message});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.receipt_long, size: 64, color: Colors.black26),
          const SizedBox(height: 12),
          Text(message, style: const TextStyle(color: Colors.black54)),
        ],
      ),
    );
  }
}
