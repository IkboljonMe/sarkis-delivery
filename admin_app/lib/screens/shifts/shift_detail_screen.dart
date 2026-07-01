import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../models/order_model.dart';
import '../../models/shift_model.dart';
import '../../services/navigation_service.dart';
import '../../services/order_service.dart';
import '../../utils/app_colors.dart';
import '../../utils/app_text_styles.dart';
import '../../utils/constants.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/gold_badge.dart';
import '../orders/order_detail_screen.dart';

class ShiftDetailScreen extends StatelessWidget {
  final ShiftModel shift;
  const ShiftDetailScreen({super.key, required this.shift});

  static const _finished = ['delivered', 'cancelled'];

  Future<void> _markDelivered(BuildContext context, OrderModel o) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Отметить доставленным?'),
        content: Text('${o.userName} • #${o.shortId}'),
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
    if (ok == true) {
      await OrderService.instance
          .updateStatus(o.id, AppConstants.statusDelivered);
    }
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text('Смена ${DateFormat('d MMM').format(shift.date)}'),
          bottom: const TabBar(
            indicatorColor: AppColors.primary,
            labelColor: AppColors.primary,
            unselectedLabelColor: AppColors.textSecondary,
            tabs: [Tab(text: 'Активные'), Tab(text: 'Завершённые')],
          ),
        ),
        body: StreamBuilder<List<OrderModel>>(
          stream: OrderService.instance.ordersByShiftStream(shift.id),
          builder: (context, snap) {
            if (snap.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            final orders = snap.data ?? [];
            final unfinished =
                orders.where((o) => !_finished.contains(o.status)).toList();
            final finished =
                orders.where((o) => _finished.contains(o.status)).toList();
            return TabBarView(
              children: [
                _list(context, unfinished, active: true),
                _list(context, finished, active: false),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _list(BuildContext context, List<OrderModel> orders,
      {required bool active}) {
    if (orders.isEmpty) {
      return EmptyState(
          icon: Icons.inbox,
          title: active ? 'Нет активных заказов' : 'Нет завершённых');
    }
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: orders.length,
      itemBuilder: (context, i) {
        final o = orders[i];
        return Opacity(
          opacity: active ? 1 : 0.6,
          child: Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.border),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text('#${i + 1}',
                        style: AppTextStyles.headingM
                            .copyWith(color: AppColors.primary)),
                    const SizedBox(width: 8),
                    Expanded(
                        child: Text(o.userName,
                            style: AppTextStyles.bodyBold)),
                    Text(AppConstants.price(o.totalPrice),
                        style: AppTextStyles.price),
                  ],
                ),
                const SizedBox(height: 6),
                GestureDetector(
                  onTap: () => NavigationService.instance
                      .copyToClipboard(o.userAddress),
                  child: Row(
                    children: [
                      const Icon(Icons.copy,
                          size: 14, color: AppColors.textSecondary),
                      const SizedBox(width: 6),
                      Expanded(
                          child: Text(o.userAddress,
                              style: AppTextStyles.caption)),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    GoldBadge(text: AppConstants.statusLabel(o.status)),
                    const Spacer(),
                    TextButton(
                      onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) =>
                                OrderDetailScreen(orderId: o.id)),
                      ),
                      child: const Text('Детали'),
                    ),
                    if (active)
                      TextButton(
                        onPressed: () => _markDelivered(context, o),
                        child: const Text('Доставлено',
                            style: TextStyle(color: AppColors.success)),
                      ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
