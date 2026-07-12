import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../l10n/app_localizations.dart';
import '../../models/category_model.dart';
import '../../models/order_model.dart';
import '../../models/shift_model.dart';
import '../../models/user_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/cart_provider.dart';
import '../../services/order_service.dart';
import '../../services/product_service.dart';
import '../../services/shift_service.dart';
import '../../utils/app_colors.dart';
import '../../utils/app_text_styles.dart';
import '../../widgets/app_lottie.dart';
import '../../widgets/brand_logo.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/glass_card.dart';
import '../../widgets/gold_badge.dart';
import '../../widgets/skeletons.dart';
import '../cart/cart_screen.dart';
import '../orders/order_detail_screen.dart';
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
                    const BrandLogo.wordmark(size: 34),
                    const Spacer(),
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
            // Verification notice — shown until an admin verifies the account.
            SliverToBoxAdapter(
              child: (user != null && !user.isVerified)
                  ? _verifyBanner(t, user)
                  : const SizedBox.shrink(),
            ),
            // Unfinished basket — lets the customer resume an order they
            // started but never placed (quantities survive app restarts).
            SliverToBoxAdapter(
              child: Consumer<CartProvider>(
                builder: (context, cart, _) {
                  if (cart.totalItems == 0) return const SizedBox.shrink();
                  return _basketBanner(context, t, cart.totalItems);
                },
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
                          // Hide delivery dates that have already passed.
                          final now = DateTime.now();
                          final today = DateTime(now.year, now.month, now.day);
                          final shifts = (snap.data ?? [])
                              .where((s) => !s.date.isBefore(today))
                              .toList();
                          if (snap.connectionState ==
                              ConnectionState.waiting) {
                            return const DeliveryCardsSkeleton();
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
                    if (snap.connectionState == ConnectionState.waiting) {
                      return const CategoryCirclesSkeleton();
                    }
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
                                ClipOval(
                                  child: SizedBox(
                                    width: 72,
                                    height: 72,
                                    child: c.imageUrl.isNotEmpty
                                        ? CachedNetworkImage(
                                            imageUrl: c.imageUrl,
                                            fit: BoxFit.cover,
                                            errorWidget: (_, __, ___) =>
                                                _categoryFallback(),
                                          )
                                        : _categoryFallback(),
                                  ),
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
                  if (snap.connectionState == ConnectionState.waiting) {
                    return const SliverToBoxAdapter(
                      child: SizedBox(
                          height: 240, child: OrderListSkeleton(count: 2)),
                    );
                  }
                  final orders = (snap.data ?? []).take(3).toList();
                  if (orders.isEmpty) {
                    return SliverToBoxAdapter(
                      child: EmptyState(
                          animation: AppAnim.thumbsUp,
                          icon: Icons.receipt_long,
                          title: t.noOrders),
                    );
                  }
                  return SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, i) => _recentOrder(context, orders[i], t, i),
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

  /// Shown on Home until an admin verifies the account. Explains the process
  /// and echoes the delivery address we'll confirm.
  Widget _verifyBanner(AppLocalizations t, UserModel user) {
    final address = [user.address, user.city]
        .where((s) => s.trim().isNotEmpty)
        .join(', ');
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.error.withOpacity(0.08),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.error.withOpacity(0.4)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.cancel, color: AppColors.error, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(t.t('verifyTitle'),
                      style: AppTextStyles.headingM.copyWith(fontSize: 16)),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(t.t('verifyBody'), style: AppTextStyles.caption),
            if (address.isNotEmpty) ...[
              const SizedBox(height: 12),
              Text(t.t('verifyAddressLabel'), style: AppTextStyles.label),
              const SizedBox(height: 2),
              Row(
                children: [
                  const Icon(Icons.location_on_outlined,
                      size: 16, color: AppColors.primary),
                  const SizedBox(width: 6),
                  Expanded(
                      child:
                          Text(address, style: AppTextStyles.body)),
                ],
              ),
            ],
          ],
        ),
      ).animate().fadeIn(duration: 400.ms),
    );
  }

  Widget _basketBanner(BuildContext context, AppLocalizations t, int items) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 8),
      child: GestureDetector(
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const CartScreen()),
        ),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.10),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.primary.withOpacity(0.4)),
          ),
          child: Row(
            children: [
              const Icon(Icons.shopping_basket_outlined,
                  color: AppColors.primary),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(t.t('unfinishedBasket'), style: AppTextStyles.bodyBold),
                    const SizedBox(height: 2),
                    Text(
                      '$items ${t.t('itemsWaiting')}',
                      style: AppTextStyles.caption,
                    ),
                  ],
                ),
              ),
              Text('${t.t('resume')} →',
                  style: const TextStyle(
                      color: AppColors.primary,
                      fontSize: 12,
                      fontWeight: FontWeight.bold)),
            ],
          ),
        ),
      ),
    ).animate().fadeIn().slideY(begin: -0.2);
  }

  Widget _categoryFallback() => Container(
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
          gradient: AppColors.goldGradient,
        ),
        child: const Icon(Icons.category, color: Colors.white),
      );

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

  Widget _recentOrder(
      BuildContext context, OrderModel o, AppLocalizations t, int i) {
    final active = o.status != 'delivered' && o.status != 'cancelled';
    final deliverDate = DateFormat('d MMM').format(o.shiftDate);
    final summary = o.itemsSummary.isNotEmpty
        ? o.itemsSummary
        : '${o.itemCount} • ${t.products}';
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
            builder: (_) => OrderDetailScreen(orderId: o.id)),
      ),
      child: Container(
        margin: const EdgeInsets.fromLTRB(20, 0, 20, 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(t.t('orderDetails'),
                          style: AppTextStyles.bodyBold),
                    ),
                    Text('€${o.totalPrice.toStringAsFixed(2)}',
                        style: AppTextStyles.bodyBold
                            .copyWith(color: AppColors.primary)),
                  ],
                ),
                const SizedBox(height: 4),
                Text(summary,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.caption),
                const SizedBox(height: 6),
                Row(
                  children: [
                    const Icon(Icons.local_shipping_outlined,
                        size: 14, color: AppColors.primary),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        active
                            ? '${t.t('awaitingDelivery')} • $deliverDate'
                            : deliverDate,
                        style: AppTextStyles.caption
                            .copyWith(color: AppColors.textSecondary),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
            const SizedBox(width: 10),
            OrderStatusBadge(status: o.status),
          ],
        ),
      ),
    ).animate().fadeIn(delay: (60 * i).ms).slideY(begin: 0.15);
  }
}
