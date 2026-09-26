import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:bellabox/core/localization/app_localizations.dart';
import 'package:bellabox/core/theme/app_colors.dart';
import 'package:bellabox/core/theme/app_dimensions.dart';
import 'package:bellabox/core/theme/app_text_styles.dart';
import 'package:bellabox/core/utils/formatters.dart';
import 'package:bellabox/features/orders/data/datasources/orders_remote_datasource.dart';
import 'package:bellabox/features/orders/domain/entities/order.dart';
import 'package:bellabox/features/orders/presentation/pages/orders_page.dart';
import 'package:bellabox/shared/widgets/buttons/bella_secondary_button.dart';
import 'package:bellabox/shared/widgets/dialogs/bella_dialog.dart';
import 'package:bellabox/shared/widgets/dialogs/bella_snackbar.dart';
import 'package:bellabox/shared/widgets/loaders/shimmer_box.dart';
import 'package:bellabox/shared/widgets/states/error_state.dart';

class OrderDetailsPage extends ConsumerWidget {
  final String orderNumber;
  const OrderDetailsPage({super.key, required this.orderNumber});

  static const _timelineStatuses = [
    OrderStatus.pending,
    OrderStatus.confirmed,
    OrderStatus.processing,
    OrderStatus.shipped,
    OrderStatus.delivered,
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final orderAsync = ref.watch(orderDetailsProvider(orderNumber));

    return Scaffold(
      appBar: AppBar(title: Text('#$orderNumber')),
      body: orderAsync.when(
        loading: () => ListView(
          padding: const EdgeInsets.all(20),
          children: const [
            ShimmerBox(height: 60, radius: AppDimensions.radius16),
            SizedBox(height: 16),
            ShimmerBox(height: 200, radius: AppDimensions.radius20),
            SizedBox(height: 16),
            ShimmerBox(height: 160, radius: AppDimensions.radius20),
          ],
        ),
        error: (e, _) => ErrorStateView(
          onRetry: () => ref.invalidate(orderDetailsProvider(orderNumber)),
        ),
        data: (order) {
          final statusColor = orderStatusColor(order.status);
          final isCancelledOrRefunded =
              order.status == OrderStatus.cancelled ||
                  order.status == OrderStatus.refunded;

          return ListView(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 40),
            children: [
              // ── Status header ──
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(AppDimensions.radius16),
                ),
                child: Row(
                  children: [
                    Icon(
                      isCancelledOrRefunded
                          ? Icons.cancel_outlined
                          : Icons.local_shipping_outlined,
                      color: statusColor,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        orderStatusLabel(context, order.status),
                        style: AppTextStyles.h4.copyWith(color: statusColor),
                      ),
                    ),
                    if (order.createdAt != null)
                      Text(
                        Formatters.date(order.createdAt!),
                        style: AppTextStyles.bodySmall,
                      ),
                  ],
                ),
              ),

              // ── Timeline ──
              if (!isCancelledOrRefunded) ...[
                const SizedBox(height: 20),
                _OrderTimeline(
                  statuses: _timelineStatuses,
                  current: order.status,
                ),
              ],

              // ── Items ──
              const SizedBox(height: 24),
              Text(context.tr('orders.items'), style: AppTextStyles.h4),
              const SizedBox(height: 12),
              ...order.items.map(
                (item) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _OrderItemTile(item: item),
                ),
              ),

              // ── Totals ──
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(AppDimensions.radius20),
                ),
                child: Column(
                  children: [
                    _row(
                      context.tr('common.subtotal'),
                      Formatters.price(order.subtotal),
                    ),
                    if (order.discount > 0)
                      _row(
                        context.tr('common.discount'),
                        '- ${Formatters.price(order.discount)}',
                        valueColor: AppColors.success,
                      ),
                    _row(
                      context.tr('common.shipping'),
                      Formatters.price(order.shipping),
                    ),
                    _row(
                      context.tr('common.tax'),
                      Formatters.price(order.tax),
                    ),
                    const Divider(height: 24),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            context.tr('common.total'),
                            style: AppTextStyles.h4,
                          ),
                        ),
                        Text(
                          Formatters.price(order.total),
                          style: AppTextStyles.priceLarge,
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // ── Payment method ──
              if (order.paymentMethod != null) ...[
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius:
                        BorderRadius.circular(AppDimensions.radius16),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.credit_card_rounded,
                        color: AppColors.textSecondary,
                        size: 20,
                      ),
                      const SizedBox(width: 12),
                      Text(
                        context.tr('checkout.${order.paymentMethod}'),
                        style: AppTextStyles.labelLarge,
                      ),
                    ],
                  ),
                ),
              ],

              // ── Cancel ──
              if (order.status.isCancellable) ...[
                const SizedBox(height: 24),
                BellaSecondaryButton(
                  label: context.tr('orders.cancelOrder'),
                  color: AppColors.error,
                  onPressed: () async {
                    final confirmed = await BellaDialog.confirm(
                      context,
                      title: context.tr('orders.cancelOrder'),
                      message: context.tr('orders.cancelConfirm'),
                      confirmLabel: context.tr('common.yes'),
                      cancelLabel: context.tr('common.no'),
                      destructive: true,
                    );
                    if (confirmed != true || !context.mounted) return;
                    try {
                      await ref
                          .read(ordersRemoteDataSourceProvider)
                          .cancel(order.orderNumber);
                      ref.invalidate(orderDetailsProvider(orderNumber));
                      ref.invalidate(ordersListProvider);
                      if (context.mounted) {
                        BellaSnackbar.show(
                          context,
                          context.tr('orders.cancelled'),
                          type: BellaSnackType.success,
                        );
                      }
                    } catch (e) {
                      if (context.mounted) {
                        BellaSnackbar.show(
                          context,
                          context.tr('errors.generic'),
                          type: BellaSnackType.error,
                        );
                      }
                    }
                  },
                ),
              ],
            ],
          );
        },
      ),
    );
  }

  Widget _row(String label, String value, {Color? valueColor}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ),
          Text(
            value,
            style: AppTextStyles.labelLarge.copyWith(color: valueColor),
          ),
        ],
      ),
    );
  }
}

