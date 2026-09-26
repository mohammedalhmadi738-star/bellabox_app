import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:bellabox/core/constants/app_constants.dart';
import 'package:bellabox/core/errors/exceptions.dart';
import 'package:bellabox/core/storage/local_storage.dart';
import 'package:bellabox/features/products/data/datasources/catalog_remote_datasource.dart';
import 'package:bellabox/features/products/domain/entities/product.dart';

sealed class SearchState {
  const SearchState();
}

class SearchIdle extends SearchState {
  const SearchIdle();
}

class SearchLoading extends SearchState {
  const SearchLoading();
}

class SearchResults extends SearchState {
  final List<Product> products;
  final String query;
  const SearchResults(this.products, this.query);
}

class SearchEmpty extends SearchState {
  final String query;
  const SearchEmpty(this.query);
}

class SearchError extends SearchState {
  final String message;
  const SearchError(this.message);
}

class SearchNotifier extends Notifier<SearchState> {
  Timer? _debounce;

  @override
  SearchState build() {
    ref.onDispose(() => _debounce?.cancel());
    return const SearchIdle();
  }

  void onQueryChanged(String query) {
    _debounce?.cancel();
    final trimmed = query.trim();
    if (trimmed.isEmpty) {
      state = const SearchIdle();
      return;
    }
    if (trimmed.length < 2) return;

    _debounce = Timer(AppConstants.searchDebounce, () => _search(trimmed));
  }

  Future<void> submit(String query) async {
    _debounce?.cancel();
    final trimmed = query.trim();
    if (trimmed.isEmpty) return;
    await _search(trimmed);
    await LocalStorage.addRecentSearch(
      trimmed,
      maxItems: AppConstants.maxRecentSearches,
    );
  }

  Future<void> _search(String query) async {
    state = const SearchLoading();
    try {
      final result =
          await ref.read(catalogRemoteDataSourceProvider).search(query);
      if (result.items.isEmpty) {
        state = SearchEmpty(query);
      } else {
        state = SearchResults(result.items, query);
        // Save successful search
        await LocalStorage.addRecentSearch(
          query,
          maxItems: AppConstants.maxRecentSearches,
        );
      }
    } on DioException catch (e) {
      final err = e.error;
      state = SearchError(
        err is AppException ? err.message : (e.message ?? 'حدث خطأ'),
      );
    } catch (e) {
      state = SearchError(e.toString());
    }
  }

  void clear() {
    _debounce?.cancel();
    state = const SearchIdle();
  }
}

final searchProvider =
    NotifierProvider<SearchNotifier, SearchState>(SearchNotifier.new);

final recentSearchesProvider = Provider<List<String>>((ref) {
  // Recomputed via manual invalidation after add/clear
  return LocalStorage.getRecentSearches();
});
