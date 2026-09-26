import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:bellabox/core/errors/exceptions.dart';
import 'package:bellabox/core/network/api_response.dart';
import 'package:bellabox/features/products/data/datasources/catalog_remote_datasource.dart';
import 'package:bellabox/features/products/domain/entities/product.dart';

/// Paginated product list state (infinite scroll)
class PaginatedListState {
  final List<Product> items;
  final PaginationMeta meta;
  final bool loadingMore;
  final bool initialLoading;
  final String? error;

  const PaginatedListState({
    this.items = const [],
    required this.meta,
    this.loadingMore = false,
    this.initialLoading = true,
    this.error,
  });

  bool get hasMore => meta.hasNext;

  PaginatedListState copyWith({
    List<Product>? items,
    PaginationMeta? meta,
    bool? loadingMore,
    bool? initialLoading,
    String? error,
    bool clearError = false,
  }) {
    return PaginatedListState(
      items: items ?? this.items,
      meta: meta ?? this.meta,
      loadingMore: loadingMore ?? this.loadingMore,
      initialLoading: initialLoading ?? this.initialLoading,
      error: clearError ? null : (error ?? this.error),
    );
  }
}

/// Family provider: paginated products per category ID.
/// autoDispose: state is released when the category page is popped,
/// preventing unbounded memory growth across browsed categories.
class CategoryProductsNotifier
    extends AutoDisposeFamilyNotifier<PaginatedListState, int> {
  bool _alive = true;

  @override
  PaginatedListState build(int categoryId) {
    _alive = true;
    ref.onDispose(() => _alive = false);
    Future.microtask(loadFirst);
    return PaginatedListState(meta: PaginationMeta.empty());
  }

  Future<void> loadFirst() async {
    if (!_alive) return;
    state = state.copyWith(initialLoading: true, clearError: true);
    try {
      final result = await ref
          .read(catalogRemoteDataSourceProvider)
          .listProducts(categoryId: arg, page: 1);
      if (!_alive) return;
      state = PaginatedListState(
        items: result.items,
        meta: result.meta,
        initialLoading: false,
      );
    } on DioException catch (e) {
      if (!_alive) return;
      final err = e.error;
      state = state.copyWith(
        initialLoading: false,
        error: err is AppException ? err.message : (e.message ?? 'حدث خطأ'),
      );
    }
  }

  Future<void> loadMore() async {
    if (!_alive || state.loadingMore || !state.hasMore || state.initialLoading) {
      return;
    }
    state = state.copyWith(loadingMore: true);
    try {
      final result = await ref
          .read(catalogRemoteDataSourceProvider)
          .listProducts(categoryId: arg, page: state.meta.currentPage + 1);
      if (!_alive) return;
      state = state.copyWith(
        items: [...state.items, ...result.items],
        meta: result.meta,
        loadingMore: false,
      );
    } on DioException {
      if (!_alive) return;
      state = state.copyWith(loadingMore: false);
    }
  }

  Future<void> refresh() => loadFirst();
}

final categoryProductsProvider = NotifierProvider.autoDispose
    .family<CategoryProductsNotifier, PaginatedListState, int>(
  CategoryProductsNotifier.new,
);

/// All categories (grid page + slug resolution) — intentionally kept alive
/// as an app-level cache of the category tree.
final allCategoriesProvider = FutureProvider<List<Category>>((ref) {
  return ref.watch(catalogRemoteDataSourceProvider).categories();
});
