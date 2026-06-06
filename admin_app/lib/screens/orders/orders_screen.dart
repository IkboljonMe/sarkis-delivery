import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../models/order_model.dart';
import '../../providers/admin_order_provider.dart';
import '../../utils/constants.dart';
import 'order_card_widget.dart';
import 'order_detail_screen.dart';

class OrdersScreen extends StatefulWidget {
  const OrdersScreen({super.key});

  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  // Tab -> status filter (empty = all)
  static const _tabs = [
    {'label': 'Все', 'status': ''},
    {'label': 'Новые', 'status': AppConstants.statusPending},
    {'label': 'Подтв.', 'status': AppConstants.statusConfirmed},
    {'label': 'В пути', 'status': AppConstants.statusOnTheWay},
    {'label': 'Доставл.', 'status': AppConstants.statusDelivered},
  ];

  String _group = '';
  DateTime? _dateFilter;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _tabs.length, vsync: this);
    _tabController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _dateFilter ?? DateTime.now(),
      firstDate: DateTime(2023),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) setState(() => _dateFilter = picked);
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.read<AdminOrderProvider>();
    final statusFilter = _tabs[_tabController.index]['status']!;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Все заказы'),
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          indicatorColor: Colors.white,
          tabs: _tabs.map((t) => Tab(text: t['label'])).toList(),
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            child: Row(
              children: [
                _groupChip('Все группы', ''),
                _groupChip('Берлин', AppConstants.groupBerlin),
                _groupChip('Гамбург', AppConstants.groupHamburg),
                const Spacer(),
                if (_dateFilter != null)
                  Chip(
                    label: Text(DateFormat('d MMM').format(_dateFilter!)),
                    onDeleted: () => setState(() => _dateFilter = null),
                  ),
                IconButton(
                  icon: const Icon(Icons.date_range),
                  onPressed: _pickDate,
                ),
              ],
            ),
          ),
          Expanded(
            child: StreamBuilder<List<OrderModel>>(
              stream: provider.ordersStream(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return const Center(child: Text('Ошибка загрузки'));
                }
                final filtered = provider.applyFilters(
                  snapshot.data ?? [],
                  status: statusFilter,
                  group: _group,
                  deliveryDate: _dateFilter,
                );
                if (filtered.isEmpty) {
                  return const Center(child: Text('Нет заказов'));
                }
                return RefreshIndicator(
                  onRefresh: () async => await Future.delayed(
                      const Duration(milliseconds: 400)),
                  child: ListView.builder(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    itemCount: filtered.length,
                    itemBuilder: (context, i) => OrderCardWidget(
                      order: filtered[i],
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) =>
                              OrderDetailScreen(orderId: filtered[i].id),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _groupChip(String label, String value) {
    final selected = _group == value;
    return Padding(
      padding: const EdgeInsets.only(right: 6),
      child: ChoiceChip(
        label: Text(label),
        selected: selected,
        onSelected: (_) => setState(() => _group = value),
      ),
    );
  }
}
