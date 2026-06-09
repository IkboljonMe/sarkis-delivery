import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';

import '../../l10n/admin_localizations.dart';
import '../../models/approval_model.dart';
import '../../models/order_model.dart';
import '../../services/approval_service.dart';
import '../../services/order_service.dart';
import '../../utils/app_colors.dart';
import '../../utils/app_text_styles.dart';
import '../../widgets/empty_state.dart';
import '../orders/order_detail_screen.dart';

/// Admin review queue: new orders awaiting acceptance + customer profile-change
/// requests (name / phone).
class ApprovalsScreen extends StatelessWidget {
  const ApprovalsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final t = AdminLocalizations.of(context);
    return DefaultTabController(
      length: 2,
      child: Column(
        children: [
          TabBar(
            labelColor: AppColors.primary,
            indicatorColor: AppColors.primary,
            tabs: [
              Tab(text: t.t('apNewOrders')),
              Tab(text: t.t('apProfile')),
            ],
          ),
          Expanded(
            child: TabBarView(
              children: [_ordersTab(), _profileTab()],
            ),
          ),
        ],
      ),
    );
  }

  Widget _ordersTab() {
    return StreamBuilder<List<OrderModel>>(
      stream: OrderService.instance.allOrdersStream(),
      builder: (context, snap) {
        final orders =
            (snap.data ?? []).where((o) => o.pendingApproval).toList();
        if (orders.isEmpty) {
          return const _Empty(text: 'Нет заказов на подтверждение');
        }
        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: orders.length,
          itemBuilder: (_, i) => _orderCard(context, orders[i]),
        );
      },
    );
  }

  Widget _orderCard(BuildContext context, OrderModel o) {
    final date = DateFormat('d MMM').format(o.shiftDate);
    return Container(
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
              Expanded(
                child: Text(o.userName, style: AppTextStyles.bodyBold),
              ),
              Text('€${o.totalPrice.toStringAsFixed(2)}',
                  style: AppTextStyles.bodyBold
                      .copyWith(color: AppColors.primary)),
            ],
          ),
          const SizedBox(height: 4),
          Text(o.itemsSummary,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: AppTextStyles.caption),
          const SizedBox(height: 4),
          Text('Доставка: $date • ${o.userGroup}',
              style: AppTextStyles.label),
          const SizedBox(height: 12),
          Row(
            children: [
              TextButton(
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => OrderDetailScreen(orderId: o.id)),
                ),
                child: const Text('Детали'),
              ),
              const Spacer(),
              OutlinedButton(
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.error,
                  side: const BorderSide(color: AppColors.error),
                ),
                onPressed: () => _reject(o),
                child: const Text('Отклонить'),
              ),
              const SizedBox(width: 8),
              FilledButton(
                style: FilledButton.styleFrom(
                    backgroundColor: AppColors.primary),
                onPressed: () => _accept(o),
                child: const Text('Принять'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _accept(OrderModel o) async {
    await OrderService.instance
        .updateOrder(o.id, {'pendingApproval': false, 'status': 'confirmed'});
    Fluttertoast.showToast(msg: 'Заказ принят');
  }

  Future<void> _reject(OrderModel o) async {
    await OrderService.instance
        .updateOrder(o.id, {'pendingApproval': false, 'status': 'cancelled'});
    Fluttertoast.showToast(msg: 'Заказ отклонён');
  }

  Widget _profileTab() {
    return StreamBuilder<List<ApprovalModel>>(
      stream: ApprovalService.instance.pendingStream(),
      builder: (context, snap) {
        final items = (snap.data ?? [])
            .where((a) => a.type == 'profile')
            .toList();
        if (items.isEmpty) {
          return const _Empty(text: 'Нет запросов на изменение профиля');
        }
        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: items.length,
          itemBuilder: (_, i) => _profileCard(items[i]),
        );
      },
    );
  }

  Widget _profileCard(ApprovalModel a) {
    const labels = {'name': 'Имя', 'phone': 'Телефон'};
    return Container(
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
          Text(a.userName, style: AppTextStyles.bodyBold),
          const SizedBox(height: 8),
          ...a.changes.entries.map((e) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 2),
                child: Row(
                  children: [
                    Text('${labels[e.key] ?? e.key}: ',
                        style: AppTextStyles.caption),
                    Expanded(
                      child: Text('${e.value}',
                          style: AppTextStyles.body),
                    ),
                  ],
                ),
              )),
          const SizedBox(height: 12),
          Row(
            children: [
              const Spacer(),
              OutlinedButton(
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.error,
                  side: const BorderSide(color: AppColors.error),
                ),
                onPressed: () => ApprovalService.instance.reject(a.id),
                child: const Text('Отклонить'),
              ),
              const SizedBox(width: 8),
              FilledButton(
                style:
                    FilledButton.styleFrom(backgroundColor: AppColors.primary),
                onPressed: () async {
                  await ApprovalService.instance.approve(a);
                  Fluttertoast.showToast(msg: 'Одобрено');
                },
                child: const Text('Одобрить'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _Empty extends StatelessWidget {
  final String text;
  const _Empty({required this.text});
  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        const SizedBox(height: 120),
        EmptyState(icon: Icons.fact_check_outlined, title: text),
      ],
    );
  }
}
