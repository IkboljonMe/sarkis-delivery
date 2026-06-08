import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/order_model.dart';
import '../../providers/group_provider.dart';
import '../../services/order_service.dart';
import '../../utils/app_colors.dart';
import '../../utils/app_text_styles.dart';
import '../../utils/constants.dart';
import '../../widgets/glass_card.dart';
import '../orders/order_detail_screen.dart';
import 'summary_card_widget.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  bool _isToday(DateTime d) {
    final n = DateTime.now();
    return d.year == n.year && d.month == n.month && d.day == n.day;
  }

  @override
  Widget build(BuildContext context) {
    final group = context.watch<GroupProvider>().group;

    return StreamBuilder<List<OrderModel>>(
      stream: OrderService.instance.ordersStream(group),
      builder: (context, snap) {
        final orders = snap.data ?? [];
        final pending =
            orders.where((o) => o.status == AppConstants.statusPending).length;
        final confirmed = orders
            .where((o) => o.status == AppConstants.statusConfirmed)
            .length;
        final onWay = orders
            .where((o) => o.status == AppConstants.statusOnTheWay)
            .length;
        final deliveredToday = orders
            .where((o) =>
                o.status == AppConstants.statusDelivered &&
                _isToday(o.updatedAt ?? o.shiftDate))
            .length;
        final now = DateTime.now();
        final monthIncome = orders
            .where((o) =>
                o.status != AppConstants.statusCancelled &&
                (o.createdAt ?? o.shiftDate).year == now.year &&
                (o.createdAt ?? o.shiftDate).month == now.month)
            .fold(0.0, (s, o) => s + o.totalPrice);

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
                    value: pending,
                    color: AppColors.warning,
                    pulse: pending > 0),
                SummaryCardWidget(
                    title: 'Подтверждено',
                    value: confirmed,
                    color: const Color(0xFF42A5F5)),
                SummaryCardWidget(
                    title: 'В пути',
                    value: onWay,
                    color: const Color(0xFFAB47BC)),
                SummaryCardWidget(
                    title: 'Доставлено сегодня',
                    value: deliveredToday,
                    color: AppColors.success),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: [
                  AppColors.primary.withOpacity(0.18),
                  AppColors.surface,
                ]),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.primary.withOpacity(0.4)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.payments_outlined,
                      color: AppColors.primary),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text('Доход за месяц', style: AppTextStyles.body),
                  ),
                  Text('€${monthIncome.toStringAsFixed(2)}',
                      style: AppTextStyles.headingL
                          .copyWith(color: AppColors.primary)),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Text('Последние заказы', style: AppTextStyles.headingM),
            const SizedBox(height: 12),
            if (orders.isEmpty)
              GlassCard(
                child: Text('Нет заказов', style: AppTextStyles.caption),
              )
            else
              ...orders.take(5).map((o) => _recent(context, o)),
          ],
        );
      },
    );
  }

  Widget _recent(BuildContext context, OrderModel o) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(o.userName, style: AppTextStyles.bodyBold),
                const SizedBox(height: 2),
                Text(o.userAddress,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.caption),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text('€${o.totalPrice.toStringAsFixed(2)}',
                  style: AppTextStyles.price),
              Text(AppConstants.statusLabel(o.status),
                  style: TextStyle(
                      fontSize: 11,
                      color: AppColors.statusColor(o.status))),
            ],
          ),
          IconButton(
            icon: const Icon(Icons.chevron_right,
                color: AppColors.textSecondary),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (_) => OrderDetailScreen(orderId: o.id)),
            ),
          ),
        ],
      ),
    );
  }
}
