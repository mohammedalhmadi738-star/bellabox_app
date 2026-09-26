import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:bellabox/core/errors/exceptions.dart';
import 'package:bellabox/features/cart/data/datasources/cart_remote_datasource.dart';
import 'package:bellabox/features/cart/domain/entities/cart.dart';

class CartNotifier extends AsyncNotifier<Cart> {
  @override
  Future<Cart> build() async {
    try {
      return await ref.watch(cartRemoteDataSourceProvider).getCart();
    } on DioException catch (e) {
      final err = e.error;
      if (err is NetworkException) rethrow;
      // Empty cart on other server responses
      return Cart.empty();
    }
  }

  Future<String?> addItem({
    required int productId,
    int? variantId,
    int quantity = 1,
  }) async {
    try {
      final cart = await ref.read(cartRemoteDataSourceProvider).addItem(
            productId: productId,
            variantId: variantId,
            quantity: quantity,
          );
      state = AsyncData(cart);
      return null;
    } on DioException catch (e) {
      return _errorMessage(e);
    } catch (e) {
      return e.toString();
    }
  }

  Future<String?> updateQuantity(int itemId, int quantity) async {
    if (quantity < 1) return removeItem(itemId);
    final previous = state.valueOrNull;
    // Optimistic UI
    if (previous != null) {
      final optimistic = Cart(
        items: previous.items
            .map((i) => i.id == itemId
                ? CartItem(
                    id: i.id,
                    productId: i.productId,
                    variantId: i.variantId,
                    name: i.name,
                    imageUrl: i.imageUrl,
                    unitPrice: i.unitPrice,
                    quantity: quantity,
                  )
                : i)
            .toList(),
        subtotal: previous.subtotal,
        discount: previous.discount,
        shipping: previous.shipping,
        tax: previous.tax,
        total: previous.total,
        couponCode: previous.couponCode,
      );
      state = AsyncData(optimistic);
    }
    try {
      final cart = await ref
          .read(cartRemoteDataSourceProvider)
          .updateItem(itemId: itemId, quantity: quantity);
      state = AsyncData(cart);
      return null;
    } on DioException catch (e) {
      if (previous != null) state = AsyncData(previous);
      return _errorMessage(e);
    }
  }

  Future<String?> removeItem(int itemId) async {
    try {
      final cart =
          await ref.read(cartRemoteDataSourceProvider).removeItem(itemId);
      state = AsyncData(cart);
      return null;
    } on DioException catch (e) {
      return _errorMessage(e);
    }
  }

  Future<String?> applyCoupon(String code) async {
    try {
      final cart =
          await ref.read(cartRemoteDataSourceProvider).applyCoupon(code);
      state = AsyncData(cart);
      return null;
    } on DioException catch (e) {
      return _errorMessage(e);
    }
  }

  Future<String?> removeCoupon() async {
    try {
      final cart = await ref.read(cartRemoteDataSourceProvider).removeCoupon();
      state = AsyncData(cart);
      return null;
    } on DioException catch (e) {
      return _errorMessage(e);
    }
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => ref.read(cartRemoteDataSourceProvider).getCart(),
    );
  }

  String _errorMessage(DioException e) {
    final err = e.error;
    if (err is AppException) return err.message;
    return e.message ?? 'حدث خطأ';
  }
}

final cartProvider = AsyncNotifierProvider<CartNotifier, Cart>(CartNotifier.new);

final cartItemCountProvider = Provider<int>((ref) {
  return ref.watch(cartProvider).valueOrNull?.itemCount ?? 0;
});
