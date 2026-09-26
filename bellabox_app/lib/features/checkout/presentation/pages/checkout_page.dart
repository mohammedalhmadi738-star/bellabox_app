import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:bellabox/core/localization/app_localizations.dart';
import 'package:bellabox/core/routing/route_names.dart';
import 'package:bellabox/core/theme/app_colors.dart';
import 'package:bellabox/core/theme/app_dimensions.dart';
import 'package:bellabox/core/theme/app_text_styles.dart';
import 'package:bellabox/core/utils/formatters.dart';
import 'package:bellabox/features/cart/presentation/providers/cart_provider.dart';
import 'package:bellabox/features/checkout/data/datasources/checkout_remote_datasource.dart';
import 'package:bellabox/features/checkout/presentation/providers/checkout_provider.dart';
import 'package:bellabox/shared/widgets/buttons/bella_primary_button.dart';
import 'package:bellabox/shared/widgets/dialogs/bella_snackbar.dart';
import 'package:bellabox/shared/widgets/loaders/shimmer_box.dart';

class CheckoutPage extends ConsumerWidget {
  const CheckoutPage({super.key});

  static const _paymentMethods = [
    ('moyasar', 'checkout.moyasar', Icons.credit_card_rounded),
    ('tabby', 'checkout.tabby', Icons.splitscreen_rounded),
    ('tamara', 'checkout.tamara', Icons.calendar_month_rounded),
    ('cod', 'checkout.cod', Icons.payments_rounded),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final checkout = ref.watch(checkoutProvider);
    final cart = ref.watch(cartProvider).valueOrNull;
    final addresses = ref.watch(addressesProvider);
    final shippingMethods = ref.watch(shippingMethodsProvider);

    return Scaffold(
      appBar: AppBar(title: Text(context.tr('checkout.title'))),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(20),
              children: [
                // ── Address ──
                Text(context.tr('checkout.address'), style: AppTextStyles.h4),
                const SizedBox(height: 12),
                addresses.when(
                  loading: () => const ShimmerBox(height: 80),
                  error: (_, __) => _RetryTile(
                    onRetry: () => ref.invalidate(addressesProvider),
                  ),
                  data: (list) {
                    if (list.isEmpty) {
                      return _AddAddressTile(
                        onTap: () => _showAddAddressSheet(context, ref),
                      );
                    }
                    // Auto-select default address once
                    if (checkout.selectedAddress == null) {
                      final def = list.firstWhere(
                        (a) => a.isDefault,
                        orElse: () => list.first,
                      );
                      Future.microtask(() =>
                          ref.read(checkoutProvider.notifier).selectAddress(def));
                    }
                    return Column(
                      children: [
                        ...list.map(
                          (a) => _AddressTile(
                            address: a,
                            selected: checkout.selectedAddress?.id == a.id,
                            onTap: () => ref
                                .read(checkoutProvider.notifier)
                                .selectAddress(a),
                          ),
                        ),
                        _AddAddressTile(
                          onTap: () => _showAddAddressSheet(context, ref),
                        ),
                      ],
                    );
                  },
                ),

                const SizedBox(height: 24),

                // ── Shipping method ──
                Text(context.tr('common.shipping'), style: AppTextStyles.h4),
                const SizedBox(height: 12),
                shippingMethods.when(
                  loading: () => const ShimmerBox(height: 64),
                  error: (_, __) => _RetryTile(
                    onRetry: () => ref.invalidate(shippingMethodsProvider),
                  ),
                  data: (methods) {
                    if (methods.isEmpty) return const SizedBox.shrink();
                    if (checkout.selectedShipping == null) {
                      Future.microtask(() => ref
                          .read(checkoutProvider.notifier)
                          .selectShipping(methods.first));
                    }
                    return Column(
                      children: methods
                          .map(
                            (m) => _ShippingTile(
                              method: m,
                              selected:
                                  checkout.selectedShipping?.id == m.id,
                              onTap: () => ref
                                  .read(checkoutProvider.notifier)
                                  .selectShipping(m),
                            ),
                          )
                          .toList(),
                    );
                  },
                ),

                const SizedBox(height: 24),

                // ── Payment method ──
                Text(
                  context.tr('checkout.paymentMethod'),
                  style: AppTextStyles.h4,
                ),
                const SizedBox(height: 12),
                ..._paymentMethods.map(
                  (m) => _PaymentTile(
                    id: m.$1,
                    labelKey: m.$2,
                    icon: m.$3,
                    selected: checkout.paymentMethod == m.$1,
                    onTap: () =>
                        ref.read(checkoutProvider.notifier).selectPayment(m.$1),
                  ),
                ),

                const SizedBox(height: 24),

                // ── Order summary ──
                if (cart != null) ...[
                  Text(
                    context.tr('checkout.orderSummary'),
                    style: AppTextStyles.h4,
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius:
                          BorderRadius.circular(AppDimensions.radius20),
                    ),
                    child: Column(
                      children: [
                        _summaryRow(
                          context.tr('common.subtotal'),
                          Formatters.price(cart.subtotal),
                        ),
                        if (cart.discount > 0)
                          _summaryRow(
                            context.tr('common.discount'),
                            '- ${Formatters.price(cart.discount)}',
                          ),
                        _summaryRow(
                          context.tr('common.shipping'),
                          Formatters.price(
                            checkout.selectedShipping?.cost ?? cart.shipping,
                          ),
                        ),
                        _summaryRow(
                          context.tr('common.tax'),
                          Formatters.price(cart.tax),
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
                              Formatters.price(cart.total),
                              style: AppTextStyles.priceLarge,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],

                const SizedBox(height: 16),

                // ── Terms ──
                CheckboxListTile(
                  value: checkout.termsAccepted,
                  onChanged: (v) => ref
                      .read(checkoutProvider.notifier)
                      .toggleTerms(v ?? false),
                  controlAffinity: ListTileControlAffinity.leading,
                  contentPadding: EdgeInsets.zero,
                  activeColor: AppColors.primary,
                  title: Text(
                    context.tr('checkout.termsAgree'),
                    style: AppTextStyles.bodyMedium,
                  ),
                ),
                const SizedBox(height: 80),
              ],
            ),
          ),

          // ── Place order ──
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
                label: checkout.placing
                    ? context.tr('checkout.placing')
                    : context.tr('checkout.placeOrder'),
                loading: checkout.placing,
                onPressed: checkout.canPlaceOrder
                    ? () async {
                        final order = await ref
                            .read(checkoutProvider.notifier)
                            .placeOrder();
                        if (!context.mounted) return;
                        if (order == null) {
                          final err =
                              ref.read(checkoutProvider).error;
                          BellaSnackbar.show(
                            context,
                            err ?? context.tr('errors.generic'),
                            type: BellaSnackType.error,
                          );
                          return;
                        }
                        if (order.paymentMethod == 'cod') {
                          context.go(
                            '${RouteNames.paymentSuccess}?order=${order.orderNumber}',
                          );
                        } else {
                          context.go(
                            '${RouteNames.paymentPending}?orderId=${order.id}&order=${order.orderNumber}&gateway=${order.paymentMethod}',
                          );
                        }
                      }
                    : null,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _summaryRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: AppTextStyles.bodyMedium
                  .copyWith(color: AppColors.textSecondary),
            ),
          ),
          Text(value, style: AppTextStyles.labelLarge),
        ],
      ),
    );
  }

  void _showAddAddressSheet(BuildContext context, WidgetRef ref) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (context) => const _AddAddressSheet(),
    );
  }
}

