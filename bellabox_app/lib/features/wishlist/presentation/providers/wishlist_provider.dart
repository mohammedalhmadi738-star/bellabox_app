import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:bellabox/core/constants/api_endpoints.dart';
import 'package:bellabox/core/network/dio_client.dart';
import 'package:bellabox/core/storage/local_storage.dart';
import 'package:bellabox/features/auth/presentation/providers/auth_session_provider.dart';

/// Wishlist: local optimistic mirror synced with server when authenticated.
/// Guest wishlist stays local-only until login.
/// TODO(phase5): merge local wishlist to server on login.
class WishlistNotifier extends Notifier<Set<int>> {
  @override
  Set<int> build() {
    // Seed from local storage instantly
    final local = LocalStorage.getWishlistIds().toSet();
    // If authenticated, refresh from server in background
    final isAuth = ref.watch(isAuthenticatedProvider);
    if (isAuth) {
      _fetchServer();
    }
    return local;
  }

  Future<void> _fetchServer() async {
    try {
      final dio = ref.read(dioClientProvider);
      final res = await dio.get(ApiEndpoints.wishlist);
      final body = res.data as Map<String, dynamic>;
      if (body['status'] == true) {
        final list = body['data'] as List? ?? [];
        final ids = list
            .map((e) => e is Map<String, dynamic>
                ? (e['product_id'] as int? ?? e['id'] as int?)
                : null)
            .whereType<int>()
            .toSet();
        state = ids;
      }
    } on DioException {
      // Keep local state on failure
    } catch (_) {}
  }

  Future<void> toggle(int productId) async {
    // Optimistic
    final wasIn = state.contains(productId);
    state = wasIn
        ? (Set.of(state)..remove(productId))
        : (Set.of(state)..add(productId));
    await LocalStorage.toggleWishlistLocal(productId);

    // Server sync if authenticated
    final isAuth = ref.read(isAuthenticatedProvider);
    if (!isAuth) return;
    try {
      final dio = ref.read(dioClientProvider);
      await dio.post(ApiEndpoints.wishlistToggle, data: {
        'product_id': productId,
      });
    } on DioException {
      // Revert on failure
      state = wasIn
          ? (Set.of(state)..add(productId))
          : (Set.of(state)..remove(productId));
      await LocalStorage.toggleWishlistLocal(productId);
    }
  }

  bool contains(int productId) => state.contains(productId);
}

final wishlistProvider =
    NotifierProvider<WishlistNotifier, Set<int>>(WishlistNotifier.new);
