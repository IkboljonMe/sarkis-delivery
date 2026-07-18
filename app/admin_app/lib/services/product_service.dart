import 'dart:convert';
import 'dart:typed_data';
import 'package:drift/drift.dart' as drift;

import '../local_db/app_database.dart';
import '../models/category_model.dart';
import '../models/product_model.dart';
import '../sync/mutation_queue.dart';
import 'api_client.dart';

class ProductService {
  ProductService._();
  static final ProductService instance = ProductService._();

  final ApiClient _api = ApiClient.instance;

  // ---- Categories ----
  Stream<List<CategoryModel>> activeCategoriesStream() {
    final db = AppDatabase.instance;
    return (db.select(db.categories)
          ..where((t) => t.isActive.equals(true))
          ..orderBy([(t) => drift.OrderingTerm.asc(t.sortOrder)]))
        .watch()
        .map(_mapCategories);
  }

  Stream<List<CategoryModel>> allCategoriesStream() {
    final db = AppDatabase.instance;
    return (db.select(db.categories)
          ..orderBy([(t) => drift.OrderingTerm.asc(t.sortOrder)]))
        .watch()
        .map(_mapCategories);
  }

  List<CategoryModel> _mapCategories(List<Category> rows) {
    return rows.map((r) => CategoryModel(
          id: r.id,
          name: r.nameJson.isNotEmpty ? Map<String, String>.from(jsonDecode(r.nameJson) as Map) : {},
          imageUrl: r.imageUrl,
          sortOrder: r.sortOrder,
          isActive: r.isActive,
        )).toList();
  }

  Future<void> saveCategory(CategoryModel c) async {
    final body = {
      'name': c.name,
      'imageUrl': c.imageUrl,
      'sortOrder': c.sortOrder,
      'isActive': c.isActive,
    };
    final id = c.id.isEmpty ? 'local_${DateTime.now().millisecondsSinceEpoch}' : c.id;
    final method = c.id.isEmpty ? 'POST' : 'PATCH';
    final path = c.id.isEmpty ? '/v1/admin/categories' : '/v1/admin/categories/${c.id}';
    
    final db = AppDatabase.instance;
    await db.into(db.categories).insertOnConflictUpdate(CategoriesCompanion.insert(
      id: id,
      nameJson: drift.Value(jsonEncode(c.name)),
      imageUrl: drift.Value(c.imageUrl),
      sortOrder: drift.Value(c.sortOrder),
      isActive: drift.Value(c.isActive),
      updatedAt: DateTime.now(),
    ));

    await MutationQueue.instance.run(
      entityType: 'category',
      method: method,
      path: path,
      body: body,
      localRefId: c.id.isEmpty ? id : '',
    );
  }

  Future<void> setCategoryActive(String id, bool active) async {
    final db = AppDatabase.instance;
    await (db.update(db.categories)..where((t) => t.id.equals(id))).write(CategoriesCompanion(isActive: drift.Value(active)));

    await MutationQueue.instance.run(
      entityType: 'category',
      method: 'PATCH',
      path: '/v1/admin/categories/$id',
      body: {'isActive': active},
    );
  }

  Future<void> deleteCategory(String id) async {
    final db = AppDatabase.instance;
    await (db.delete(db.categories)..where((t) => t.id.equals(id))).go();
    
    await MutationQueue.instance.run(
      entityType: 'category',
      method: 'DELETE',
      path: '/v1/admin/categories/$id',
    );
  }

  // ---- Products ----
  Stream<List<ProductModel>> activeProductsStream() {
    final db = AppDatabase.instance;
    return (db.select(db.products)
          ..where((t) => t.isActive.equals(true))
          ..orderBy([(t) => drift.OrderingTerm.asc(t.sortOrder)]))
        .watch()
        .map(_mapProducts);
  }

  Stream<List<ProductModel>> productsByCategoryStream(String categoryId) {
    final db = AppDatabase.instance;
    return (db.select(db.products)
          ..where((t) => t.categoryId.equals(categoryId))
          ..orderBy([(t) => drift.OrderingTerm.asc(t.sortOrder)]))
        .watch()
        .map(_mapProducts);
  }

