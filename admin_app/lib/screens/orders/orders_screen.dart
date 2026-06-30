import 'dart:async';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../models/order_model.dart';
import '../../providers/group_provider.dart';
import '../../services/navigation_service.dart';
import '../../services/order_service.dart';
import '../../services/user_service.dart';
import '../../utils/app_colors.dart';
import '../../utils/app_text_styles.dart';
import '../../utils/constants.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/gold_badge.dart';
import '../../widgets/verified_badge.dart';
import 'order_detail_screen.dart';

class OrdersScreen extends StatefulWidget {
  const OrdersScreen({super.key});

  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> {
  String _status = '';
  DateTime? _date;
  // userIds of verified customers, for the inline check next to names.
  Set<String> _verified = {};
  StreamSubscription? _usersSub;

  @override
  void initState() {
    super.initState();
    _usersSub = UserService.instance.usersStream().listen((users) {
      if (!mounted) return;
      setState(() => _verified =
          users.where((u) => u.isVerified).map((u) => u.id).toSet());
    });
  }

  @override
  void dispose() {
    _usersSub?.cancel();
    super.dispose();
  }

  static const _filters = [
    {'label': 'Все', 'status': ''},
    {'label': 'Новые', 'status': 'pending'},
    {'label': 'Подтв.', 'status': 'confirmed'},
    {'label': 'В пути', 'status': 'on_the_way'},
    {'label': 'Доставл.', 'status': 'delivered'},
  ];

  bool _sameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  @override
  Widget build(BuildContext context) {
    final group = context.watch<GroupProvider>().group;

    return Column(
      children: [
        SizedBox(
          height: 48,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            children: [
              ..._filters.map((f) {
                final sel = _status == f['status'];
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: ChoiceChip(
                    label: Text(f['label']!),
                    selected: sel,
                    selectedColor: AppColors.primary.withOpacity(0.2),
                    onSelected: (_) =>
                        setState(() => _status = f['status']!),
                  ),
                );
              }),
              const SizedBox(width: 4),
              ActionChip(
                avatar: const Icon(Icons.calendar_today, size: 16),
                label: Text(_date == null
                    ? 'Дата'
                    : DateFormat('d MMM').format(_date!)),
                onPressed: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: _date ?? DateTime.now(),
                    firstDate: DateTime(2023),
                    lastDate: DateTime.now().add(const Duration(days: 365)),
                  );
                  setState(() => _date = picked);
                },
              ),
              if (_date != null)
                IconButton(
                  icon: const Icon(Icons.clear, size: 18),
                  onPressed: () => setState(() => _date = null),
                ),
            ],
          ),
        ),
        Expanded(
          child: StreamBuilder<List<OrderModel>>(
            stream: OrderService.instance.ordersStream(group),
            builder: (context, snap) {
              if (snap.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              var orders = snap.data ?? [];
              if (_status.isNotEmpty) {
                orders =
                    orders.where((o) => o.status == _status).toList();
              }
              if (_date != null) {
                orders = orders
                    .where((o) => _sameDay(o.shiftDate, _date!))
                    .toList();
              }
              if (orders.isEmpty) {
                return const EmptyState(
                    icon: Icons.receipt_long, title: 'Нет заказов');
              }
              return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: orders.length,
                itemBuilder: (context, i) => _orderCard(orders[i]),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _orderCard(OrderModel o) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
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
              GestureDetector(
                onTap: () => NavigationService.instance
                    .copyToClipboard(o.id),
                child: Text('#${o.shortId}', style: AppTextStyles.bodyBold),
              ),
              const Spacer(),
              GoldBadge(
                  text: AppConstants.statusLabel(o.status),
                  color: AppColors.statusColor(o.status)),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(Icons.person_outline,
                  size: 16, color: AppColors.textSecondary),
              const SizedBox(width: 6),
              Flexible(child: Text(o.userName, style: AppTextStyles.body)),
              VerifiedBadge(verified: _verified.contains(o.userId)),
              const Spacer(),
              GestureDetector(
                onTap: () =>
                    NavigationService.instance.callPhone(o.userPhone),
                child: Row(
                  children: [
                    const Icon(Icons.phone, size: 16, color: AppColors.success),
                    const SizedBox(width: 4),
                    Text(o.userPhone, style: AppTextStyles.caption),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          GestureDetector(
            onTap: () =>
                NavigationService.instance.copyToClipboard(o.userAddress),
            child: Row(
              children: [
                const Icon(Icons.location_on_outlined,
                    size: 16, color: AppColors.textSecondary),
                const SizedBox(width: 6),
                Expanded(
                    child: Text(o.userAddress,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyles.caption)),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Text(
                  '${o.awaitingSchedule ? 'Дата не назначена' : o.shiftLabel} • ${o.itemCount} шт.',
                  style: AppTextStyles.caption.copyWith(
                      color: o.awaitingSchedule
                          ? AppColors.warning
                          : AppColors.textSecondary)),
              const Spacer(),
              Text('€${o.totalPrice.toStringAsFixed(2)}',
                  style: AppTextStyles.price),
              const SizedBox(width: 8),
              TextButton(
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => OrderDetailScreen(orderId: o.id)),
                ),
                child: const Text('Детали'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
