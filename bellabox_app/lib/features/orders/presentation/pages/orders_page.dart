import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:bellabox/core/localization/app_localizations.dart';
import 'package:bellabox/core/routing/route_names.dart';
import 'package:bellabox/core/theme/app_colors.dart';
import 'package:bellabox/core/theme/app_dimensions.dart';
import 'package:bellabox/core/theme/app_text_styles.dart';
import 'package:bellabox/core/utils/formatters.dart';
import 'package:bellabox/features/auth/presentation/providers/auth_session_provider.dart';
import 'package:bellabox/features/orders/data/datasources/orders_remote_datasource.dart';
import 'package:bellabox/features/orders/domain/entities/order.dart';
import 'package:bellabox/shared/widgets/loaders/shimmer_box.dart';
import 'package:bellabox/shared/widgets/states/empty_state.dart';
import 'package:bellabox/shared/widgets/states/error_state.dart';

Color orderStatusColor(OrderStatus status) => switch (status) {
      OrderStatus.pending => AppColors.warning,
      OrderStatus.confirmed => AppColors.secondaryDark,
      OrderStatus.processing => AppColors.secondaryDark,
      OrderStatus.shipped => AppColors.primary,
      OrderStatus.delivered => AppColors.success,
      OrderStatus.cancelled => AppColors.error,
      OrderStatus.refunded => AppColors.textSecondary,
    };

String orderStatusLabel(BuildContext context, OrderStatus status) =>
    context.tr('orders.status.${status.name}');

class OrdersPage extends ConsumerWidget {
  const OrdersPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isAuth = ref.watch(isAuthenticatedProvider);

    if (!isAuth) {
      return Scaffold(
        appBar: AppBar(title: Text(context.tr('orders.title'))),
        body: EmptyState(
          icon: Icons.receipt_long_outlined,
          title: context.tr('orders.loginRequired'),
          actionLabel: context.tr('auth.loginTitle'),
          onAction: () => context.push(RouteNames.login),
        ),
      );
    }

    final ordersAsync = ref.watch(ordersListProvider);

    return Scaffold(
      appBar: AppBar(title: Text(context.tr('orders.title'))),
      body: RefreshIndicator(
        color: AppColors.primary,
        onRefresh: () async => ref.invalidate(ordersListProvider),
        child: ordersAsync.when(
          loading: () => ListView.separated(
            padding: const EdgeInsets.all(20),
            itemCount: 4,
            separatorBuilder: (_, __) => const SizedBox(height: 14),
            itemBuilder: (_, __) =>
                const ShimmerBox(height: 120, radius: AppDimensions.radius20),
          ),
          error: (e, _) => ErrorStateView(
            onRetry: () => ref.invalidate(ordersListProvider),
          ),
          data: (orders) {
            if (orders.isEmpty) {
              return EmptyState(
                icon: Icons.receipt_long_outlined,
                title: context.tr('orders.empty'),
                body: context.tr('orders.emptyHint'),
                actionLabel: context.tr('cart.shopNow'),
                onAction: () => context.go(RouteNames.home),
              );
            }
            return ListView.separated(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 40),
              itemCount: orders.length,
              separatorBuilder: (_, __) => const SizedBox(height: 14),
              itemBuilder: (context, i) => _OrderTile(order: orders[i]),
            );
          },
        ),
      ),
    );
  }
}

class _OrderTile extends StatelessWidget {
  final Order order;
  const _OrderTile({required this.order});

  @override
  Widget build(BuildContext context) {
    final statusColor = orderStatusColor(order.status);

    return Material(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(AppDimensions.radius20),
      child: InkWell(
        onTap: () => context.push(
          '${RouteNames.orderDetails}/${order.orderNumber}',
        ),
        borderRadius: BorderRadius.circular(AppDimensions.radius20),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      '#${order.orderNumber}',
                      style: AppTextStyles.labelLarge,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: statusColor.withValues(alpha: 0.1),
                      borderRadius:
                          BorderRadius.circular(AppDimensions.radiusPill),
                    ),
                    child: Text(
                      orderStatusLabel(context, order.status),
                      style: AppTextStyles.labelSmall.copyWith(
                        color: statusColor,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              if (order.createdAt != null)
                Text(
                  Formatters.date(order.createdAt!),
                  style: AppTextStyles.bodySmall,
                ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      '${order.itemCount} ${context.tr('orders.items')}',
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                  Text(
                    Formatters.price(order.total),
                    style: AppTextStyles.priceMedium,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
