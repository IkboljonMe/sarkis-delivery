import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../models/message_model.dart';
import '../../models/order_model.dart';
import '../../providers/admin_order_provider.dart';
import '../../services/firebase_service.dart';
import '../../services/fcm_service.dart';
import '../../services/navigation_service.dart';
import '../../utils/constants.dart';
import '../../utils/theme.dart';
import 'status_button_row.dart';

class OrderDetailScreen extends StatefulWidget {
  final String orderId;
  const OrderDetailScreen({super.key, required this.orderId});

  @override
  State<OrderDetailScreen> createState() => _OrderDetailScreenState();
}

class _OrderDetailScreenState extends State<OrderDetailScreen> {
  final _messageController = TextEditingController();
  bool _sending = false;

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  Future<void> _changeStatus(OrderModel order, String status) async {
    final provider = context.read<AdminOrderProvider>();
    final ok = await provider.updateStatus(order.id, status);
    if (!mounted) return;
    if (ok) {
      Fluttertoast.showToast(msg: 'Статус обновлён');
      // Notify the customer of the status change.
      final user = await FirebaseService.instance.getUser(order.userId);
      if (user != null && user.fcmToken.isNotEmpty) {
        await FcmService.instance.sendNotificationToUser(
          user.fcmToken,
          'Sarkis Bread',
          'Статус вашего заказа: ${AppConstants.statusLabelsRu[status] ?? status}',
          data: {'orderId': order.id},
        );
      }
    } else {
      Fluttertoast.showToast(msg: 'Ошибка обновления');
    }
  }

  Future<void> _sendMessage(OrderModel order) async {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;
    setState(() => _sending = true);
    final provider = context.read<AdminOrderProvider>();
    final ok = await provider.sendMessage(order.id, text);
    if (!mounted) return;

    if (ok) {
      _messageController.clear();
      final user = await FirebaseService.instance.getUser(order.userId);
      if (user != null && user.fcmToken.isNotEmpty) {
        await FcmService.instance.sendNotificationToUser(
          user.fcmToken,
          'Sarkis Bread',
          text,
          data: {'orderId': order.id},
        );
      }
    } else {
      Fluttertoast.showToast(msg: 'Ошибка отправки');
    }
    if (mounted) setState(() => _sending = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Заказ')),
      body: StreamBuilder<OrderModel?>(
        stream: FirebaseService.instance.orderStream(widget.orderId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          final order = snapshot.data;
          if (order == null) {
            return const Center(child: Text('Заказ не найден'));
          }
          return Column(
            children: [
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.all(12),
                  children: [
                    _customerCard(order),
                    const SizedBox(height: 12),
                    _itemsCard(order),
                    const SizedBox(height: 12),
                    _statusCard(order),
                    const SizedBox(height: 12),
                    _messagesSection(order),
                  ],
                ),
              ),
              _messageInput(order),
            ],
          );
        },
      ),
    );
  }

  Widget _customerCard(OrderModel order) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(order.userName,
                style: const TextStyle(
                    fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            InkWell(
              onTap: () =>
                  NavigationService.instance.callPhone(order.userPhone),
              child: Row(
                children: [
                  const Icon(Icons.phone, size: 18, color: Colors.green),
                  const SizedBox(width: 8),
                  Text(order.userPhone,
                      style: const TextStyle(
                          color: Colors.blue,
                          decoration: TextDecoration.underline)),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.location_on_outlined, size: 18),
                const SizedBox(width: 8),
                Expanded(child: Text(order.userAddress)),
              ],
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryDark),
                onPressed: () => NavigationService.instance
                    .openGoogleMapsNavigation(order.userAddress),
                icon: const Icon(Icons.navigation),
                label: const Text('НАВИГАЦИЯ'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _itemsCard(OrderModel order) {
    final dateLabel =
        DateFormat('EEEE, d MMM yyyy').format(order.deliveryDate);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Доставка: $dateLabel •'
                ' ${AppConstants.groupLabelsRu[order.group] ?? order.group}'),
            const Divider(),
            Table(
              columnWidths: const {
                0: FlexColumnWidth(3),
                1: FlexColumnWidth(1),
                2: FlexColumnWidth(1.5),
                3: FlexColumnWidth(1.5),
              },
              children: [
                const TableRow(children: [
                  Text('Товар',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  Text('Кол',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  Text('Цена',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  Text('Сумма',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                ]),
                ...order.items.map((i) => TableRow(children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: Text(i.name),
                      ),
                      Text('${i.qty}'),
                      Text('€${i.price.toStringAsFixed(2)}'),
                      Text('€${i.subtotal.toStringAsFixed(2)}'),
                    ])),
              ],
            ),
            const Divider(),
            Align(
              alignment: Alignment.centerRight,
              child: Text('Итого: €${order.totalPrice.toStringAsFixed(2)}',
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 16)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _statusCard(OrderModel order) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Text('Статус: '),
                Text(
                  AppConstants.statusLabelsRu[order.status] ?? order.status,
                  style: TextStyle(
                      color: AppTheme.statusColor(order.status),
                      fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 8),
            StatusButtonRow(
              currentStatus: order.status,
              onChange: (status) => _changeStatus(order, status),
            ),
          ],
        ),
      ),
    );
  }

  Widget _messagesSection(OrderModel order) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.all(8),
              child: Text('Сообщения',
                  style: TextStyle(fontWeight: FontWeight.bold)),
            ),
            StreamBuilder<List<MessageModel>>(
              stream: FirebaseService.instance.messagesStream(order.id),
              builder: (context, snapshot) {
                final messages = snapshot.data ?? [];
                if (messages.isEmpty) {
                  return const Padding(
                    padding: EdgeInsets.all(16),
                    child: Text('Нет сообщений',
                        style: TextStyle(color: Colors.black45)),
                  );
                }
                return ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: messages.length,
                  itemBuilder: (context, i) => _bubble(messages[i]),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _bubble(MessageModel m) {
    final time = m.createdAt != null
        ? DateFormat('d MMM, HH:mm').format(m.createdAt!)
        : '';
    return Align(
      alignment: m.fromAdmin ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 4),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        constraints: BoxConstraints(
            maxWidth: MediaQuery.of(context).size.width * 0.7),
        decoration: BoxDecoration(
          color: m.fromAdmin
              ? const Color(0xFFF1E7D2)
              : Colors.grey.shade200,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(m.text),
            const SizedBox(height: 2),
            Text(time,
                style:
                    const TextStyle(fontSize: 10, color: Colors.black45)),
          ],
        ),
      ),
    );
  }

  Widget _messageInput(OrderModel order) {
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: _messageController,
                minLines: 1,
                maxLines: 4,
                decoration: const InputDecoration(
                  hintText: 'Сообщение клиенту...',
                  contentPadding:
                      EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                ),
              ),
            ),
            const SizedBox(width: 8),
            _sending
                ? const Padding(
                    padding: EdgeInsets.all(8),
                    child: SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(strokeWidth: 2)),
                  )
                : IconButton.filled(
                    icon: const Icon(Icons.send),
                    onPressed: () => _sendMessage(order),
                  ),
          ],
        ),
      ),
    );
  }
}
