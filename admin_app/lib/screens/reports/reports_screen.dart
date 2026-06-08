import 'package:flutter/material.dart';
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
import '../../widgets/empty_state.dart';
import '../../widgets/glass_card.dart';
import '../orders/order_detail_screen.dart';

const _ruMonths = [
  'Янв', 'Фев', 'Мар', 'Апр', 'Май', 'Июн',
  'Июл', 'Авг', 'Сен', 'Окт', 'Ноя', 'Дек'
];

enum _Period { month, week, shift }

/// A single income bucket (month / week / shift).
class _Bucket {
  final String key;
  final String label;
  final DateTime sortDate;
  double total = 0;
  int count = 0;
  _Bucket(this.key, this.label, this.sortDate);
}

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key});

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabs = TabController(length: 2, vsync: this);
  _Period _period = _Period.month;

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
        final orders = (snap.data ?? [])
            .where((o) => o.status != AppConstants.statusCancelled)
            .toList();
        final buckets = _bucketize(orders);
        final grand = orders.fold(0.0, (s, o) => s + o.totalPrice);
        final delivered = orders
            .where((o) => o.status == AppConstants.statusDelivered)
            .fold(0.0, (s, o) => s + o.totalPrice);

        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _periodSelector(),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                    child: _totalCard('Всего (без отмен)', grand, orders.length,
                        AppColors.primary)),
                const SizedBox(width: 12),
                Expanded(
                    child: _totalCard('Доставлено', delivered, null,
                        AppColors.success)),
              ],
            ),
            const SizedBox(height: 20),
            Text('Разбивка', style: AppTextStyles.headingM),
            const SizedBox(height: 12),
            if (buckets.isEmpty)
              GlassCard(
                child: Text('Нет данных', style: AppTextStyles.caption),
              )
            else
              ...buckets.map(_bucketRow),
          ],
        );
      },
    );
  }

  Widget _periodSelector() {
    Widget chip(String label, _Period p) {
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
        chip('По месяцам', _Period.month),
        chip('По неделям', _Period.week),
        chip('По сменам', _Period.shift),
      ],
    );
  }

  List<_Bucket> _bucketize(List<OrderModel> orders) {
    final map = <String, _Bucket>{};
    for (final o in orders) {
      final d = o.createdAt ?? o.shiftDate;
      late String key;
      late String label;
      late DateTime sortDate;
      switch (_period) {
        case _Period.month:
          key = DateFormat('yyyy-MM').format(d);
          label = '${_ruMonths[d.month - 1]} ${d.year}';
          sortDate = DateTime(d.year, d.month);
          break;
        case _Period.week:
          final monday = d.subtract(Duration(days: d.weekday - 1));
          final sunday = monday.add(const Duration(days: 6));
          key = DateFormat('yyyy-MM-dd').format(monday);
          label =
              '${DateFormat('dd.MM').format(monday)} – ${DateFormat('dd.MM').format(sunday)}';
          sortDate = monday;
          break;
        case _Period.shift:
          key = o.shiftId.isEmpty ? 'no-shift' : o.shiftId;
          final g = AppConstants.groupLabel(o.userGroup);
          label = o.shiftLabel.isEmpty
              ? 'Без смены'
              : '${o.shiftLabel} • $g';
          sortDate = o.shiftDate;
          break;
      }
      final b = map.putIfAbsent(key, () => _Bucket(key, label, sortDate));
      b.total += o.totalPrice;
      b.count += 1;
    }
    final list = map.values.toList()
      ..sort((a, b) => b.sortDate.compareTo(a.sortDate));
    return list;
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
          Text('€${amount.toStringAsFixed(2)}',
              style: AppTextStyles.headingL.copyWith(color: color)),
          if (count != null)
            Text('$count заказ(ов)', style: AppTextStyles.caption),
        ],
      ),
    );
  }

  Widget _bucketRow(_Bucket b) {
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
          Text('€${b.total.toStringAsFixed(2)}', style: AppTextStyles.price),
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
            final byUser = <String, List<OrderModel>>{};
            for (final o in orders) {
              byUser.putIfAbsent(o.userId, () => []).add(o);
            }
            // Sort users by most recent order first.
            DateTime lastOf(UserModel u) {
              final list = byUser[u.id];
              if (list == null || list.isEmpty) return DateTime(1970);
              return list
                  .map((o) => o.createdAt ?? o.shiftDate)
                  .reduce((a, b) => a.isAfter(b) ? a : b);
            }

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
    final spent = orders
        .where((o) => o.status != AppConstants.statusCancelled)
        .fold(0.0, (s, o) => s + o.totalPrice);
    DateTime? last;
    for (final o in orders) {
      final d = o.createdAt ?? o.shiftDate;
      if (last == null || d.isAfter(last)) last = d;
    }
    final sub = orders.isEmpty
        ? 'Нет заказов'
        : '${orders.length} заказ(ов) • €${spent.toStringAsFixed(2)} • '
            'последний ${DateFormat('dd.MM.yyyy').format(last!)}';

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
