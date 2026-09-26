import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:bellabox/core/constants/api_endpoints.dart';
import 'package:bellabox/core/network/api_response.dart';
import 'package:bellabox/core/network/dio_client.dart';
import 'package:bellabox/core/network/response_handler.dart';
import 'package:bellabox/features/products/domain/entities/product.dart';

class PaginatedProducts {
  final List<Product> items;
  final PaginationMeta meta;
  const PaginatedProducts(this.items, this.meta);
}

class CatalogRemoteDataSource {
  final Dio _dio;
  CatalogRemoteDataSource(this._dio);

  /// GET /products with filters
  Future<PaginatedProducts> listProducts({
    int page = 1,
    int perPage = 20,
    int? categoryId,
    int? brandId,
    double? minPrice,
    double? maxPrice,
    String? sort,
    bool? inStock,
  }) async {
    final res = await _dio.get(ApiEndpoints.products, queryParameters: {
      'page': page,
      'per_page': perPage,
      if (categoryId != null) 'category_id': categoryId,
      if (brandId != null) 'brand_id': brandId,
      if (minPrice != null) 'min_price': minPrice,
      if (maxPrice != null) 'max_price': maxPrice,
      if (sort != null) 'sort': sort,
      if (inStock != null) 'in_stock': inStock,
    });
    return _parsePaginated(res);
  }

  /// GET /products/search?q=
  Future<PaginatedProducts> search(String query, {int page = 1}) async {
    final res = await _dio.get(ApiEndpoints.productSearch, queryParameters: {
      'q': query,
      'page': page,
    });
    return _parsePaginated(res);
  }

  /// GET /products/{slug}
  Future<Product> productDetails(String slug) async {
    final res = await _dio.get(ApiEndpoints.productBySlug(slug));
    final body = ensureSuccess(res);
    return Product.fromJson(body['data'] as Map<String, dynamic>);
  }

  /// GET /products/featured, /new-arrivals, /best-sellers
  Future<List<Product>> featured() => _listOnly(ApiEndpoints.productsFeatured);
  Future<List<Product>> newArrivals() =>
      _listOnly(ApiEndpoints.productsNewArrivals);
  Future<List<Product>> bestSellers() =>
      _listOnly(ApiEndpoints.productsBestSellers);

  /// GET /products/{id}/related
  Future<List<Product>> related(int id) =>
      _listOnly(ApiEndpoints.productRelated(id));

  /// GET /categories (tree)
  Future<List<Category>> categories() async {
    final res = await _dio.get(ApiEndpoints.categories);
    final body = ensureSuccess(res);
    final list = body['data'] as List? ?? [];
    return list
        .map((c) => Category.fromJson(c as Map<String, dynamic>))
        .toList();
  }

  /// GET /banners
  Future<List<Banner>> banners() async {
    final res = await _dio.get(ApiEndpoints.banners);
    final body = ensureSuccess(res);
    final list = body['data'] as List? ?? [];
    return list.map((b) => Banner.fromJson(b as Map<String, dynamic>)).toList();
  }

  // ─── helpers ───

  Future<List<Product>> _listOnly(String path) async {
    final res = await _dio.get(path);
    final body = ensureSuccess(res);
    final list = body['data'] as List? ?? [];
    return list.map((p) => Product.fromJson(p as Map<String, dynamic>)).toList();
  }

  PaginatedProducts _parsePaginated(Response res) {
    final body = ensureSuccess(res);
    final list = body['data'] as List? ?? [];
    final products =
        list.map((p) => Product.fromJson(p as Map<String, dynamic>)).toList();
    final meta = body['meta'] != null
        ? PaginationMeta.fromJson(body['meta'] as Map<String, dynamic>)
        : PaginationMeta.empty();
    return PaginatedProducts(products, meta);
  }

}

final catalogRemoteDataSourceProvider = Provider<CatalogRemoteDataSource>((ref) {
  return CatalogRemoteDataSource(ref.watch(dioClientProvider));
});