class _OrderTimeline extends StatelessWidget {
  final List<OrderStatus> statuses;
  final OrderStatus current;

  const _OrderTimeline({required this.statuses, required this.current});

  @override
  Widget build(BuildContext context) {
    final currentIndex = statuses.indexOf(current);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppDimensions.radius20),
      ),
      child: Column(
        children: List.generate(statuses.length, (i) {
          final status = statuses[i];
          final reached = i <= currentIndex;
          final isLast = i == statuses.length - 1;
          final color = reached ? AppColors.success : AppColors.divider;

          return IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Column(
                  children: [
                    Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        color: reached ? AppColors.success : AppColors.surface,
                        shape: BoxShape.circle,
                        border: Border.all(color: color, width: 2),
                      ),
                      child: reached
                          ? const Icon(
                              Icons.check_rounded,
                              size: 14,
                              color: Colors.white,
                            )
                          : null,
                    ),
                    if (!isLast)
                      Expanded(
                        child: Container(width: 2, color: color),
                      ),
                  ],
                ),
                const SizedBox(width: 14),
                Padding(
                  padding: EdgeInsets.only(bottom: isLast ? 0 : 24, top: 2),
                  child: Text(
                    orderStatusLabel(context, status),
                    style: AppTextStyles.labelLarge.copyWith(
                      color: reached
                          ? AppColors.textPrimary
                          : AppColors.textTertiary,
                    ),
                  ),
                ),
              ],
            ),
          );
        }),
      ),
    );
  }
}

class _OrderItemTile extends StatelessWidget {
  final OrderItem item;
  const _OrderItemTile({required this.item});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppDimensions.radius16),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(AppDimensions.radius12),
            child: SizedBox(
              width: 64,
              height: 64,
              child: item.imageUrl != null
                  ? CachedNetworkImage(
                      imageUrl: item.imageUrl!,
                      fit: BoxFit.cover,
                      placeholder: (_, __) => const ShimmerBox(radius: 0),
                      errorWidget: (_, __, ___) =>
                          const Icon(Icons.image_outlined),
                    )
                  : Container(
                      color: AppColors.scaffoldOverlay,
                      child: const Icon(
                        Icons.image_outlined,
                        color: AppColors.textTertiary,
                      ),
                    ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.name,
                  style: AppTextStyles.labelMedium,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                if (item.variantName != null)
                  Text(item.variantName!, style: AppTextStyles.bodySmall),
                const SizedBox(height: 4),
                Text(
                  '${item.quantity} × ${Formatters.price(item.unitPrice)}',
                  style: AppTextStyles.bodySmall,
                ),
              ],
            ),
          ),
          Text(
            Formatters.price(item.lineTotal),
            style: AppTextStyles.priceMedium,
          ),
        ],
      ),
    );
  }
}
