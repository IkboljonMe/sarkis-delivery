import 'dart:typed_data';

import '../models/category_model.dart';
import '../models/product_model.dart';
import 'api_client.dart';

class ProductService {
  ProductService._();
  static final ProductService instance = ProductService._();

  final ApiClient _api = ApiClient.instance;

  static const _interval = Duration(seconds: 30);

  List<CategoryModel> _categories(dynamic res) => (res as List)
      .map((e) => CategoryModel.fromJson(Map<String, dynamic>.from(e as Map)))
      .toList();

  List<ProductModel> _products(dynamic res) => (res as List)
      .map((e) => ProductModel.fromJson(Map<String, dynamic>.from(e as Map)))
      .toList();

  // ---- Categories ----
  Stream<List<CategoryModel>> activeCategoriesStream() => ApiClient.poll(
      _interval, () async => _categories(await _api.get('/v1/categories')));

  Stream<List<CategoryModel>> allCategoriesStream() => ApiClient.poll(
      _interval, () async => _categories(await _api.get('/v1/categories?all=true')));

  Future<void> saveCategory(CategoryModel c) async {
    final body = {
      'name': c.name,
      'imageUrl': c.imageUrl,
      'sortOrder': c.sortOrder,
      'isActive': c.isActive,
    };
    if (c.id.isEmpty) {
      await _api.post('/v1/admin/categories', body);
    } else {
      await _api.patch('/v1/admin/categories/${c.id}', body);
    }
  }

  Future<void> setCategoryActive(String id, bool active) =>
      _api.patch('/v1/admin/categories/$id', {'isActive': active});

  Future<void> deleteCategory(String id) async {
    await _api.delete('/v1/admin/categories/$id');
  }

  // ---- Products ----
  Stream<List<ProductModel>> activeProductsStream() => ApiClient.poll(
      _interval, () async => _products(await _api.get('/v1/products')));

  Stream<List<ProductModel>> productsByCategoryStream(String categoryId) =>
      ApiClient.poll(_interval,
          () async => _products(await _api.get('/v1/products?categoryId=$categoryId')));

  Stream<List<ProductModel>> allProductsStream() => ApiClient.poll(
      _interval, () async => _products(await _api.get('/v1/products?all=true')));

  Future<void> saveProduct(ProductModel p) async {
    final body = Map<String, dynamic>.from(p.toJson())..remove('id');
    if (p.id.isEmpty) {
      await _api.post('/v1/admin/products', body);
    } else {
      await _api.patch('/v1/admin/products/${p.id}', body);
    }
  }

  Future<void> setProductActive(String id, bool active) =>
      _api.patch('/v1/admin/products/$id', {'isActive': active});

  Future<void> deleteProduct(String id) async {
    await _api.delete('/v1/admin/products/$id');
  }

  /// Uploads a product photo and returns its public URL.
  Future<String> uploadProductImage(
    Uint8List bytes, {
    String ext = 'jpg',
    String contentType = 'image/jpeg',
  }) {
    return _api.uploadBytes('/v1/uploads/product', bytes,
        filename: 'product.$ext', field: 'file');
  }

  /// Old photos stay on the server's uploads volume; nothing to do client-side.
  Future<void> deleteImageByUrl(String url) async {}
}
