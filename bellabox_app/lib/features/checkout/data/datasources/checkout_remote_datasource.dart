import 'dart:math';

import 'package:dio/dio.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:bellabox/core/constants/api_endpoints.dart';
import 'package:bellabox/core/network/dio_client.dart';
import 'package:bellabox/core/network/response_handler.dart';

// ── Entities ──

class Address extends Equatable {
  final int id;
  final String label;
  final String recipientName;
  final String phone;
  final String city;
  final String district;
  final String street;
  final bool isDefault;

  const Address({
    required this.id,
    required this.label,
    required this.recipientName,
    required this.phone,
    required this.city,
    required this.district,
    required this.street,
    this.isDefault = false,
  });

  String get summary => '$city، $district، $street';

  factory Address.fromJson(Map<String, dynamic> json) => Address(
        id: json['id'] as int,
        label: json['label'] as String? ?? '',
        recipientName: json['recipient_name'] as String? ?? '',
        phone: json['phone'] as String? ?? '',
        city: json['city'] as String? ?? '',
        district: json['district'] as String? ?? '',
        street: json['street'] as String? ?? '',
        isDefault: json['is_default'] as bool? ?? false,
      );

  @override
  List<Object?> get props => [id];
}

class ShippingMethod extends Equatable {
  final int id;
  final String name;
  final double cost;
  final int? estimatedDaysMin;
  final int? estimatedDaysMax;

  const ShippingMethod({
    required this.id,
    required this.name,
    required this.cost,
    this.estimatedDaysMin,
    this.estimatedDaysMax,
  });

  factory ShippingMethod.fromJson(Map<String, dynamic> json) =>
      ShippingMethod(
        id: json['id'] as int,
        name: json['name'] as String? ?? '',
        cost: (json['cost'] as num?)?.toDouble() ?? 0,
        estimatedDaysMin: json['estimated_days_min'] as int?,
        estimatedDaysMax: json['estimated_days_max'] as int?,
      );

  @override
  List<Object?> get props => [id];
}

class CreatedOrder {
  final int id;
  final String orderNumber;
  final String paymentMethod;
  const CreatedOrder({
    required this.id,
    required this.orderNumber,
    required this.paymentMethod,
  });
}

// ── Datasource ──

class CheckoutRemoteDataSource {
  final Dio _dio;
  CheckoutRemoteDataSource(this._dio);

  Future<List<Address>> addresses() async {
    final res = await _dio.get(ApiEndpoints.addresses);
    final body = ensureSuccess(res);
    final list = body['data'] as List? ?? [];
    return list.map((a) => Address.fromJson(a as Map<String, dynamic>)).toList();
  }

  Future<Address> createAddress(Map<String, dynamic> data) async {
    final res = await _dio.post(ApiEndpoints.addresses, data: data);
    final body = ensureSuccess(res);
    return Address.fromJson(body['data'] as Map<String, dynamic>);
  }

  Future<List<ShippingMethod>> shippingMethods({String? city}) async {
    final res = await _dio.get(ApiEndpoints.shippingMethods, queryParameters: {
      if (city != null) 'city': city,
    });
    final body = ensureSuccess(res);
    final list = body['data'] as List? ?? [];
    return list
        .map((m) => ShippingMethod.fromJson(m as Map<String, dynamic>))
        .toList();
  }

  /// POST /orders with Idempotency-Key header (contract requirement:
  /// prevents double order on flaky network retry)
  Future<CreatedOrder> createOrder({
    required int addressId,
    required int shippingMethodId,
    required String paymentMethod,
    String? notes,
  }) async {
    final idempotencyKey = _generateIdempotencyKey();
    final res = await _dio.post(
      ApiEndpoints.orders,
      data: {
        'address_id': addressId,
        'shipping_method_id': shippingMethodId,
        'payment_method': paymentMethod,
        if (notes != null && notes.isNotEmpty) 'notes': notes,
      },
      options: Options(headers: {'Idempotency-Key': idempotencyKey}),
    );
    final body = ensureSuccess(res);
    final data = body['data'] as Map<String, dynamic>;
    return CreatedOrder(
      id: data['id'] as int,
      orderNumber: data['order_number'] as String,
      paymentMethod: paymentMethod,
    );
  }

  String _generateIdempotencyKey() {
    final rand = Random.secure();
    final bytes = List<int>.generate(16, (_) => rand.nextInt(256));
    return bytes.map((b) => b.toRadixString(16).padLeft(2, '0')).join();
  }

}

final checkoutRemoteDataSourceProvider =
    Provider<CheckoutRemoteDataSource>((ref) {
  return CheckoutRemoteDataSource(ref.watch(dioClientProvider));
});

final addressesProvider = FutureProvider.autoDispose<List<Address>>((ref) {
  return ref.watch(checkoutRemoteDataSourceProvider).addresses();
});

final shippingMethodsProvider =
    FutureProvider.autoDispose<List<ShippingMethod>>((ref) {
  return ref.watch(checkoutRemoteDataSourceProvider).shippingMethods();
});
