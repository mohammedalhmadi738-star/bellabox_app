import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:bellabox/core/constants/api_endpoints.dart';
import 'package:bellabox/core/constants/app_constants.dart';
import 'package:bellabox/core/errors/exceptions.dart';
import 'package:bellabox/core/network/dio_client.dart';

/// Payment flow per Rule #10:
/// 1. POST /payments/initiate → returns redirect_url (opened in EXTERNAL browser
///    via url_launcher — NOT WebView).
/// 2. Poll GET /payments/{orderId}/status until paid/failed/timeout.
sealed class PaymentFlowState {
  const PaymentFlowState();
}

class PaymentInitial extends PaymentFlowState {
  const PaymentInitial();
}

class PaymentInitiating extends PaymentFlowState {
  const PaymentInitiating();
}

class PaymentPolling extends PaymentFlowState {
  final int elapsedSeconds;
  const PaymentPolling(this.elapsedSeconds);
}

class PaymentSucceeded extends PaymentFlowState {
  const PaymentSucceeded();
}

class PaymentFailed extends PaymentFlowState {
  final String? reason;
  const PaymentFailed([this.reason]);
}

class PaymentNotifier extends AutoDisposeNotifier<PaymentFlowState> {
  Timer? _pollTimer;
  DateTime? _pollStart;

  @override
  PaymentFlowState build() {
    ref.onDispose(() => _pollTimer?.cancel());
    return const PaymentInitial();
  }

  /// Initiates payment session and starts polling.
  Future<void> start({required int orderId, required String gateway}) async {
    state = const PaymentInitiating();
    try {
      final dio = ref.read(dioClientProvider);
      final res = await dio.post(ApiEndpoints.paymentInitiate, data: {
        'order_id': orderId,
        'gateway': gateway,
      });
      final body = res.data as Map<String, dynamic>;
      if (body['status'] != true) {
        state = PaymentFailed(body['message'] as String?);
        return;
      }
      final data = body['data'] as Map<String, dynamic>? ?? {};
      final redirectUrl =
          data['redirect_url'] as String? ?? data['url'] as String?;

      // Open gateway page in external browser (never WebView)
      if (redirectUrl != null && redirectUrl.isNotEmpty) {
        final uri = Uri.tryParse(redirectUrl);
        if (uri != null) {
          await launchUrl(uri, mode: LaunchMode.externalApplication);
        }
      }

      _startPolling(orderId);
    } on DioException catch (e) {
      final err = e.error;
      state = PaymentFailed(
        err is AppException ? err.message : (e.message ?? 'حدث خطأ'),
      );
    } catch (e) {
      state = PaymentFailed(e.toString());
    }
  }

  void _startPolling(int orderId) {
    _pollStart = DateTime.now();
    state = const PaymentPolling(0);
    _pollTimer?.cancel();
    _pollTimer = Timer.periodic(AppConstants.paymentPollInterval, (_) async {
      final elapsed = DateTime.now().difference(_pollStart!);
      if (elapsed > AppConstants.paymentPollTimeout) {
        _pollTimer?.cancel();
        state = const PaymentFailed('انتهت مهلة الدفع');
        return;
      }
      try {
        final dio = ref.read(dioClientProvider);
        final res = await dio.get(ApiEndpoints.paymentStatus(orderId));
        final body = res.data as Map<String, dynamic>;
        if (body['status'] != true) return; // keep polling
        final data = body['data'] as Map<String, dynamic>? ?? {};
        final paymentStatus = data['payment_status'] as String? ??
            data['status'] as String? ??
            '';
        switch (paymentStatus) {
          case 'paid':
          case 'captured':
            _pollTimer?.cancel();
            state = const PaymentSucceeded();
          case 'failed':
          case 'cancelled':
            _pollTimer?.cancel();
            state = PaymentFailed(data['failure_reason'] as String?);
          default:
            // pending/authorized → keep polling, update elapsed
            state = PaymentPolling(elapsed.inSeconds);
        }
      } on DioException {
        // Network hiccup during polling → keep polling silently
      }
    });
  }

  void cancelPolling() {
    _pollTimer?.cancel();
  }
}

final paymentProvider =
    AutoDisposeNotifierProvider<PaymentNotifier, PaymentFlowState>(
  PaymentNotifier.new,
);
