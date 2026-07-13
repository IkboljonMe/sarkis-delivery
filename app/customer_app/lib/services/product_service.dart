import '../models/category_model.dart';
import '../models/product_model.dart';
import 'api_client.dart';

class ProductService {
  ProductService._();
  static final ProductService instance = ProductService._();

  final ApiClient _api = ApiClient.instance;

  static const _interval = Duration(seconds: 60);

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

  // ---- Products ----
  Stream<List<ProductModel>> activeProductsStream() => ApiClient.poll(
      _interval, () async => _products(await _api.get('/v1/products')));

  Stream<List<ProductModel>> productsByCategoryStream(String categoryId) =>
      ApiClient.poll(_interval,
          () async => _products(await _api.get('/v1/products?categoryId=$categoryId')));

  Stream<List<ProductModel>> allProductsStream() => ApiClient.poll(
      _interval, () async => _products(await _api.get('/v1/products?all=true')));
}