  Stream<List<ProductModel>> allProductsStream() {
    final db = AppDatabase.instance;
    return (db.select(db.products)
          ..orderBy([(t) => drift.OrderingTerm.asc(t.sortOrder)]))
        .watch()
        .map(_mapProducts);
  }

  List<ProductModel> _mapProducts(List<Product> rows) {
    return rows.map((r) => ProductModel(
          id: r.id,
          categoryId: r.categoryId,
          name: r.nameJson.isNotEmpty ? Map<String, String>.from(jsonDecode(r.nameJson) as Map) : {},
          description: r.descriptionJson.isNotEmpty ? Map<String, String>.from(jsonDecode(r.descriptionJson) as Map) : {},
          price: r.price,
          unit: r.unit,
          maxQty: r.maxQty,
          imageUrl: r.imageUrl,
          images: r.imagesJson.isNotEmpty ? (jsonDecode(r.imagesJson) as List).cast<String>() : [],
          photos: r.photosJson.isNotEmpty ? (jsonDecode(r.photosJson) as List).map((e) => ProductPhoto.fromJson(Map<String, dynamic>.from(e as Map))).toList() : [],
          isActive: r.isActive,
          sortOrder: r.sortOrder,
          discountType: r.discountType,
          discountValue: r.discountValue,
        )).toList();
  }

  Future<void> saveProduct(ProductModel p) async {
    final body = Map<String, dynamic>.from(p.toJson())..remove('id');
    final id = p.id.isEmpty ? 'local_${DateTime.now().millisecondsSinceEpoch}' : p.id;
    final method = p.id.isEmpty ? 'POST' : 'PATCH';
    final path = p.id.isEmpty ? '/v1/admin/products' : '/v1/admin/products/${p.id}';
    
    final db = AppDatabase.instance;
    await db.into(db.products).insertOnConflictUpdate(ProductsCompanion.insert(
      id: id,
      categoryId: p.categoryId,
      nameJson: drift.Value(jsonEncode(p.name)),
      descriptionJson: drift.Value(jsonEncode(p.description)),
      price: p.price,
      unit: drift.Value(p.unit),
      maxQty: drift.Value(p.maxQty),
      imageUrl: drift.Value(p.imageUrl),
      imagesJson: drift.Value(jsonEncode(p.images)),
      photosJson: drift.Value(jsonEncode(p.photos)),
      isActive: drift.Value(p.isActive),
      sortOrder: drift.Value(p.sortOrder),
      discountType: drift.Value(p.discountType),
      discountValue: drift.Value(p.discountValue),
      updatedAt: DateTime.now(),
    ));

    await MutationQueue.instance.run(
      entityType: 'product',
      method: method,
      path: path,
      body: body,
      localRefId: p.id.isEmpty ? id : '',
    );
  }

  Future<void> setProductActive(String id, bool active) async {
    final db = AppDatabase.instance;
    await (db.update(db.products)..where((t) => t.id.equals(id))).write(ProductsCompanion(isActive: drift.Value(active)));

    await MutationQueue.instance.run(
      entityType: 'product',
      method: 'PATCH',
      path: '/v1/admin/products/$id',
      body: {'isActive': active},
    );
  }

  Future<void> deleteProduct(String id) async {
    final db = AppDatabase.instance;
    await (db.delete(db.products)..where((t) => t.id.equals(id))).go();
    
    await MutationQueue.instance.run(
      entityType: 'product',
      method: 'DELETE',
      path: '/v1/admin/products/$id',
    );
  }

  Future<String> uploadProductImage(
    Uint8List bytes, {
    String ext = 'jpg',
    String contentType = 'image/jpeg',
  }) {
    return _api.uploadBytes('/v1/uploads/product', bytes,
        filename: 'product.$ext', field: 'file');
  }

  Future<void> deleteImageByUrl(String url) async {}
}
