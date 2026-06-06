import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/category_model.dart';
import '../models/product_model.dart';

class ProductService {
  ProductService._();
  static final ProductService instance = ProductService._();

  final FirebaseFirestore _db = FirebaseFirestore.instance;
  CollectionReference<Map<String, dynamic>> get _categories =>
      _db.collection('categories');
  CollectionReference<Map<String, dynamic>> get _products =>
      _db.collection('products');

  // ---- Categories ----
  Stream<List<CategoryModel>> activeCategoriesStream() {
    return _categories
        .where('isActive', isEqualTo: true)
        .snapshots()
        .map((s) {
      final list = s.docs
          .map((d) => CategoryModel.fromJson({...d.data(), 'id': d.id}))
          .toList();
      list.sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
      return list;
    });
  }

  Stream<List<CategoryModel>> allCategoriesStream() {
    return _categories.snapshots().map((s) {
      final list = s.docs
          .map((d) => CategoryModel.fromJson({...d.data(), 'id': d.id}))
          .toList();
      list.sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
      return list;
    });
  }

  Future<void> saveCategory(CategoryModel c) async {
    try {
      if (c.id.isEmpty) {
        final ref = _categories.doc();
        await ref.set(c.copyWith(id: ref.id).toJson());
      } else {
        await _categories.doc(c.id).set(c.toJson());
      }
    } catch (e) {
      throw Exception('Failed to save category: $e');
    }
  }

  Future<void> setCategoryActive(String id, bool active) =>
      _categories.doc(id).update({'isActive': active});

  Future<void> deleteCategory(String id) => _categories.doc(id).delete();

  // ---- Products ----
  Stream<List<ProductModel>> activeProductsStream() {
    return _products.where('isActive', isEqualTo: true).snapshots().map((s) {
      final list = s.docs
          .map((d) => ProductModel.fromJson({...d.data(), 'id': d.id}))
          .toList();
      list.sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
      return list;
    });
  }

  Stream<List<ProductModel>> productsByCategoryStream(String categoryId) {
    return _products
        .where('isActive', isEqualTo: true)
        .where('categoryId', isEqualTo: categoryId)
        .snapshots()
        .map((s) {
      final list = s.docs
          .map((d) => ProductModel.fromJson({...d.data(), 'id': d.id}))
          .toList();
      list.sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
      return list;
    });
  }

  Stream<List<ProductModel>> allProductsStream() {
    return _products.snapshots().map((s) {
      final list = s.docs
          .map((d) => ProductModel.fromJson({...d.data(), 'id': d.id}))
          .toList();
      list.sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
      return list;
    });
  }

  Future<void> saveProduct(ProductModel p) async {
    try {
      if (p.id.isEmpty) {
        final ref = _products.doc();
        await ref.set(p.copyWith(id: ref.id).toJson());
      } else {
        await _products.doc(p.id).set(p.toJson());
      }
    } catch (e) {
      throw Exception('Failed to save product: $e');
    }
  }

  Future<void> setProductActive(String id, bool active) =>
      _products.doc(id).update({'isActive': active});

  Future<void> deleteProduct(String id) => _products.doc(id).delete();
}
