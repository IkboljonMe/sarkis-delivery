import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

import '../../models/product_model.dart';
import '../../services/firebase_service.dart';
import 'add_edit_product_dialog.dart';

class ProductsScreen extends StatelessWidget {
  const ProductsScreen({super.key});

  Future<void> _addEdit(BuildContext context, [ProductModel? product]) async {
    final result = await showDialog<ProductModel>(
      context: context,
      builder: (_) => AddEditProductDialog(product: product),
    );
    if (result != null) {
      try {
        await FirebaseService.instance.saveProduct(result);
        Fluttertoast.showToast(msg: 'Сохранено');
      } catch (e) {
        Fluttertoast.showToast(msg: 'Ошибка: $e');
      }
    }
  }

  Future<void> _confirmDelete(BuildContext context, String id) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Удалить товар?'),
        content: const Text('Это действие нельзя отменить.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Отмена')),
          ElevatedButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Удалить')),
        ],
      ),
    );
    if (ok == true) {
      await FirebaseService.instance.deleteProduct(id);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Товары')),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _addEdit(context),
        child: const Icon(Icons.add),
      ),
      body: StreamBuilder<List<ProductModel>>(
        stream: FirebaseService.instance.productsStream(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          final products = snapshot.data ?? [];
          if (products.isEmpty) {
            return const Center(child: Text('Нет товаров. Нажмите +'));
          }
          return ListView.builder(
            padding: const EdgeInsets.all(8),
            itemCount: products.length,
            itemBuilder: (context, i) {
              final p = products[i];
              return Card(
                child: ListTile(
                  title: Text(p.nameFor('ru')),
                  subtitle: Text(
                      '€${p.price.toStringAsFixed(2)} / ${p.unit} • макс. ${p.maxQty}'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Switch(
                        value: p.isActive,
                        onChanged: (v) => FirebaseService.instance
                            .setProductActive(p.id, v),
                      ),
                      IconButton(
                        icon: const Icon(Icons.edit, color: Color(0xFFC8860D)),
                        onPressed: () => _addEdit(context, p),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete_outline,
                            color: Colors.red),
                        onPressed: () => _confirmDelete(context, p.id),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
