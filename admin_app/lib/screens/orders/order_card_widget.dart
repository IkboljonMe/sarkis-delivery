import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../models/message_model.dart';
import '../../models/order_model.dart';
import '../../services/firebase_service.dart';
import '../../utils/constants.dart';
import '../../utils/theme.dart';

class OrderCardWidget extends StatelessWidget {
  final OrderModel order;
  final VoidCallback onTap;

  const OrderCardWidget({
    super.key,
    required this.order,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final dateLabel = DateFormat('EEE, d MMM').format(order.deliveryDate);
    final statusColor = AppTheme.statusColor(order.status);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(order.userName,
                        style: const TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold)),
                  ),
                  _badge(
                      AppConstants.statusLabelsRu[order.status] ?? order.status,
                      statusColor),
                ],
              ),
              const SizedBox(height: 4),
              Text(order.userPhone,
                  style: const TextStyle(color: Colors.black54)),
              Text(order.userAddress,
                  style: const TextStyle(color: Colors.black54)),
              const SizedBox(height: 8),
              Row(
                children: [
                  _badge(
                      AppConstants.groupLabelsRu[order.group] ?? order.group,
                      const Color(0xFF9A6500)),
                  const SizedBox(width: 8),
                  Text('$dateLabel'),
                  const Spacer(),
                  Text('${order.itemCount} шт.'),
                  const SizedBox(width: 8),
                  Text('€${order.totalPrice.toStringAsFixed(2)}',
                      style: const TextStyle(fontWeight: FontWeight.bold)),
                ],
              ),
              _UnreadRow(orderId: order.id),
            ],
          ),
        ),
      ),
    );
  }

  Widget _badge(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.4)),
      ),
      child: Text(text,
          style: TextStyle(
              color: color, fontSize: 12, fontWeight: FontWeight.w600)),
    );
  }
}

class _UnreadRow extends StatelessWidget {
  final String orderId;
  const _UnreadRow({required this.orderId});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<MessageModel>>(
      stream: FirebaseService.instance.messagesStream(orderId),
      builder: (context, snapshot) {
        final unread = (snapshot.data ?? [])
            .where((m) => !m.fromAdmin && !m.isRead)
            .length;
        if (unread == 0) return const SizedBox.shrink();
        return Padding(
          padding: const EdgeInsets.only(top: 8),
          child: Row(
            children: [
              const Icon(Icons.mark_chat_unread,
                  size: 16, color: Colors.redAccent),
              const SizedBox(width: 4),
              Text('$unread новых сообщений',
                  style: const TextStyle(
                      color: Colors.redAccent, fontSize: 12)),
            ],
          ),
        );
      },
    );
  }
}
