import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';

import '../../l10n/app_localizations.dart';
import '../../models/category_model.dart';
import '../../providers/auth_provider.dart';
import '../../services/product_service.dart';
import '../../utils/app_colors.dart';
import '../../utils/app_text_styles.dart';
import '../../sync/sync_engine.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/skeletons.dart';
import 'products_screen.dart';

class CategoriesScreen extends StatelessWidget {
  const CategoriesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final lang = context.watch<AuthProvider>().user?.language ?? 'en';

    return Scaffold(
      appBar: AppBar(title: Text(t.categories)),
      body: StreamBuilder<List<CategoryModel>>(
        stream: ProductService.instance.activeCategoriesStream(),
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const CategoryGridSkeleton();
          }
          final cats = snap.data ?? [];
          if (cats.isEmpty) {
            return EmptyState(icon: Icons.category, title: t.categories);
          }
          return RefreshIndicator(
            onRefresh: () async {
              final auth = context.read<AuthProvider>();
              if (auth.user != null) {
                await SyncEngine.instance.fullSync(auth.user!.id);
              }
            },
            child: GridView.builder(
              padding: const EdgeInsets.all(16),
              gridDelegate:
                  const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 16,
                crossAxisSpacing: 16,
                childAspectRatio: 1,
              ),
              itemCount: cats.length,
              itemBuilder: (context, i) {
                final c = cats[i];
                return GestureDetector(
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => ProductsScreen(category: c)),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        if (c.imageUrl.isNotEmpty)
                          CachedNetworkImage(
                            imageUrl: c.imageUrl,
                            fit: BoxFit.cover,
                            errorWidget: (_, __, ___) => _fallback(),
                          )
                        else
                          _fallback(),
                        Container(
                          decoration: const BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [Colors.transparent, Color(0xCC000000)],
                            ),
                          ),
                        ),
                        Positioned(
                          left: 12,
                          right: 12,
                          bottom: 12,
                          child: Text(c.nameFor(lang),
                              style: AppTextStyles.headingM),
                        ),
                      ],
                    ),
                  ),
                )
                    .animate()
                    .fadeIn(delay: (80 * i).ms, duration: 350.ms)
                    .scale(begin: const Offset(0.95, 0.95));
              },
            ),
          );
        },
      ),
    );
  }

  Widget _fallback() => Container(
        decoration: const BoxDecoration(gradient: AppColors.goldGradient),
        child: const Icon(Icons.bakery_dining, color: Colors.white, size: 40),
      );
}
