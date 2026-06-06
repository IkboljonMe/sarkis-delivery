import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../l10n/app_localizations.dart';
import '../../models/order_model.dart';
import '../../services/order_service.dart';
import '../../utils/app_colors.dart';
import '../../utils/app_text_styles.dart';
import '../../widgets/dark_card.dart';
import '../../widgets/glass_card.dart';
import 'order_status_badge.dart';

class OrderDetailScreen extends StatelessWidget {
  final String orderId;
  const OrderDetailScreen({super.key, required this.orderId});

  static const _steps = ['pending', 'confirmed', 'on_the_way', 'delivered'];

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(title: Text(t.myOrders)),
      body: StreamBuilder<OrderModel?>(
        stream: OrderService.instance.orderStream(orderId),
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          final order = snap.data;
          if (order == null) {
            return Center(child: Text(t.error));
          }
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              if (order.status == 'on_the_way') _driverBanner(t),
              _timeline(order.status),
              const SizedBox(height: 16),
              DarkCard(
                child: Column(
                  children: [
                    ...order.items.map((i) => Padding(
                          padding: const EdgeInsets.symmetric(vertical: 6),
                          child: Row(
                            children: [
                              Expanded(
                                  flex: 3,
                                  child: Text(i.name,
                                      style: AppTextStyles.body)),
                              Expanded(
                                  child: Text('x${i.qty}',
                                      style: AppTextStyles.caption)),
                              Expanded(
                                child: Text(
                                    '€${i.subtotal.toStringAsFixed(2)}',
                                    textAlign: TextAlign.right,
                                    style: AppTextStyles.bodyBold),
                              ),
                            ],
                          ),
                        )),
                    const Divider(color: AppColors.border),
                    Row(
                      children: [
                        Text(t.orderTotal, style: AppTextStyles.bodyBold),
                        const Spacer(),
                        Text('€${order.totalPrice.toStringAsFixed(2)}',
                            style: AppTextStyles.price),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              GlassCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _info(Icons.event,
                        DateFormat('EEEE, d MMM yyyy').format(order.shiftDate)),
                    const SizedBox(height: 8),
                    _info(Icons.location_on_outlined,
                        '${order.userAddress}, ${order.userGroup}'),
                  ],
                ),
              ),
              if (order.adminNote.isNotEmpty) ...[
                const SizedBox(height: 16),
                DarkCard(
                  borderColor: AppColors.primary,
                  child: Row(
                    children: [
                      const Icon(Icons.info_outline,
                          color: AppColors.primary, size: 18),
                      const SizedBox(width: 8),
                      Expanded(
                          child: Text(order.adminNote,
                              style: AppTextStyles.body)),
                    ],
                  ),
                ),
              ],
            ],
          );
        },
      ),
    );
  }

  Widget _driverBanner(AppLocalizations t) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        gradient: AppColors.goldGradient,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          const Icon(Icons.local_shipping, color: Colors.white),
          const SizedBox(width: 12),
          Text(t.driverComing,
              style: AppTextStyles.bodyBold.copyWith(color: Colors.white)),
        ],
      ),
    );
  }

  Widget _timeline(String status) {
    final currentIndex = _steps.indexOf(status);
    if (status == 'cancelled') {
      return DarkCard(
        borderColor: AppColors.error,
        child: Row(
          children: const [
            Icon(Icons.cancel, color: AppColors.error),
            SizedBox(width: 8),
            Text('Cancelled', style: TextStyle(color: AppColors.error)),
          ],
        ),
      );
    }
    return Row(
      children: List.generate(_steps.length, (i) {
        final done = i <= currentIndex;
        return Expanded(
          child: Row(
            children: [
              Column(
                children: [
                  CircleAvatar(
                    radius: 12,
                    backgroundColor:
                        done ? AppColors.primary : AppColors.surfaceElevated,
                    child: Icon(
                      done ? Icons.check : Icons.circle,
                      size: 12,
                      color: done ? Colors.white : AppColors.textMuted,
                    ),
                  ),
                ],
              ),
              if (i < _steps.length - 1)
                Expanded(
                  child: Container(
                    height: 2,
                    color: i < currentIndex
                        ? AppColors.primary
                        : AppColors.border,
                  ),
                ),
            ],
          ),
        );
      }),
    );
  }

  Widget _info(IconData icon, String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: AppColors.primary),
        const SizedBox(width: 8),
        Expanded(child: Text(text, style: AppTextStyles.body)),
      ],
    );
  }
}
