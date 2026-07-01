import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';

import '../../l10n/app_localizations.dart';
import '../../models/order_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/order_provider.dart';
import '../../utils/app_colors.dart';
import '../../utils/app_text_styles.dart';
import '../../widgets/app_lottie.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/loading_shimmer.dart';
import 'order_detail_screen.dart';
import 'order_status_badge.dart';

class MyOrdersScreen extends StatelessWidget {
  const MyOrdersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final user = context.watch<AuthProvider>().user;
    final orderProvider = context.read<OrderProvider>();

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text(t.myOrders),
          bottom: TabBar(
            indicatorColor: AppColors.primary,
            labelColor: AppColors.primary,
            unselectedLabelColor: AppColors.textSecondary,
            tabs: [
              Tab(text: t.activeOrders),
              Tab(text: t.completedOrders),
            ],
          ),
        ),
        body: user == null
            ? Center(child: Text(t.loading))
            : StreamBuilder<List<OrderModel>>(
                stream: orderProvider.userOrdersStream(user.id),
                builder: (context, snap) {
                  if (snap.connectionState == ConnectionState.waiting) {
                    return const LoadingShimmer();
                  }
                  if (snap.hasError) {
                    return Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.error_outline,
                              color: AppColors.error, size: 40),
                          const SizedBox(height: 12),
                          Text(t.t('somethingWrong'),
                              style: AppTextStyles.body,
                              textAlign: TextAlign.center),
                          const SizedBox(height: 12),
                          OutlinedButton.icon(
                            onPressed: () =>
                                (context as Element).markNeedsBuild(),
                            icon: const Icon(Icons.refresh),
                            label: Text(t.t('retry')),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: AppColors.primary,
                              side: const BorderSide(color: AppColors.primary),
                            ),
                          ),
                        ],
                      ),
                    );
                  }
                  final orders = snap.data ?? [];
                  return TabBarView(
                    children: [
                      _list(orderProvider.active(orders), t),
                      _list(orderProvider.completed(orders), t),
                    ],
                  );
                },
              ),
      ),
    );
  }

  Widget _list(List<OrderModel> orders, AppLocalizations t) {
    if (orders.isEmpty) {
      return EmptyState(
          animation: AppAnim.thumbsUp,
          icon: Icons.receipt_long,
          title: t.noOrders);
    }
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
      itemCount: orders.length,
      itemBuilder: (context, i) => _OrderCard(order: orders[i])
          .animate()
          .fadeIn(delay: (60 * i).ms)
          .slideY(begin: 0.08),
    );
  }
}

class _OrderCard extends StatelessWidget {
  final OrderModel order;
  const _OrderCard({required this.order});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
            builder: (_) => OrderDetailScreen(orderId: order.id)),
      ),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text('#${order.shortId}', style: AppTextStyles.bodyBold),
                const Spacer(),
                OrderStatusBadge(status: order.status),
              ],
            ),
            const SizedBox(height: 8),
            Text(order.itemsSummary,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.caption),
            const SizedBox(height: 8),
            Row(
              children: [
                Text('${order.shiftLabel} • ${order.userGroup}',
                    style: AppTextStyles.caption),
                const Spacer(),
                Text('€${order.totalPrice.toStringAsFixed(2)}',
                    style: AppTextStyles.price),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
