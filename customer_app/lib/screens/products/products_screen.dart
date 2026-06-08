import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';

import '../../l10n/app_localizations.dart';
import '../../models/category_model.dart';
import '../../models/product_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/cart_provider.dart';
import '../../utils/app_colors.dart';
import '../../utils/app_text_styles.dart';
import '../../services/product_service.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/golden_button.dart';
import '../../widgets/loading_shimmer.dart';
import '../cart/cart_screen.dart';
import 'product_detail_screen.dart';

class ProductsScreen extends StatelessWidget {
  final CategoryModel category;
  const ProductsScreen({super.key, required this.category});

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final lang = context.watch<AuthProvider>().user?.language ?? 'en';
    final cart = context.watch<CartProvider>();

    return Scaffold(
      appBar: AppBar(title: Text(category.nameFor(lang))),
      body: StreamBuilder<List<ProductModel>>(
        stream:
            ProductService.instance.productsByCategoryStream(category.id),
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const LoadingShimmer();
          }
          final products = snap.data ?? [];
          if (products.isEmpty) {
            return EmptyState(icon: Icons.inventory_2, title: t.products);
          }
          return ListView.builder(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 120),
            itemCount: products.length,
            itemBuilder: (context, i) =>
                _ProductCard(product: products[i], lang: lang)
                    .animate()
                    .fadeIn(delay: (80 * i).ms)
                    .slideY(begin: 0.1),
          );
        },
      ),
      bottomSheet: cart.totalItems > 0
          ? _CartBar(
              items: cart.totalItems,
              onView: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const CartScreen()),
              ),
            )
          : null,
    );
  }
}

class _ProductCard extends StatelessWidget {
  final ProductModel product;
  final String lang;
  const _ProductCard({required this.product, required this.lang});

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartProvider>();
    final qty = cart.qtyOf(product.id);

    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
            builder: (_) => ProductDetailScreen(product: product)),
      ),
      child: Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: product.imageUrl.isNotEmpty
                ? CachedNetworkImage(
                    imageUrl: product.imageUrl,
                    width: 80,
                    height: 80,
                    fit: BoxFit.cover,
                    errorWidget: (_, __, ___) => _ph(),
                  )
                : _ph(),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(product.nameFor(lang), style: AppTextStyles.bodyBold),
                if (product.descriptionFor(lang).isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(product.descriptionFor(lang),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.caption),
                ],
                const SizedBox(height: 8),
                Row(
                  children: [
                    Text('€${product.price.toStringAsFixed(2)}',
                        style: AppTextStyles.price),
                    Text(' / ${product.unit}',
                        style: AppTextStyles.caption),
                    const Spacer(),
                    _qtyPicker(context, cart, qty),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    ),
    );
  }

  Widget _qtyPicker(BuildContext context, CartProvider cart, int qty) {
    return Row(
      children: [
        _btn(Icons.remove, qty > 0 ? () => cart.decrement(product) : null,
            gold: false),
        SizedBox(
          width: 28,
          child: Text('$qty',
              textAlign: TextAlign.center, style: AppTextStyles.bodyBold),
        ),
        _btn(Icons.add, () => cart.increment(product), gold: true),
      ],
    );
  }

  Widget _btn(IconData icon, VoidCallback? onTap, {required bool gold}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.all(5),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: onTap == null
              ? AppColors.surfaceElevated
              : (gold ? AppColors.primary : AppColors.surfaceElevated),
          border: Border.all(color: AppColors.border),
        ),
        child: Icon(icon,
            size: 18,
            color: onTap == null
                ? AppColors.textMuted
                : (gold ? Colors.white : AppColors.textSecondary)),
      ),
    );
  }

  Widget _ph() => Container(
        width: 80,
        height: 80,
        color: AppColors.surfaceElevated,
        child: const Icon(Icons.bakery_dining, color: AppColors.primary),
      );
}

class _CartBar extends StatelessWidget {
  final int items;
  final VoidCallback onView;
  const _CartBar({required this.items, required this.onView});

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    return Container(
      color: AppColors.background,
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
      child: GoldenButton(
        label: '$items • ${t.viewCart}',
        icon: Icons.shopping_cart_outlined,
        onPressed: onView,
      ),
    );
  }
}
