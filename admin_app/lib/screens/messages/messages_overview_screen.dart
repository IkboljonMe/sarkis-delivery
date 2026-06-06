import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../models/message_model.dart';
import '../../models/order_model.dart';
import '../../services/firebase_service.dart';
import '../orders/order_detail_screen.dart';

/// Lists orders that have at least one unread customer message.
class MessagesOverviewScreen extends StatelessWidget {
  const MessagesOverviewScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Сообщения')),
      body: StreamBuilder<List<OrderModel>>(
        stream: FirebaseService.instance.allOrdersStream(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          final orders = snapshot.data ?? [];
          if (orders.isEmpty) {
            return const Center(child: Text('Нет заказов'));
          }
          return ListView.builder(
            itemCount: orders.length,
            itemBuilder: (context, i) => _OrderMessageTile(order: orders[i]),
          );
        },
      ),
    );
  }
}

class _OrderMessageTile extends StatelessWidget {
  final OrderModel order;
  const _OrderMessageTile({required this.order});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<MessageModel>>(
      stream: FirebaseService.instance.messagesStream(order.id),
      builder: (context, snapshot) {
        final messages = snapshot.data ?? [];
        final unread =
            messages.where((m) => !m.fromAdmin && !m.isRead).toList();
        // Only show orders with at least one unread customer message.
        if (unread.isEmpty) return const SizedBox.shrink();

        final last = messages.isNotEmpty ? messages.last : null;
        final time = last?.createdAt != null
            ? DateFormat('d MMM, HH:mm').format(last!.createdAt!)
            : '';

        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: Colors.redAccent,
              child: Text('${unread.length}',
                  style: const TextStyle(color: Colors.white)),
            ),
            title: Text(order.userName),
            subtitle: Text(
              last?.text ?? '',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            trailing: Text(time,
                style: const TextStyle(fontSize: 11, color: Colors.black45)),
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => OrderDetailScreen(orderId: order.id),
              ),
            ),
          ),
        );
      },
    );
  }
}
