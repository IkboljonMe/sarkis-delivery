import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../models/message_model.dart';
import '../../models/order_model.dart';
import '../../providers/admin_auth_provider.dart';
import '../../services/fcm_service.dart';
import '../../services/message_service.dart';
import '../../services/navigation_service.dart';
import '../../services/order_service.dart';
import '../../services/user_service.dart';
import '../../utils/app_colors.dart';
import '../../utils/app_text_styles.dart';
import '../../utils/constants.dart';
import '../../widgets/glass_card.dart';
import '../../widgets/golden_button.dart';

class OrderDetailScreen extends StatefulWidget {
  final String orderId;
  const OrderDetailScreen({super.key, required this.orderId});

  @override
  State<OrderDetailScreen> createState() => _OrderDetailScreenState();
}

class _OrderDetailScreenState extends State<OrderDetailScreen> {
  final _message = TextEditingController();
  bool _sending = false;

  static List<String> _next(String status) {
    switch (status) {
      case 'pending':
        return ['confirmed', 'cancelled'];
      case 'confirmed':
        return ['on_the_way', 'cancelled'];
      case 'on_the_way':
        return ['delivered'];
      default:
        return [];
    }
  }

  @override
  void dispose() {
    _message.dispose();
    super.dispose();
  }

  Future<void> _changeStatus(OrderModel o, String status) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Изменить статус?'),
        content: Text('Новый статус: ${AppConstants.statusLabel(status)}'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Отмена')),
          TextButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Да')),
        ],
      ),
    );
    if (ok != true) return;
    await OrderService.instance.updateStatus(o.id, status);

    // Post a status update into the customer's chat thread.
    final statusMsg =
        '📦 Заказ #${o.shortId}: ${AppConstants.statusLabel(status)}';
    final admin = context.read<AdminAuthProvider>();
    await MessageService.instance.ensureTopic(
        topicId: o.userId, userName: o.userName, userGroup: o.userGroup);
    await MessageService.instance.sendMessage(
      topicId: o.userId,
      text: statusMsg,
      senderId: admin.uid ?? 'admin',
      senderName: 'Admin',
      isFromAdmin: true,
    );

    final user = await UserService.instance.getUser(o.userId);
    if (user != null && user.fcmToken.isNotEmpty) {
      await FcmService.instance.sendToUser(
        user.fcmToken,
        'Sarkis Bread',
        statusMsg,
        data: {'orderId': o.id},
      );
    }
    Fluttertoast.showToast(msg: 'Статус обновлён');
  }

  Future<void> _send(OrderModel o) async {
    final text = _message.text.trim();
    if (text.isEmpty) return;
    setState(() => _sending = true);
    final admin = context.read<AdminAuthProvider>();
    await MessageService.instance.ensureTopic(
        topicId: o.userId, userName: o.userName, userGroup: o.userGroup);
    await MessageService.instance.sendMessage(
      topicId: o.userId,
      text: text,
      senderId: admin.uid ?? 'admin',
      senderName: 'Admin',
      isFromAdmin: true,
    );
    _message.clear();
    final user = await UserService.instance.getUser(o.userId);
    if (user != null && user.fcmToken.isNotEmpty) {
      await FcmService.instance
          .sendToUser(user.fcmToken, 'Sarkis Bread', text, data: {'orderId': o.id});
    }
    if (mounted) setState(() => _sending = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Заказ')),
      body: StreamBuilder<OrderModel?>(
        stream: OrderService.instance.orderStream(widget.orderId),
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          final o = snap.data;
          if (o == null) return const Center(child: Text('Не найдено'));
          return Column(
            children: [
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    _customer(o),
                    const SizedBox(height: 12),
                    _items(o),
                    const SizedBox(height: 12),
                    _status(o),
                    const SizedBox(height: 12),
                    _chat(o),
                  ],
                ),
              ),
              _inputBar(o),
            ],
          );
        },
      ),
    );
  }

  Widget _customer(OrderModel o) {
    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(o.userName, style: AppTextStyles.headingM),
          const SizedBox(height: 8),
          GestureDetector(
            onTap: () => NavigationService.instance.callPhone(o.userPhone),
            child: Row(children: [
              const Icon(Icons.phone, size: 16, color: AppColors.success),
              const SizedBox(width: 8),
              Text(o.userPhone,
                  style: const TextStyle(color: AppColors.primary)),
            ]),
          ),
          const SizedBox(height: 8),
          GestureDetector(
            onTap: () =>
                NavigationService.instance.copyToClipboard(o.userAddress),
            child: Row(children: [
              const Icon(Icons.location_on_outlined,
                  size: 16, color: AppColors.textSecondary),
              const SizedBox(width: 8),
              Expanded(child: Text(o.userAddress, style: AppTextStyles.body)),
              const Icon(Icons.copy, size: 14, color: AppColors.textMuted),
            ]),
          ),
          const SizedBox(height: 12),
          GoldenButton(
            label: 'НАВИГАЦИЯ',
            icon: Icons.navigation,
            onPressed: () => NavigationService.instance
                .openGoogleMapsNavigation(o.userAddress),
          ),
        ],
      ),
    );
  }

  Widget _items(OrderModel o) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          Row(children: [
            const Icon(Icons.event, size: 16, color: AppColors.primary),
            const SizedBox(width: 8),
            Text(DateFormat('EEEE, d MMM yyyy').format(o.shiftDate),
                style: AppTextStyles.caption),
          ]),
          const Divider(color: AppColors.border),
          ...o.items.map((i) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(children: [
                  Expanded(flex: 3, child: Text(i.name, style: AppTextStyles.body)),
                  Expanded(child: Text('x${i.qty}', style: AppTextStyles.caption)),
                  Expanded(
                      child: Text('€${i.unitPrice.toStringAsFixed(2)}',
                          style: AppTextStyles.caption)),
                  Expanded(
                      child: Text('€${i.subtotal.toStringAsFixed(2)}',
                          textAlign: TextAlign.right,
                          style: AppTextStyles.bodyBold)),
                ]),
              )),
          const Divider(color: AppColors.border),
          if (o.discount > 0) ...[
            Row(children: [
              Text('Сумма', style: AppTextStyles.caption),
              const Spacer(),
              Text('€${o.subtotal.toStringAsFixed(2)}',
                  style: AppTextStyles.body),
            ]),
            const SizedBox(height: 4),
            Row(children: [
              Text(
                  o.couponCode.isNotEmpty
                      ? 'Скидка (${o.couponCode})'
                      : 'Скидка',
                  style: AppTextStyles.caption
                      .copyWith(color: AppColors.primary)),
              const Spacer(),
              Text('−€${o.discount.toStringAsFixed(2)}',
                  style: AppTextStyles.body
                      .copyWith(color: AppColors.primary)),
            ]),
            const SizedBox(height: 6),
          ],
          Row(children: [
            Text('Итого', style: AppTextStyles.bodyBold),
            const Spacer(),
            Text('€${o.totalPrice.toStringAsFixed(2)}',
                style: AppTextStyles.price),
          ]),
        ],
      ),
    );
  }

  Widget _status(OrderModel o) {
    final next = _next(o.status);
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Text('Статус: ', style: AppTextStyles.body),
            Text(AppConstants.statusLabel(o.status),
                style: TextStyle(
                    color: AppColors.statusColor(o.status),
                    fontWeight: FontWeight.bold)),
          ]),
          if (next.isNotEmpty) ...[
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: next.map((s) {
                final cancel = s == 'cancelled';
                return ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: cancel
                        ? AppColors.error
                        : AppColors.statusColor(s),
                    foregroundColor: Colors.white,
                  ),
                  onPressed: () => _changeStatus(o, s),
                  child: Text(AppConstants.statusLabel(s)),
                );
              }).toList(),
            ),
          ],
        ],
      ),
    );
  }

  Widget _chat(OrderModel o) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(8),
            child: Text('Сообщения', style: AppTextStyles.bodyBold),
          ),
          StreamBuilder<List<MessageModel>>(
            stream: MessageService.instance.messagesStream(o.userId),
            builder: (context, snap) {
              final msgs = snap.data ?? [];
              if (msgs.isEmpty) {
                return Padding(
                  padding: const EdgeInsets.all(12),
                  child: Text('Нет сообщений', style: AppTextStyles.caption),
                );
              }
              return ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: msgs.length,
                itemBuilder: (context, i) => _bubble(msgs[i]),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _bubble(MessageModel m) {
    final admin = m.isFromAdmin;
    final time =
        m.createdAt != null ? DateFormat('d MMM HH:mm').format(m.createdAt!) : '';
    return Align(
      alignment: admin ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 4),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        constraints:
            BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.7),
        decoration: BoxDecoration(
          gradient: admin ? AppColors.goldGradient : null,
          color: admin ? null : AppColors.surfaceElevated,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(m.text,
                style: TextStyle(
                    color: admin ? Colors.white : AppColors.textPrimary)),
            Text(time,
                style: TextStyle(
                    fontSize: 10,
                    color: admin ? Colors.white70 : AppColors.textMuted)),
          ],
        ),
      ),
    );
  }

  Widget _inputBar(OrderModel o) {
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Row(children: [
          Expanded(
            child: TextField(
              controller: _message,
              style: AppTextStyles.body,
              minLines: 1,
              maxLines: 4,
              decoration: const InputDecoration(hintText: 'Сообщение...'),
            ),
          ),
          const SizedBox(width: 8),
          _sending
              ? const Padding(
                  padding: EdgeInsets.all(10),
                  child: SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(strokeWidth: 2)),
                )
              : GestureDetector(
                  onTap: () => _send(o),
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: const BoxDecoration(
                        gradient: AppColors.goldGradient,
                        shape: BoxShape.circle),
                    child:
                        const Icon(Icons.send, color: Colors.white, size: 20),
                  ),
                ),
        ]),
      ),
    );
  }
}
