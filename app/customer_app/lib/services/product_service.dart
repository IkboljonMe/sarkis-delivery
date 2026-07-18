import 'dart:convert';
import 'package:drift/drift.dart';

import '../local_db/app_database.dart';
import '../models/category_model.dart';
import '../models/product_model.dart';

class ProductService {
  ProductService._();
  static final ProductService instance = ProductService._();

  final AppDatabase _db = AppDatabase.instance;

  CategoryModel _mapCategory(Category c) {
    return CategoryModel(
      id: c.id,
      name: Map<String, String>.from(jsonDecode(c.nameJson)),
      imageUrl: c.imageUrl,
      sortOrder: c.sortOrder,
      isActive: c.isActive,
    );
  }

  ProductModel _mapProduct(Product p) {
    return ProductModel(
      id: p.id,
      categoryId: p.categoryId,
      name: Map<String, String>.from(jsonDecode(p.nameJson)),
      description: Map<String, String>.from(jsonDecode(p.descriptionJson)),
      price: p.price,
      unit: p.unit,
      maxQty: p.maxQty,
      imageUrl: p.imageUrl,
      images: (jsonDecode(p.imagesJson) as List).map((e) => e.toString()).toList(),
      isActive: p.isActive,
      sortOrder: p.sortOrder,
      discountType: p.discountType,
      discountValue: p.discountValue,
    );
  }

  // ---- Categories ----
  Stream<List<CategoryModel>> activeCategoriesStream() {
    return (_db.select(_db.categories)
          ..where((t) => t.isActive.equals(true))
          ..orderBy([(t) => OrderingTerm.asc(t.sortOrder)]))
        .watch()
        .map((rows) => rows.map(_mapCategory).toList());
  }

  Stream<List<CategoryModel>> allCategoriesStream() {
    return (_db.select(_db.categories)
          ..orderBy([(t) => OrderingTerm.asc(t.sortOrder)]))
        .watch()
        .map((rows) => rows.map(_mapCategory).toList());
  }

  // ---- Products ----
  Stream<List<ProductModel>> activeProductsStream() {
    return (_db.select(_db.products)
          ..where((t) => t.isActive.equals(true))
          ..orderBy([(t) => OrderingTerm.asc(t.sortOrder)]))
        .watch()
        .map((rows) => rows.map(_mapProduct).toList());
  }

  Stream<List<ProductModel>> productsByCategoryStream(String categoryId) {
    return (_db.select(_db.products)
          ..where((t) => t.categoryId.equals(categoryId) & t.isActive.equals(true))
          ..orderBy([(t) => OrderingTerm.asc(t.sortOrder)]))
        .watch()
        .map((rows) => rows.map(_mapProduct).toList());
  }

  Stream<List<ProductModel>> allProductsStream() {
    return (_db.select(_db.products)
          ..orderBy([(t) => OrderingTerm.asc(t.sortOrder)]))
        .watch()
        .map((rows) => rows.map(_mapProduct).toList());
  }
}
