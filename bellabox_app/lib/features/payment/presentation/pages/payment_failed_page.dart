import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:bellabox/core/localization/app_localizations.dart';
import 'package:bellabox/core/routing/route_names.dart';
import 'package:bellabox/core/theme/app_colors.dart';
import 'package:bellabox/core/theme/app_text_styles.dart';
import 'package:bellabox/shared/widgets/buttons/bella_primary_button.dart';
import 'package:bellabox/shared/widgets/buttons/bella_secondary_button.dart';

class PaymentFailedPage extends StatelessWidget {
  final int orderId;
  final String orderNumber;
  final String gateway;
  final String? reason;

  const PaymentFailedPage({
    super.key,
    required this.orderId,
    required this.orderNumber,
    required this.gateway,
    this.reason,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              const Spacer(),
              Container(
                width: 128,
                height: 128,
                decoration: BoxDecoration(
                  color: AppColors.error.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.close_rounded,
                  color: AppColors.error,
                  size: 72,
                ),
              ),
              const SizedBox(height: 36),
              Text(
                context.tr('payment.failedTitle'),
                style: AppTextStyles.h1,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Text(
                reason ?? context.tr('payment.failedBody'),
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Text(
                '${context.tr('orders.orderNumber')}: $orderNumber',
                style: AppTextStyles.labelMedium,
              ),
              const Spacer(),
              BellaPrimaryButton(
                label: context.tr('payment.tryAgain'),
                onPressed: () => context.go(
                  '${RouteNames.paymentPending}'
                  '?orderId=$orderId&order=$orderNumber&gateway=$gateway',
                ),
              ),
              const SizedBox(height: 12),
              BellaSecondaryButton(
                label: context.tr('payment.backToHome'),
                onPressed: () => context.go(RouteNames.home),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
