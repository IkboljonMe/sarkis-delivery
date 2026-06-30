import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../l10n/app_localizations.dart';
import '../../models/product_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/cart_provider.dart';
import '../../utils/app_colors.dart';
import '../../utils/app_text_styles.dart';
import '../../widgets/golden_button.dart';
import '../cart/cart_screen.dart';

/// Product detail with a swipeable image gallery (2-3 photos).
class ProductDetailScreen extends StatefulWidget {
  final ProductModel product;
  const ProductDetailScreen({super.key, required this.product});

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  final _pageController = PageController();
  int _page = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final lang = context.watch<AuthProvider>().user?.language ?? 'en';
    final cart = context.watch<CartProvider>();
    final p = widget.product;
    final qty = cart.qtyOf(p.id);
    final gallery = p.gallery;

    return Scaffold(
      appBar: AppBar(title: Text(p.nameFor(lang))),
      body: ListView(
        children: [
          SizedBox(
            height: 280,
            child: gallery.isEmpty
                ? Container(
                    color: AppColors.surfaceElevated,
                    child: const Icon(Icons.bakery_dining,
                        size: 64, color: AppColors.primary),
                  )
                : Stack(
                    children: [
                      PageView.builder(
                        controller: _pageController,
                        onPageChanged: (i) => setState(() => _page = i),
                        itemCount: gallery.length,
                        itemBuilder: (_, i) => CachedNetworkImage(
                          imageUrl: gallery[i],
                          fit: BoxFit.cover,
                          width: double.infinity,
                          placeholder: (_, __) => Container(
                              color: AppColors.surfaceElevated),
                          errorWidget: (_, __, ___) => Container(
                            color: AppColors.surfaceElevated,
                            child: const Icon(Icons.broken_image,
                                color: AppColors.textMuted),
                          ),
                        ),
                      ),
                      if (gallery.length > 1)
                        Positioned(
                          bottom: 12,
                          left: 0,
                          right: 0,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: List.generate(
                              gallery.length,
                              (i) => AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                margin:
                                    const EdgeInsets.symmetric(horizontal: 3),
                                width: i == _page ? 20 : 8,
                                height: 8,
                                decoration: BoxDecoration(
                                  color: i == _page
                                      ? AppColors.primary
                                      : Colors.white54,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                              ),
                            ),
                          ),
                        ),
                      // Localized caption for the current photo, if set.
                      if (_page < p.photos.length &&
                          p.photos[_page].titleFor(lang).isNotEmpty)
                        Positioned(
                          left: 12,
                          right: 12,
                          bottom: 28,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: Colors.black54,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              p.photos[_page].titleFor(lang),
                              textAlign: TextAlign.center,
                              style: AppTextStyles.caption
                                  .copyWith(color: Colors.white),
                            ),
                          ),
                        ),
                    ],
                  ),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(p.nameFor(lang), style: AppTextStyles.headingL),
                const SizedBox(height: 8),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text('€${p.discountedPrice.toStringAsFixed(2)}',
                        style: AppTextStyles.headingM
                            .copyWith(color: AppColors.primary)),
                    if (p.hasDiscount) ...[
                      const SizedBox(width: 8),
                      Padding(
                        padding: const EdgeInsets.only(bottom: 2),
                        child: Text('€${p.price.toStringAsFixed(2)}',
                            style: AppTextStyles.caption.copyWith(
                                decoration: TextDecoration.lineThrough,
                                color: AppColors.textMuted)),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.error.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text('-${p.discountPercentLabel}%',
                            style: const TextStyle(
                                color: AppColors.error,
                                fontSize: 12,
                                fontWeight: FontWeight.bold)),
                      ),
                    ],
                    Text(' / ${p.unit}', style: AppTextStyles.caption),
                  ],
                ),
                if (p.descriptionFor(lang).isNotEmpty) ...[
                  const SizedBox(height: 16),
                  Text(p.descriptionFor(lang),
                      style: AppTextStyles.body
                          .copyWith(color: AppColors.textSecondary)),
                ],
                const SizedBox(height: 24),
                Row(
                  children: [
                    _btn(Icons.remove,
                        qty > 0 ? () => cart.decrement(p) : null, false),
                    SizedBox(
                      width: 50,
                      child: Text('$qty',
                          textAlign: TextAlign.center,
                          style: AppTextStyles.headingM),
                    ),
                    _btn(Icons.add, () => cart.increment(p), true),
                    const Spacer(),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: cart.totalItems > 0
          ? Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
              child: GoldenButton(
                label: '${cart.totalItems} • ${t.viewCart}',
                icon: Icons.shopping_cart_outlined,
                onPressed: () => Navigator.push(context,
                    MaterialPageRoute(builder: (_) => const CartScreen())),
              ),
            )
          : null,
    );
  }

  Widget _btn(IconData icon, VoidCallback? onTap, bool gold) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(24),
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: onTap == null
              ? AppColors.surfaceElevated
              : (gold ? AppColors.primary : AppColors.surfaceElevated),
          border: Border.all(color: AppColors.border),
        ),
        child: Icon(icon,
            color: onTap == null
                ? AppColors.textMuted
                : (gold ? Colors.white : AppColors.textSecondary)),
      ),
    );
  }
}
