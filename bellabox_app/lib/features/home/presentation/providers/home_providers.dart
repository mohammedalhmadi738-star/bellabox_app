import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:bellabox/features/products/data/datasources/catalog_remote_datasource.dart';
import 'package:bellabox/features/products/domain/entities/product.dart';

/// Home screen data — each section is an independent async provider so the
/// page renders progressively (shimmer per section) instead of blocking.

final bannersProvider = FutureProvider.autoDispose<List<Banner>>((ref) {
  return ref.watch(catalogRemoteDataSourceProvider).banners();
});

final homeCategoriesProvider =
    FutureProvider.autoDispose<List<Category>>((ref) {
  return ref.watch(catalogRemoteDataSourceProvider).categories();
});

final featuredProductsProvider =
    FutureProvider.autoDispose<List<Product>>((ref) {
  return ref.watch(catalogRemoteDataSourceProvider).featured();
});

final newArrivalsProvider = FutureProvider.autoDispose<List<Product>>((ref) {
  return ref.watch(catalogRemoteDataSourceProvider).newArrivals();
});

final bestSellersProvider = FutureProvider.autoDispose<List<Product>>((ref) {
  return ref.watch(catalogRemoteDataSourceProvider).bestSellers();
});
