import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../l10n/app_localizations.dart';
import '../../models/category_model.dart';
import '../../models/order_model.dart';
import '../../models/shift_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/cart_provider.dart';
import '../../services/order_service.dart';
import '../../services/product_service.dart';
import '../../services/shift_service.dart';
import '../../utils/app_colors.dart';
import '../../utils/app_text_styles.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/glass_card.dart';
import '../../widgets/gold_badge.dart';
import '../orders/order_status_badge.dart';
import '../products/categories_screen.dart';
import '../products/products_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  String _greeting(AppLocalizations t) {
    final h = DateTime.now().hour;
    if (h < 12) return t.t('goodMorning');
    if (h < 18) return t.t('goodAfternoon');
    return t.t('goodEvening');
  }

  void _openShift(BuildContext context, ShiftModel shift) {
    context.read<CartProvider>().setShift(shift);
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const CategoriesScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final user = context.watch<AuthProvider>().user;
    final lang = user?.language ?? 'en';

    return Scaffold(
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
                child: Row(
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.bakery_dining,
                            color: AppColors.primary),
                        const SizedBox(width: 8),
                        Text('Sarkis Bread', style: AppTextStyles.headingM),
                      ],
                    ),
                    const Spacer(),
                    const Icon(Icons.notifications_none,
                        color: AppColors.textSecondary),
                  ],
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 4, 20, 16),
                child: Text(
                  '${_greeting(t)}, ${user?.name ?? ''} 👋',
                  style: AppTextStyles.body
                      .copyWith(color: AppColors.textSecondary),
                ),
              ),
            ),
            // Deliveries
            SliverToBoxAdapter(
                child: _sectionTitle(t.deliveries)),
            SliverToBoxAdapter(
              child: SizedBox(
                height: 150,
                child: user == null
                    ? const SizedBox()
                    : StreamBuilder<List<ShiftModel>>(
                        stream: ShiftService.instance
                            .openShiftsStream(user.group),
                        builder: (context, snap) {
                          final shifts = snap.data ?? [];
                          if (snap.connectionState ==
                              ConnectionState.waiting) {
                            return const Center(
                                child: CircularProgressIndicator());
                          }
                          if (shifts.isEmpty) {
                            return Center(
                              child: Text(t.noDeliveries,
                                  style: AppTextStyles.caption),
                            );
                          }
                          return ListView.builder(
                            scrollDirection: Axis.horizontal,
                            padding:
                                const EdgeInsets.symmetric(horizontal: 16),
                            itemCount: shifts.length,
                            itemBuilder: (context, i) =>
                                _shiftCard(context, shifts[i], t, i),
                          );
                        },
                      ),
              ),
            ),
            // Categories preview
            SliverToBoxAdapter(child: _sectionTitle(t.products)),
            SliverToBoxAdapter(
              child: SizedBox(
                height: 120,
                child: StreamBuilder<List<CategoryModel>>(
                  stream: ProductService.instance.activeCategoriesStream(),
                  builder: (context, snap) {
                    final cats = snap.data ?? [];
                    if (cats.isEmpty) {
                      return Center(
                          child: Text(t.t('categories'),
                              style: AppTextStyles.caption));
                    }
                    return ListView.builder(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: cats.length,
                      itemBuilder: (context, i) {
                        final c = cats[i];
                        return GestureDetector(
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => ProductsScreen(category: c),
                            ),
                          ),
                          child: Container(
                            width: 96,
                            margin: const EdgeInsets.only(right: 12),
                            child: Column(
                              children: [
                                Container(
                                  width: 72,
                                  height: 72,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    gradient: AppColors.goldGradient,
                                  ),
                                  child: const Icon(Icons.category,
                                      color: Colors.white),
                                ),
                                const SizedBox(height: 8),
                                Text(c.nameFor(lang),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: AppTextStyles.caption),
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ),
            // Recent orders
            SliverToBoxAdapter(child: _sectionTitle(t.t('recentOrders'))),
            if (user != null)
              StreamBuilder<List<OrderModel>>(
                stream: OrderService.instance.userOrdersStream(user.id),
                builder: (context, snap) {
                  final orders = (snap.data ?? []).take(3).toList();
                  if (orders.isEmpty) {
                    return const SliverToBoxAdapter(
                      child: EmptyState(
                          icon: Icons.receipt_long, title: 'No orders yet'),
                    );
                  }
                  return SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, i) => _recentOrder(orders[i], t),
                      childCount: orders.length,
                    ),
                  );
                },
              ),
            const SliverToBoxAdapter(child: SizedBox(height: 100)),
          ],
        ),
      ),
    );
  }

  Widget _sectionTitle(String title) => Padding(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
        child: Text(title, style: AppTextStyles.headingM),
      );

  Widget _shiftCard(
      BuildContext context, ShiftModel shift, AppLocalizations t, int i) {
    final day = DateFormat('d MMMM').format(shift.date);
    final dow = DateFormat('EEEE').format(shift.date);
    return GestureDetector(
      onTap: () => _openShift(context, shift),
      child: Container(
        width: 180,
        margin: const EdgeInsets.only(right: 12),
        child: GlassCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(day, style: AppTextStyles.headingL.copyWith(fontSize: 20)),
              Text(dow, style: AppTextStyles.caption),
              const Spacer(),
              Row(
                children: [
                  GoldBadge(text: shift.group),
                  const Spacer(),
                  Text('${t.orderNow} →',
                      style: const TextStyle(
                          color: AppColors.primary,
                          fontSize: 11,
                          fontWeight: FontWeight.bold)),
                ],
              ),
            ],
          ),
        ),
      ),
    ).animate().fadeIn(delay: (80 * i).ms).slideX(begin: 0.1);
  }

  Widget _recentOrder(OrderModel o, AppLocalizations t) {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 0, 20, 10),
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
                Text('#${o.shortId}', style: AppTextStyles.bodyBold),
                const SizedBox(height: 4),
                Text('${o.shiftLabel} • €${o.totalPrice.toStringAsFixed(2)}',
                    style: AppTextStyles.caption),
              ],
            ),
          ),
          OrderStatusBadge(status: o.status),
        ],
      ),
    );
  }
}
