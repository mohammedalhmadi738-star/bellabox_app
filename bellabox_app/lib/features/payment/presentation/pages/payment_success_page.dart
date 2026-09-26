import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:bellabox/core/localization/app_localizations.dart';
import 'package:bellabox/core/routing/route_names.dart';
import 'package:bellabox/core/theme/app_colors.dart';
import 'package:bellabox/core/theme/app_text_styles.dart';
import 'package:bellabox/shared/widgets/buttons/bella_primary_button.dart';
import 'package:bellabox/shared/widgets/buttons/bella_secondary_button.dart';

class PaymentSuccessPage extends StatefulWidget {
  final String orderNumber;
  const PaymentSuccessPage({super.key, required this.orderNumber});

  @override
  State<PaymentSuccessPage> createState() => _PaymentSuccessPageState();
}

class _PaymentSuccessPageState extends State<PaymentSuccessPage>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..forward();
    _scale = CurvedAnimation(parent: _controller, curve: Curves.elasticOut);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              const Spacer(),
              ScaleTransition(
                scale: _scale,
                child: Container(
                  width: 128,
                  height: 128,
                  decoration: const BoxDecoration(
                    color: AppColors.success,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.check_rounded,
                    color: Colors.white,
                    size: 72,
                  ),
                ),
              ),
              const SizedBox(height: 36),
              FadeTransition(
                opacity: _controller,
                child: Column(
                  children: [
                    Text(
                      context.tr('payment.successTitle'),
                      style: AppTextStyles.h1,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      context.tr('payment.successBody'),
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.textSecondary,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(100),
                      ),
                      child: Text(
                        '${context.tr('orders.orderNumber')}: ${widget.orderNumber}',
                        style: AppTextStyles.labelLarge,
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              BellaPrimaryButton(
                label: context.tr('payment.viewOrder'),
                onPressed: () => context.go(
                  '${RouteNames.orderDetails}/${widget.orderNumber}',
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
