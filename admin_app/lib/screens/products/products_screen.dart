import 'package:flutter/material.dart';

import '../../models/category_model.dart';
import '../../models/product_model.dart';
import '../../services/product_service.dart';
import '../../utils/app_colors.dart';
import '../../utils/app_text_styles.dart';
import '../../widgets/empty_state.dart';
import 'add_edit_category_sheet.dart';
import 'add_edit_product_sheet.dart';

class ProductsScreen extends StatelessWidget {
  const ProductsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Column(
        children: [
          const Material(
            color: Colors.transparent,
            child: TabBar(
              indicatorColor: AppColors.primary,
              labelColor: AppColors.primary,
              unselectedLabelColor: AppColors.textSecondary,
              tabs: [Tab(text: 'Категории'), Tab(text: 'Товары')],
            ),
          ),
          const Expanded(
            child: TabBarView(
              children: [_CategoriesTab(), _ProductsTab()],
            ),
          ),
        ],
      ),
    );
  }
}

class _CategoriesTab extends StatelessWidget {
  const _CategoriesTab();

  Future<void> _confirmDelete(BuildContext context, String id) async {
    final ok = await _confirm(context, 'Удалить категорию?');
    if (ok) await ProductService.instance.deleteCategory(id);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        heroTag: 'addCat',
        onPressed: () => showAddEditCategorySheet(context, null),
        child: const Icon(Icons.add),
      ),
      body: StreamBuilder<List<CategoryModel>>(
        stream: ProductService.instance.allCategoriesStream(),
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          final cats = snap.data ?? [];
          if (cats.isEmpty) {
            return const EmptyState(
                icon: Icons.category, title: 'Нет категорий');
          }
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: cats.length,
            itemBuilder: (context, i) {
              final c = cats[i];
              return Container(
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
                        child: Text(c.nameFor('ru'),
                            style: AppTextStyles.bodyBold)),
                    Text('#${c.sortOrder}', style: AppTextStyles.caption),
                    Switch(
                      value: c.isActive,
                      activeColor: AppColors.primary,
                      onChanged: (v) => ProductService.instance
                          .setCategoryActive(c.id, v),
                    ),
                    IconButton(
                      icon: const Icon(Icons.edit, color: AppColors.primary),
                      onPressed: () =>
                          showAddEditCategorySheet(context, c),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete_outline,
                          color: AppColors.error),
                      onPressed: () => _confirmDelete(context, c.id),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class _ProductsTab extends StatelessWidget {
  const _ProductsTab();

  Future<void> _confirmDelete(BuildContext context, String id) async {
    final ok = await _confirm(context, 'Удалить товар?');
    if (ok) await ProductService.instance.deleteProduct(id);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        heroTag: 'addProd',
        onPressed: () => showAddEditProductSheet(context, null),
        child: const Icon(Icons.add),
      ),
      body: StreamBuilder<List<ProductModel>>(
        stream: ProductService.instance.allProductsStream(),
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          final products = snap.data ?? [];
          if (products.isEmpty) {
            return const EmptyState(
                icon: Icons.storefront, title: 'Нет товаров');
          }
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: products.length,
            itemBuilder: (context, i) {
              final p = products[i];
              return Container(
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
                          Text(p.nameFor('ru'),
                              style: AppTextStyles.bodyBold),
                          Text('€${p.price.toStringAsFixed(2)} / ${p.unit}',
                              style: AppTextStyles.caption),
                        ],
                      ),
                    ),
                    Switch(
                      value: p.isActive,
                      activeColor: AppColors.primary,
                      onChanged: (v) => ProductService.instance
                          .setProductActive(p.id, v),
                    ),
                    IconButton(
                      icon: const Icon(Icons.edit, color: AppColors.primary),
                      onPressed: () =>
                          showAddEditProductSheet(context, p),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete_outline,
                          color: AppColors.error),
                      onPressed: () => _confirmDelete(context, p.id),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}

Future<bool> _confirm(BuildContext context, String title) async {
  final ok = await showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: Text(title),
      content: const Text('Это действие нельзя отменить.'),
      actions: [
        TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Отмена')),
        TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Удалить',
                style: TextStyle(color: AppColors.error))),
      ],
    ),
  );
  return ok ?? false;
}
