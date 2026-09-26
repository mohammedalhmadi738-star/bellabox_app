import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:bellabox/core/errors/exceptions.dart';
import 'package:bellabox/features/cart/presentation/providers/cart_provider.dart';
import 'package:bellabox/features/checkout/data/datasources/checkout_remote_datasource.dart';

class CheckoutState {
  final Address? selectedAddress;
  final ShippingMethod? selectedShipping;
  final String? paymentMethod; // moyasar | tabby | tamara | cod
  final bool termsAccepted;
  final bool placing;
  final String? error;

  const CheckoutState({
    this.selectedAddress,
    this.selectedShipping,
    this.paymentMethod,
    this.termsAccepted = false,
    this.placing = false,
    this.error,
  });

  bool get canPlaceOrder =>
      selectedAddress != null &&
      selectedShipping != null &&
      paymentMethod != null &&
      termsAccepted &&
      !placing;

  CheckoutState copyWith({
    Address? selectedAddress,
    ShippingMethod? selectedShipping,
    String? paymentMethod,
    bool? termsAccepted,
    bool? placing,
    String? error,
    bool clearError = false,
  }) {
    return CheckoutState(
      selectedAddress: selectedAddress ?? this.selectedAddress,
      selectedShipping: selectedShipping ?? this.selectedShipping,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      termsAccepted: termsAccepted ?? this.termsAccepted,
      placing: placing ?? this.placing,
      error: clearError ? null : (error ?? this.error),
    );
  }
}

class CheckoutNotifier extends AutoDisposeNotifier<CheckoutState> {
  @override
  CheckoutState build() => const CheckoutState();

  void selectAddress(Address address) =>
      state = state.copyWith(selectedAddress: address, clearError: true);

  void selectShipping(ShippingMethod method) =>
      state = state.copyWith(selectedShipping: method, clearError: true);

  void selectPayment(String method) =>
      state = state.copyWith(paymentMethod: method, clearError: true);

  void toggleTerms(bool value) =>
      state = state.copyWith(termsAccepted: value, clearError: true);

  /// Returns created order on success, null on failure (error in state)
  Future<CreatedOrder?> placeOrder() async {
    if (!state.canPlaceOrder) return null;
    state = state.copyWith(placing: true, clearError: true);
    try {
      final order =
          await ref.read(checkoutRemoteDataSourceProvider).createOrder(
                addressId: state.selectedAddress!.id,
                shippingMethodId: state.selectedShipping!.id,
                paymentMethod: state.paymentMethod!,
              );
      state = state.copyWith(placing: false);
      // Refresh cart (server clears it after order)
      ref.read(cartProvider.notifier).refresh();
      return order;
    } on DioException catch (e) {
      final err = e.error;
      state = state.copyWith(
        placing: false,
        error: err is AppException ? err.message : (e.message ?? 'حدث خطأ'),
      );
      return null;
    } catch (e) {
      state = state.copyWith(placing: false, error: e.toString());
      return null;
    }
  }
}

final checkoutProvider =
    AutoDisposeNotifierProvider<CheckoutNotifier, CheckoutState>(
  CheckoutNotifier.new,
);
