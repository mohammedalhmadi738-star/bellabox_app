import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:bellabox/core/constants/api_endpoints.dart';
import 'package:bellabox/core/constants/storage_keys.dart';
import 'package:bellabox/core/network/dio_client.dart';
import 'package:bellabox/core/network/response_handler.dart';
import 'package:bellabox/core/storage/local_storage.dart';
import 'package:bellabox/features/cart/domain/entities/cart.dart';

/// Server-side cart per API contract.
/// Guest cart identified via X-Cart-Token header (persisted locally).
class CartRemoteDataSource {
  final Dio _dio;
  CartRemoteDataSource(this._dio);

  Options _cartOptions() {
    final token = LocalStorage.prefs.getString(StorageKeys.cartToken);
    return Options(headers: {
      if (token != null && token.isNotEmpty) 'X-Cart-Token': token,
    });
  }

  void _persistCartToken(Response res) {
    // Backend may issue/return a guest cart token in headers or body
    final headerToken = res.headers.value('x-cart-token');
    if (headerToken != null && headerToken.isNotEmpty) {
      LocalStorage.prefs.setString(StorageKeys.cartToken, headerToken);
      return;
    }
    final body = res.data;
    if (body is Map<String, dynamic>) {
      final data = body['data'];
      if (data is Map<String, dynamic> && data['cart_token'] is String) {
        LocalStorage.prefs
            .setString(StorageKeys.cartToken, data['cart_token'] as String);
      }
    }
  }

  Future<Cart> getCart() async {
    final res = await _dio.get(ApiEndpoints.cart, options: _cartOptions());
    _persistCartToken(res);
    final body = ensureSuccess(res);
    final data = body['data'];
    if (data == null) return Cart.empty();
    return Cart.fromJson(data as Map<String, dynamic>);
  }

  Future<Cart> addItem({
    required int productId,
    int? variantId,
    int quantity = 1,
  }) async {
    final res = await _dio.post(
      ApiEndpoints.cartItems,
      data: {
        'product_id': productId,
        if (variantId != null) 'variant_id': variantId,
        'quantity': quantity,
      },
      options: _cartOptions(),
    );
    _persistCartToken(res);
    final body = ensureSuccess(res);
    return Cart.fromJson(body['data'] as Map<String, dynamic>);
  }

  Future<Cart> updateItem({required int itemId, required int quantity}) async {
    final res = await _dio.patch(
      ApiEndpoints.cartItem(itemId),
      data: {'quantity': quantity},
      options: _cartOptions(),
    );
    final body = ensureSuccess(res);
    return Cart.fromJson(body['data'] as Map<String, dynamic>);
  }

  Future<Cart> removeItem(int itemId) async {
    final res = await _dio.delete(
      ApiEndpoints.cartItem(itemId),
      options: _cartOptions(),
    );
    final body = ensureSuccess(res);
    final data = body['data'];
    if (data == null) return Cart.empty();
    return Cart.fromJson(data as Map<String, dynamic>);
  }

  Future<void> clear() async {
    final res = await _dio.delete(ApiEndpoints.cart, options: _cartOptions());
    ensureSuccess(res);
  }

  Future<Cart> applyCoupon(String code) async {
    final res = await _dio.post(
      ApiEndpoints.cartApplyCoupon,
      data: {'code': code},
      options: _cartOptions(),
    );
    final body = ensureSuccess(res);
    return Cart.fromJson(body['data'] as Map<String, dynamic>);
  }

  Future<Cart> removeCoupon() async {
    final res = await _dio.delete(
      ApiEndpoints.cartRemoveCoupon,
      options: _cartOptions(),
    );
    final body = ensureSuccess(res);
    return Cart.fromJson(body['data'] as Map<String, dynamic>);
  }

  /// POST /cart/merge — merge guest cart after login
  Future<Cart> merge() async {
    final res = await _dio.post(ApiEndpoints.cartMerge, options: _cartOptions());
    final body = ensureSuccess(res);
    final data = body['data'];
    if (data == null) return Cart.empty();
    return Cart.fromJson(data as Map<String, dynamic>);
  }

}

final cartRemoteDataSourceProvider = Provider<CartRemoteDataSource>((ref) {
  return CartRemoteDataSource(ref.watch(dioClientProvider));
});
