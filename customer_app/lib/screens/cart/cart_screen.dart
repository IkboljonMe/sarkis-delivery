import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../l10n/app_localizations.dart';
import '../../models/product_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/cart_provider.dart';
import '../../services/product_service.dart';
import '../../utils/app_colors.dart';
import '../../utils/app_text_styles.dart';
import '../../widgets/dark_card.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/glass_card.dart';
import '../../widgets/gold_badge.dart';
import '../../widgets/golden_button.dart';
import 'order_success_screen.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final cart = context.watch<CartProvider>();
    final user = context.watch<AuthProvider>().user;
    final lang = user?.language ?? 'en';

    return Scaffold(
      appBar: AppBar(
        title: Text(t.cart),
        actions: [
          if (!cart.isEmpty)
            IconButton(
              icon: const Icon(Icons.delete_outline),
              onPressed: cart.clear,
            ),
        ],
      ),
      body: StreamBuilder<List<ProductModel>>(
        stream: ProductService.instance.activeProductsStream(),
        builder: (context, snap) {
          final all = snap.data ?? [];
          final inCart =
              all.where((p) => cart.qtyOf(p.id) > 0).toList();
          if (cart.isEmpty || inCart.isEmpty) {
            return EmptyState(
                icon: Icons.shopping_cart_outlined, title: t.cartEmpty);
          }
          final total = cart.total(all);
          final shift = cart.shift;

          return Column(
            children: [
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    if (shift != null)
                      GlassCard(
                        child: Row(
                          children: [
                            const Icon(Icons.event,
                                color: AppColors.primary, size: 20),
                            const SizedBox(width: 10),
                            Text(
                                DateFormat('EEE, d MMM').format(shift.date),
                                style: AppTextStyles.bodyBold),
                            const SizedBox(width: 8),
                            GoldBadge(text: shift.group),
                          ],
                        ),
                      ),
                    const SizedBox(height: 16),
                    ...inCart.map((p) => _cartItem(context, p, cart, lang)),
                    const SizedBox(height: 16),
                    DarkCard(
                      child: Column(
                        children: [
                          _summaryRow(t.total, '', isHeader: true),
                          const SizedBox(height: 8),
                          _summaryRow(t.delivery, t.free),
                          const Divider(color: AppColors.border, height: 24),
                          Row(
                            children: [
                              Text(t.total, style: AppTextStyles.headingM),
                              const Spacer(),
                              Text('€${total.toStringAsFixed(2)}',
                                  style: AppTextStyles.headingL
                                      .copyWith(color: AppColors.primary)),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                child: GoldenButton(
                  label: t.placeOrder,
                  loading: cart.placing,
                  onPressed: () => _confirm(context, all),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _cartItem(
      BuildContext context, ProductModel p, CartProvider cart, String lang) {
    final qty = cart.qtyOf(p.id);
    return Dismissible(
      key: ValueKey(p.id),
      direction: DismissDirection.endToStart,
      onDismissed: (_) => cart.remove(p.id),
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
          color: AppColors.error.withOpacity(0.2),
          borderRadius: BorderRadius.circular(14),
        ),
        child: const Icon(Icons.delete, color: AppColors.error),
      ),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(12),
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
                  Text(p.nameFor(lang), style: AppTextStyles.bodyBold),
                  Text('€${p.price.toStringAsFixed(2)}',
                      style: AppTextStyles.caption),
                ],
              ),
            ),
            IconButton(
              icon: const Icon(Icons.remove_circle_outline,
                  color: AppColors.textSecondary),
              onPressed: () => cart.decrement(p),
            ),
            Text('$qty', style: AppTextStyles.bodyBold),
            IconButton(
              icon: const Icon(Icons.add_circle, color: AppColors.primary),
              onPressed: () => cart.increment(p),
            ),
            SizedBox(
              width: 60,
              child: Text('€${(p.price * qty).toStringAsFixed(2)}',
                  textAlign: TextAlign.right, style: AppTextStyles.price),
            ),
          ],
        ),
      ),
    );
  }

  Widget _summaryRow(String label, String value, {bool isHeader = false}) {
    return Row(
      children: [
        Text(label,
            style: isHeader ? AppTextStyles.bodyBold : AppTextStyles.caption),
        const Spacer(),
        Text(value, style: AppTextStyles.body),
      ],
    );
  }

  Future<void> _confirm(
      BuildContext context, List<ProductModel> products) async {
    final t = AppLocalizations.of(context);
    final confirmed = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surfaceElevated,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => Padding(
        padding: EdgeInsets.fromLTRB(
            20, 20, 20, MediaQuery.of(ctx).viewInsets.bottom + 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.border,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 16),
            Text(t.t('confirmOrder'), style: AppTextStyles.headingL),
            const SizedBox(height: 8),
            Text(t.areYouSure, style: AppTextStyles.caption),
            const SizedBox(height: 24),
            GoldenButton(
                label: t.yesConfirm,
                onPressed: () => Navigator.pop(ctx, true)),
            const SizedBox(height: 8),
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: Text(t.noGoBack,
                  style: const TextStyle(color: AppColors.textSecondary)),
            ),
          ],
        ),
      ),
    );

    if (confirmed != true || !context.mounted) return;

    final auth = context.read<AuthProvider>();
    final cart = context.read<CartProvider>();
    final user = auth.user;
    if (user == null) return;

    final id = await cart.placeOrder(user: user, products: products);
    if (!context.mounted) return;
    if (id != null) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => OrderSuccessScreen(orderId: id)),
      );
    }
  }
}
