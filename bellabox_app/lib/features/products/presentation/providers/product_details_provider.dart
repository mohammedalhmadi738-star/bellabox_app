import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:bellabox/features/products/data/datasources/catalog_remote_datasource.dart';
import 'package:bellabox/features/products/domain/entities/product.dart';

final productDetailsProvider =
    FutureProvider.autoDispose.family<Product, String>((ref, slug) {
  return ref.watch(catalogRemoteDataSourceProvider).productDetails(slug);
});

final relatedProductsProvider =
    FutureProvider.autoDispose.family<List<Product>, int>((ref, productId) {
  return ref.watch(catalogRemoteDataSourceProvider).related(productId);
});
