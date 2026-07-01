import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../models/order_model.dart';
import '../../models/user_model.dart';
import '../../providers/group_provider.dart';
import '../../services/order_service.dart';
import '../../services/user_service.dart';
import '../../utils/app_colors.dart';
import '../../utils/app_text_styles.dart';
import '../../utils/constants.dart';
import '../../utils/reports_aggregator.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/glass_card.dart';
import '../orders/order_detail_screen.dart';

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key});

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabs = TabController(length: 2, vsync: this);
  ReportPeriod _period = ReportPeriod.month;
  String _statusFilter = ''; // '' all | delivered | active

  @override
  void dispose() {
    _tabs.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final group = context.watch<GroupProvider>().group;
    return Column(
      children: [
        Container(
          color: AppColors.surface,
          child: TabBar(
            indicatorSize: TabBarIndicatorSize.tab,
            controller: _tabs,
            indicatorColor: AppColors.primary,
            labelColor: AppColors.primary,
            unselectedLabelColor: AppColors.textSecondary,
            tabs: const [
              Tab(text: 'Доходы'),
              Tab(text: 'Клиенты'),
            ],
          ),
        ),
        Expanded(
          child: TabBarView(
            controller: _tabs,
            children: [
              _incomeTab(group),
              _clientsTab(group),
            ],
          ),
        ),
      ],
    );
  }

  // ---- Income --------------------------------------------------------------
  Widget _incomeTab(String group) {
    return StreamBuilder<List<OrderModel>>(
      stream: OrderService.instance.ordersStream(group),
      builder: (context, snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        // Income = everything that wasn't cancelled.
        final all = (snap.data ?? [])
            .where((o) => o.status != AppConstants.statusCancelled)
            .toList();
        List<OrderModel> orders = all;
        if (_statusFilter == 'delivered') {
          orders = all
              .where((o) => o.status == AppConstants.statusDelivered)
              .toList();
        } else if (_statusFilter == 'active') {
          orders = all
              .where((o) => o.status != AppConstants.statusDelivered)
              .toList();
        }

        final buckets = ReportsAggregator.bucketize(orders, _period);
        final grand = ReportsAggregator.grandTotal(orders);
        final delivered = ReportsAggregator.deliveredTotal(orders);
        final discount = ReportsAggregator.discountTotal(orders);
        final avg = ReportsAggregator.averageCheck(orders);
        final recent = ReportsAggregator.recentFirst(orders);

        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _periodSelector(),
            const SizedBox(height: 12),
            _statusChips(),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                    child: _totalCard('Выручка', grand, orders.length,
                        AppColors.primary)),
                const SizedBox(width: 12),
                Expanded(
                    child: _totalCard('Доставлено', delivered, null,
                        AppColors.success)),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                    child: _totalCard('Средний чек', avg, null,
                        AppColors.textSecondary)),
                const SizedBox(width: 12),
                Expanded(
                    child: _totalCard('Скидки', discount, null,
                        AppColors.error)),
              ],
            ),
            const SizedBox(height: 20),
            Text('График выручки', style: AppTextStyles.headingM),
            const SizedBox(height: 12),
            _incomeChart(buckets),
            const SizedBox(height: 20),
            Text('Разбивка', style: AppTextStyles.headingM),
            const SizedBox(height: 12),
            if (buckets.isEmpty)
              GlassCard(
                child: Text('Нет данных', style: AppTextStyles.caption),
              )
            else
              ...buckets.map(_bucketRow),
            const SizedBox(height: 20),
            Text('Заказы', style: AppTextStyles.headingM),
            const SizedBox(height: 12),
            if (recent.isEmpty)
              GlassCard(child: Text('Нет заказов', style: AppTextStyles.caption))
            else
              ...recent.take(60).map((o) => _orderRow(o)),
          ],
        );
      },
    );
  }

  Widget _statusChips() {
    Widget chip(String label, String value) {
      final sel = _statusFilter == value;
      return Padding(
        padding: const EdgeInsets.only(right: 8),
        child: ChoiceChip(
          label: Text(label),
          selected: sel,
          selectedColor: AppColors.primary.withOpacity(0.2),
          onSelected: (_) => setState(() => _statusFilter = value),
        ),
      );
    }

    return SizedBox(
      height: 40,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          chip('Все', ''),
          chip('Доставленные', 'delivered'),
          chip('Активные', 'active'),
        ],
      ),
    );
  }

  /// Uber-style earnings bar chart for the most recent buckets.
  Widget _incomeChart(List<IncomeBucket> buckets) {
    if (buckets.isEmpty) {
      return GlassCard(child: Text('Нет данных', style: AppTextStyles.caption));
    }
    final chrono = buckets.reversed.toList();
    final shown =
        chrono.length > 8 ? chrono.sublist(chrono.length - 8) : chrono;
    final maxV =
        shown.map((b) => b.total).fold(0.0, (a, b) => a > b ? a : b);
    return Container(
      padding: const EdgeInsets.fromLTRB(8, 14, 8, 10),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: shown.map((b) {
          final frac = maxV <= 0 ? 0.0 : b.total / maxV;
          final short = b.label.split(RegExp(r'[ –]')).first;
          return Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text(AppConstants.price(b.total, decimals: 0),
                    style: const TextStyle(
                        fontSize: 9, color: AppColors.textSecondary)),
                const SizedBox(height: 4),
                Container(
                  height: (frac * 120).clamp(4.0, 120.0),
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  decoration: const BoxDecoration(
                    gradient: AppColors.goldGradient,
                    borderRadius: BorderRadius.vertical(top: Radius.circular(6)),
                  ),
                )
                    .animate()
                    .scaleY(
                        begin: 0,
                        end: 1,
                        alignment: Alignment.bottomCenter,
                        duration: 450.ms,
                        curve: Curves.easeOut),
                const SizedBox(height: 6),
                Text(short,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                        fontSize: 9, color: AppColors.textMuted)),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _orderRow(OrderModel o) {
    final d = DateFormat('dd.MM.yyyy').format(o.createdAt ?? o.shiftDate);
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: ListTile(
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => OrderDetailScreen(orderId: o.id)),
        ),
        title: Text(o.userName.isEmpty ? o.userPhone : o.userName,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTextStyles.bodyBold),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('$d • ${o.itemCount} тов. • ${AppConstants.statusLabel(o.status)}',
                style: AppTextStyles.caption),
            if (o.discount > 0)
              Text(
                  'Скидка €${o.discount.toStringAsFixed(2)}'
                  '${o.couponCode.isNotEmpty ? ' (${o.couponCode})' : ''}',
                  style: AppTextStyles.caption
                      .copyWith(color: AppColors.primary)),
          ],
        ),
        trailing: Text(AppConstants.price(o.totalPrice),
            style: AppTextStyles.price),
      ),
    );
  }

  Widget _periodSelector() {
    Widget chip(String label, ReportPeriod p) {
      final sel = _period == p;
      return Expanded(
        child: GestureDetector(
          onTap: () => setState(() => _period = p),
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 4),
            padding: const EdgeInsets.symmetric(vertical: 10),
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: sel ? AppColors.primary.withOpacity(0.18) : AppColors.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                  color: sel ? AppColors.primary : AppColors.border),
            ),
            child: Text(label,
                style: AppTextStyles.body.copyWith(
                    color: sel ? AppColors.primary : AppColors.textSecondary,
                    fontWeight: sel ? FontWeight.bold : FontWeight.normal)),
          ),
        ),
      );
    }

    return Row(
      children: [
        chip('По месяцам', ReportPeriod.month),
        chip('По неделям', ReportPeriod.week),
        chip('По сменам', ReportPeriod.shift),
      ],
    );
  }

  Widget _totalCard(String title, double amount, int? count, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: AppTextStyles.caption),
          const SizedBox(height: 6),
          Text(AppConstants.price(amount),
              style: AppTextStyles.headingL.copyWith(color: color)),
          if (count != null)
            Text('$count заказ(ов)', style: AppTextStyles.caption),
        ],
      ),
    );
  }

  Widget _bucketRow(IncomeBucket b) {
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
                Text(b.label, style: AppTextStyles.bodyBold),
                Text('${b.count} заказ(ов)', style: AppTextStyles.caption),
              ],
            ),
          ),
          Text(AppConstants.price(b.total), style: AppTextStyles.price),
        ],
      ),
    );
  }

  // ---- Clients -------------------------------------------------------------
  Widget _clientsTab(String group) {
    return StreamBuilder<List<UserModel>>(
      stream: UserService.instance.usersStream(),
      builder: (context, uSnap) {
        if (uSnap.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        var users = (uSnap.data ?? []).where((u) => !u.isAdmin).toList();
        if (!AppConstants.isAllGroups(group)) {
          users = users.where((u) => u.group == group).toList();
        }
        return StreamBuilder<List<OrderModel>>(
          stream: OrderService.instance.ordersStream(group),
          builder: (context, oSnap) {
            final orders = oSnap.data ?? [];
            final byUser = ReportsAggregator.ordersByUser(orders);
            // Sort users by most recent order first.
            DateTime lastOf(UserModel u) =>
                ReportsAggregator.lastOrderDate(byUser[u.id] ?? const []);

            users.sort((a, b) => lastOf(b).compareTo(lastOf(a)));
            final withOrders =
                users.where((u) => (byUser[u.id]?.isNotEmpty ?? false)).length;

            if (users.isEmpty) {
              return const EmptyState(
                  icon: Icons.people_outline, title: 'Нет клиентов');
            }
            return ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Row(
                  children: [
                    Expanded(
                        child: _miniStat('Клиентов', '${users.length}')),
                    const SizedBox(width: 12),
                    Expanded(
                        child: _miniStat('С заказами', '$withOrders')),
                  ],
                ),
                const SizedBox(height: 16),
                ...users.map((u) => _clientRow(u, byUser[u.id] ?? const [])),
              ],
            );
          },
        );
      },
    );
  }

  Widget _miniStat(String label, String value) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(value,
              style: AppTextStyles.headingL.copyWith(color: AppColors.primary)),
          Text(label, style: AppTextStyles.caption),
        ],
      ),
    );
  }

  Widget _clientRow(UserModel u, List<OrderModel> orders) {
    final life = ReportsAggregator.clientLifetime(orders);
    final sub = orders.isEmpty
        ? 'Нет заказов'
        : '${orders.length} заказ(ов) • ${AppConstants.price(life.spent)} • '
            'последний ${DateFormat('dd.MM.yyyy').format(life.last!)}';

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
          CircleAvatar(
            radius: 18,
            backgroundColor: AppColors.surfaceElevated,
            child: Text(
                u.fullName.isNotEmpty ? u.fullName[0].toUpperCase() : '?',
                style: const TextStyle(color: AppColors.primary)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(u.fullName.isEmpty ? u.phone : u.fullName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTextStyles.bodyBold),
                    ),
                    const SizedBox(width: 6),
                    Text(AppConstants.groupLabel(u.group),
                        style: AppTextStyles.caption
                            .copyWith(color: AppColors.primary)),
                  ],
                ),
                const SizedBox(height: 2),
                Text(sub,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.caption),
              ],
            ),
          ),
          if (orders.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.chevron_right,
                  color: AppColors.textSecondary),
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (_) =>
                        OrderDetailScreen(orderId: orders.first.id)),
              ),
            ),
        ],
      ),
    );
  }
}
