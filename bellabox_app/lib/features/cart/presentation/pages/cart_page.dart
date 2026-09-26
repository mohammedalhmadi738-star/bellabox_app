import 'package:cached_network_image/cached_network_image.dart';
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
import 'package:bellabox/features/cart/domain/entities/cart.dart';
import 'package:bellabox/features/cart/presentation/providers/cart_provider.dart';
import 'package:bellabox/shared/widgets/buttons/bella_primary_button.dart';
import 'package:bellabox/shared/widgets/dialogs/bella_snackbar.dart';
import 'package:bellabox/shared/widgets/loaders/shimmer_box.dart';
import 'package:bellabox/shared/widgets/states/empty_state.dart';
import 'package:bellabox/shared/widgets/states/error_state.dart';

class CartPage extends ConsumerStatefulWidget {
  const CartPage({super.key});

  @override
  ConsumerState<CartPage> createState() => _CartPageState();
}

class _CartPageState extends ConsumerState<CartPage> {
  final _couponController = TextEditingController();
  bool _applyingCoupon = false;

  @override
  void dispose() {
    _couponController.dispose();
    super.dispose();
  }

  Future<void> _applyCoupon() async {
    final code = _couponController.text.trim();
    if (code.isEmpty) return;
    setState(() => _applyingCoupon = true);
    final error = await ref.read(cartProvider.notifier).applyCoupon(code);
    if (mounted) {
      setState(() => _applyingCoupon = false);
      if (error != null) {
        BellaSnackbar.show(context, error, type: BellaSnackType.error);
      } else {
        _couponController.clear();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final cartAsync = ref.watch(cartProvider);
    final isAuth = ref.watch(isAuthenticatedProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(context.tr('cart.title')),
        automaticallyImplyLeading: false,
      ),
      body: cartAsync.when(
        loading: () => ListView.separated(
          padding: const EdgeInsets.all(20),
          itemCount: 3,
          separatorBuilder: (_, __) => const SizedBox(height: 14),
          itemBuilder: (_, __) =>
              const ShimmerBox(height: 110, radius: AppDimensions.radius20),
        ),
        error: (e, _) => ErrorStateView(
          onRetry: () => ref.read(cartProvider.notifier).refresh(),
        ),
        data: (cart) {
          if (cart.isEmpty) {
            return EmptyState(
              icon: Icons.shopping_bag_outlined,
              title: context.tr('cart.empty'),
              body: context.tr('cart.emptyHint'),
              actionLabel: context.tr('cart.shopNow'),
              onAction: () => context.go(RouteNames.home),
            );
          }
          return Column(
            children: [
              Expanded(
                child: RefreshIndicator(
                  color: AppColors.primary,
                  onRefresh: () => ref.read(cartProvider.notifier).refresh(),
                  child: ListView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
                    children: [
                      ...cart.items.map(
                        (item) => Padding(
                          padding: const EdgeInsets.only(bottom: 14),
                          child: _CartItemTile(item: item),
                        ),
                      ),
                      const SizedBox(height: 8),
                      // ── Coupon ──
                      _CouponField(
                        controller: _couponController,
                        applying: _applyingCoupon,
                        appliedCode: cart.couponCode,
                        onApply: _applyCoupon,
                        onRemove: () async {
                          final err = await ref
                              .read(cartProvider.notifier)
                              .removeCoupon();
                          if (err != null && context.mounted) {
                            BellaSnackbar.show(
                              context,
                              err,
                              type: BellaSnackType.error,
                            );
                          }
                        },
                      ),
                      const SizedBox(height: 16),
                      // ── Totals ──
                      _TotalsCard(cart: cart),
                    ],
                  ),
                ),
              ),
              // ── Checkout button ──
              Container(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
                decoration: const BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.vertical(
                    top: Radius.circular(AppDimensions.radius24),
                  ),
                  boxShadow: AppDimensions.shadowLg,
                ),
                child: SafeArea(
                  top: false,
                  child: BellaPrimaryButton(
                    label:
                        '${context.tr('cart.proceedToCheckout')} • ${Formatters.price(cart.total)}',
                    onPressed: () {
                      if (!isAuth) {
                        // Checkout requires auth per API contract
                        context.push(RouteNames.login);
                        return;
                      }
                      context.push(RouteNames.checkout);
                    },
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

// ─────────────────────────────────────────────

class _CartItemTile extends ConsumerWidget {
  final CartItem item;
  const _CartItemTile({required this.item});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Dismissible(
      key: ValueKey('cart_item_${item.id}'),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: AlignmentDirectional.centerEnd,
        padding: const EdgeInsetsDirectional.only(end: 24),
        decoration: BoxDecoration(
          color: AppColors.error,
          borderRadius: BorderRadius.circular(AppDimensions.radius20),
        ),
        child: const Icon(Icons.delete_outline_rounded, color: Colors.white),
      ),
      onDismissed: (_) async {
        final err = await ref.read(cartProvider.notifier).removeItem(item.id);
        if (err != null && context.mounted) {
          BellaSnackbar.show(context, err, type: BellaSnackType.error);
        }
      },
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppDimensions.radius20),
        ),
        child: Row(
          children: [
            // Image
            ClipRRect(
              borderRadius: BorderRadius.circular(AppDimensions.radius16),
              child: SizedBox(
                width: 84,
                height: 84,
                child: item.imageUrl != null
                    ? CachedNetworkImage(
                        imageUrl: item.imageUrl!,
                        fit: BoxFit.cover,
                        placeholder: (_, __) => const ShimmerBox(radius: 0),
                        errorWidget: (_, __, ___) => Container(
                          color: AppColors.scaffoldOverlay,
                          child: const Icon(Icons.image_outlined),
                        ),
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
            const SizedBox(width: 14),
            // Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.name,
                    style: AppTextStyles.labelLarge,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    Formatters.price(item.unitPrice),
                    style: AppTextStyles.priceMedium,
                  ),
                  const SizedBox(height: 10),
                  // Quantity stepper
                  Row(
                    children: [
                      _QtyButton(
                        icon: Icons.remove_rounded,
                        onTap: () => ref
                            .read(cartProvider.notifier)
                            .updateQuantity(item.id, item.quantity - 1),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 14),
                        child: Text(
                          '${item.quantity}',
                          style: AppTextStyles.labelLarge,
                        ),
                      ),
                      _QtyButton(
                        icon: Icons.add_rounded,
                        onTap: () => ref
                            .read(cartProvider.notifier)
                            .updateQuantity(item.id, item.quantity + 1),
                      ),
                      const Spacer(),
                      Text(
                        Formatters.price(item.lineTotal),
                        style: AppTextStyles.labelLarge.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _QtyButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _QtyButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.background,
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: SizedBox(
          width: 40,
          height: 40,
          child: Icon(icon, size: 16, color: AppColors.primary),
        ),
      ),
    );
  }
}

class _CouponField extends StatelessWidget {
  final TextEditingController controller;
  final bool applying;
  final String? appliedCode;
  final VoidCallback onApply;
  final VoidCallback onRemove;

  const _CouponField({
    required this.controller,
    required this.applying,
    required this.appliedCode,
    required this.onApply,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    if (appliedCode != null) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: AppColors.success.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(AppDimensions.radius16),
          border: Border.all(
            color: AppColors.success.withValues(alpha: 0.3),
          ),
        ),
        child: Row(
          children: [
            const Icon(
              Icons.local_offer_rounded,
              color: AppColors.success,
              size: 18,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                appliedCode!,
                style: AppTextStyles.labelLarge.copyWith(
                  color: AppColors.success,
                ),
              ),
            ),
            TextButton(
              onPressed: onRemove,
              child: Text(
                context.tr('cart.removeCoupon'),
                style: AppTextStyles.labelMedium.copyWith(
                  color: AppColors.error,
                ),
              ),
            ),
          ],
        ),
      );
    }

    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: controller,
            style: AppTextStyles.bodyMedium,
            decoration: InputDecoration(
              hintText: context.tr('cart.couponHint'),
              prefixIcon: const Icon(
                Icons.local_offer_outlined,
                size: 18,
                color: AppColors.textTertiary,
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 14,
              ),
            ),
          ),
        ),
        const SizedBox(width: 10),
        SizedBox(
          height: 50,
          child: BellaPrimaryButton(
            label: context.tr('cart.applyCoupon'),
            loading: applying,
            expanded: false,
            height: 50,
            onPressed: onApply,
          ),
        ),
      ],
    );
  }
}

class _TotalsCard extends StatelessWidget {
  final Cart cart;
  const _TotalsCard({required this.cart});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppDimensions.radius20),
      ),
      child: Column(
        children: [
          _row(context.tr('common.subtotal'), Formatters.price(cart.subtotal)),
          if (cart.discount > 0)
            _row(
              context.tr('common.discount'),
              '- ${Formatters.price(cart.discount)}',
              valueColor: AppColors.success,
            ),
          _row(
            context.tr('common.shipping'),
            cart.shipping == 0
                ? context.tr('common.free')
                : Formatters.price(cart.shipping),
            valueColor: cart.shipping == 0 ? AppColors.success : null,
          ),
          _row(context.tr('common.tax'), Formatters.price(cart.tax)),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 12),
            child: Divider(),
          ),
          Row(
            children: [
              Expanded(
                child: Text(
                  context.tr('common.total'),
                  style: AppTextStyles.h4,
                ),
              ),
              Text(
                Formatters.price(cart.total),
                style: AppTextStyles.priceLarge,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _row(String label, String value, {Color? valueColor}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
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