// ─────────────────────────────────────────────

class _AddressTile extends StatelessWidget {
  final Address address;
  final bool selected;
  final VoidCallback onTap;

  const _AddressTile({
    required this.address,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Material(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppDimensions.radius16),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppDimensions.radius16),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(AppDimensions.radius16),
              border: Border.all(
                color: selected ? AppColors.primary : AppColors.divider,
                width: selected ? 1.5 : 1,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  selected
                      ? Icons.radio_button_checked_rounded
                      : Icons.radio_button_off_rounded,
                  color: selected ? AppColors.primary : AppColors.textTertiary,
                  size: 20,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(address.label, style: AppTextStyles.labelLarge),
                      const SizedBox(height: 4),
                      Text(
                        address.summary,
                        style: AppTextStyles.bodySmall,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _AddAddressTile extends StatelessWidget {
  final VoidCallback onTap;
  const _AddAddressTile({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppDimensions.radius16),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppDimensions.radius16),
            border: Border.all(color: AppColors.secondary),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.add_location_alt_outlined,
                color: AppColors.primary,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                context.tr('checkout.addAddress'),
                style: AppTextStyles.labelLarge,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ShippingTile extends StatelessWidget {
  final ShippingMethod method;
  final bool selected;
  final VoidCallback onTap;

  const _ShippingTile({
    required this.method,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final eta = method.estimatedDaysMin != null
        ? '${method.estimatedDaysMin}-${method.estimatedDaysMax ?? method.estimatedDaysMin} أيام'
        : null;
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Material(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppDimensions.radius16),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppDimensions.radius16),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(AppDimensions.radius16),
              border: Border.all(
                color: selected ? AppColors.primary : AppColors.divider,
                width: selected ? 1.5 : 1,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  selected
                      ? Icons.radio_button_checked_rounded
                      : Icons.radio_button_off_rounded,
                  color: selected ? AppColors.primary : AppColors.textTertiary,
                  size: 20,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(method.name, style: AppTextStyles.labelLarge),
                      if (eta != null)
                        Text(eta, style: AppTextStyles.bodySmall),
                    ],
                  ),
                ),
                Text(
                  method.cost == 0
                      ? context.tr('common.free')
                      : Formatters.price(method.cost),
                  style: AppTextStyles.labelLarge.copyWith(
                    color: method.cost == 0 ? AppColors.success : null,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _PaymentTile extends StatelessWidget {
  final String id;
  final String labelKey;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  const _PaymentTile({
    required this.id,
    required this.labelKey,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Material(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppDimensions.radius16),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppDimensions.radius16),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(AppDimensions.radius16),
              border: Border.all(
                color: selected ? AppColors.primary : AppColors.divider,
                width: selected ? 1.5 : 1,
              ),
            ),
            child: Row(
              children: [
                Icon(icon, color: AppColors.primary, size: 22),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    context.tr(labelKey),
                    style: AppTextStyles.labelLarge,
                  ),
                ),
                Icon(
                  selected
                      ? Icons.radio_button_checked_rounded
                      : Icons.radio_button_off_rounded,
                  color: selected ? AppColors.primary : AppColors.textTertiary,
                  size: 20,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _RetryTile extends StatelessWidget {
  final VoidCallback onRetry;
  const _RetryTile({required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return TextButton.icon(
      onPressed: onRetry,
      icon: const Icon(Icons.refresh_rounded, size: 18),
      label: Text(context.tr('common.retry')),
    );
  }
}

// ── Add address sheet ──

class _AddAddressSheet extends ConsumerStatefulWidget {
  const _AddAddressSheet();

  @override
  ConsumerState<_AddAddressSheet> createState() => _AddAddressSheetState();
}

class _AddAddressSheetState extends ConsumerState<_AddAddressSheet> {
  final _label = TextEditingController(text: 'المنزل');
  final _name = TextEditingController();
  final _phone = TextEditingController();
  final _city = TextEditingController();
  final _district = TextEditingController();
  final _street = TextEditingController();
  bool _saving = false;

  @override
  void dispose() {
    for (final c in [_label, _name, _phone, _city, _district, _street]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _save() async {
    if (_name.text.isEmpty || _city.text.isEmpty || _street.text.isEmpty) {
      BellaSnackbar.show(
        context,
        context.tr('errors.validation'),
        type: BellaSnackType.error,
      );
      return;
    }
    setState(() => _saving = true);
    try {
      await ref.read(checkoutRemoteDataSourceProvider).createAddress({
        'label': _label.text,
        'recipient_name': _name.text,
        'phone': _phone.text,
        'country': 'SA',
        'city': _city.text,
        'district': _district.text,
        'street': _street.text,
        'is_default': true,
      });
      ref.invalidate(addressesProvider);
      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (mounted) {
        BellaSnackbar.show(
          context,
          context.tr('errors.generic'),
          type: BellaSnackType.error,
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 24,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(context.tr('checkout.addAddress'), style: AppTextStyles.h3),
            const SizedBox(height: 20),
            _field(_label, 'العنوان (المنزل، العمل...)'),
            _field(_name, 'اسم المستلم'),
            _field(_phone, 'رقم الجوال', keyboard: TextInputType.phone),
            _field(_city, 'المدينة'),
            _field(_district, 'الحي'),
            _field(_street, 'الشارع'),
            const SizedBox(height: 8),
            BellaPrimaryButton(
              label: context.tr('common.save'),
              loading: _saving,
              onPressed: _save,
            ),
          ],
        ),
      ),
    );
  }

  Widget _field(
    TextEditingController controller,
    String hint, {
    TextInputType keyboard = TextInputType.text,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextField(
        controller: controller,
        keyboardType: keyboard,
        style: AppTextStyles.bodyMedium,
        decoration: InputDecoration(hintText: hint),
      ),
    );
  }
}
