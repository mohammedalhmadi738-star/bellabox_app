import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:bellabox/core/constants/api_endpoints.dart';
import 'package:bellabox/core/network/api_response.dart';
import 'package:bellabox/core/network/dio_client.dart';
import 'package:bellabox/core/network/response_handler.dart';
import 'package:bellabox/features/orders/domain/entities/order.dart';

class PaginatedOrders {
  final List<Order> items;
  final PaginationMeta meta;
  const PaginatedOrders(this.items, this.meta);
}

class OrdersRemoteDataSource {
  final Dio _dio;
  OrdersRemoteDataSource(this._dio);

  /// GET /orders (paginated)
  Future<PaginatedOrders> list({int page = 1}) async {
    final res = await _dio.get(ApiEndpoints.orders, queryParameters: {
      'page': page,
    });
    final body = ensureSuccess(res);
    final list = body['data'] as List? ?? [];
    final orders =
        list.map((o) => Order.fromJson(o as Map<String, dynamic>)).toList();
    final meta = body['meta'] != null
        ? PaginationMeta.fromJson(body['meta'] as Map<String, dynamic>)
        : PaginationMeta.empty();
    return PaginatedOrders(orders, meta);
  }

  /// GET /orders/{order_number}
  Future<Order> details(String orderNumber) async {
    final res = await _dio.get(ApiEndpoints.order(orderNumber));
    final body = ensureSuccess(res);
    return Order.fromJson(body['data'] as Map<String, dynamic>);
  }

  /// POST /orders/{order_number}/cancel
  Future<Order> cancel(String orderNumber) async {
    final res = await _dio.post(ApiEndpoints.orderCancel(orderNumber));
    final body = ensureSuccess(res);
    return Order.fromJson(body['data'] as Map<String, dynamic>);
  }

}

final ordersRemoteDataSourceProvider = Provider<OrdersRemoteDataSource>((ref) {
  return OrdersRemoteDataSource(ref.watch(dioClientProvider));
});

/// Orders list — first page. TODO(phase5): infinite scroll for long history.
final ordersListProvider = FutureProvider.autoDispose<List<Order>>((ref) async {
  final result = await ref.watch(ordersRemoteDataSourceProvider).list();
  return result.items;
});

final orderDetailsProvider =
    FutureProvider.autoDispose.family<Order, String>((ref, orderNumber) {
  return ref.watch(ordersRemoteDataSourceProvider).details(orderNumber);
});
