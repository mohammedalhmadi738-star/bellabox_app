import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:bellabox/core/localization/app_localizations.dart';
import 'package:bellabox/core/routing/route_names.dart';
import 'package:bellabox/core/theme/app_colors.dart';
import 'package:bellabox/core/theme/app_text_styles.dart';
import 'package:bellabox/features/payment/presentation/providers/payment_provider.dart';
import 'package:bellabox/shared/widgets/buttons/bella_secondary_button.dart';

/// Receives ?orderId=&order=&gateway= — initiates payment, opens the gateway
/// in the external browser, and polls status until success/failure/timeout.
class PaymentPendingPage extends ConsumerStatefulWidget {
  final int orderId;
  final String orderNumber;
  final String gateway;

  const PaymentPendingPage({
    super.key,
    required this.orderId,
    required this.orderNumber,
    required this.gateway,
  });

  @override
  ConsumerState<PaymentPendingPage> createState() =>
      _PaymentPendingPageState();
}

class _PaymentPendingPageState extends ConsumerState<PaymentPendingPage> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.read(paymentProvider.notifier).start(
          orderId: widget.orderId,
          gateway: widget.gateway,
        ));
  }

  @override
  Widget build(BuildContext context) {
    // Navigate on terminal states
    ref.listen<PaymentFlowState>(paymentProvider, (prev, next) {
      switch (next) {
        case PaymentSucceeded():
          context.go(
            '${RouteNames.paymentSuccess}?order=${widget.orderNumber}',
          );
        case PaymentFailed(:final reason):
          context.go(
            '${RouteNames.paymentFailed}'
            '?orderId=${widget.orderId}'
            '&order=${widget.orderNumber}'
            '&gateway=${widget.gateway}'
            '${reason != null ? '&reason=${Uri.encodeComponent(reason)}' : ''}',
          );
        default:
          break;
      }
    });

    final state = ref.watch(paymentProvider);

    return PopScope(
      canPop: false, // Prevent accidental back during payment
      child: Scaffold(
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(
                  width: 72,
                  height: 72,
                  child: CircularProgressIndicator(
                    strokeWidth: 3,
                    valueColor: AlwaysStoppedAnimation(AppColors.secondary),
                  ),
                ),
                const SizedBox(height: 40),
                Text(
                  context.tr('payment.processingTitle'),
                  style: AppTextStyles.h2,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                Text(
                  switch (state) {
                    PaymentInitiating() =>
                      context.tr('payment.initiating'),
                    PaymentPolling() =>
                      context.tr('payment.completeInBrowser'),
                    _ => context.tr('payment.processingBody'),
                  },
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.textSecondary,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  '${context.tr('orders.orderNumber')}: ${widget.orderNumber}',
                  style: AppTextStyles.labelMedium,
                ),
                const SizedBox(height: 48),
                // Escape hatch: user can bail to orders (payment continues
                // server-side; order details will reflect final status)
                BellaSecondaryButton(
                  label: context.tr('payment.checkLater'),
                  onPressed: () {
                    ref.read(paymentProvider.notifier).cancelPolling();
                    context.go(RouteNames.orders);
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
