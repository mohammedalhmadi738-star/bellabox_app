import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

import 'package:bellabox/core/localization/app_localizations.dart';
import 'package:bellabox/core/routing/route_names.dart';
import 'package:bellabox/core/theme/app_colors.dart';
import 'package:bellabox/core/theme/app_dimensions.dart';
import 'package:bellabox/core/theme/app_text_styles.dart';
import 'package:bellabox/core/utils/formatters.dart';
import 'package:bellabox/features/cart/presentation/providers/cart_provider.dart';
import 'package:bellabox/features/products/domain/entities/product.dart';
import 'package:bellabox/features/products/presentation/providers/product_details_provider.dart';
import 'package:bellabox/features/wishlist/presentation/providers/wishlist_provider.dart';
import 'package:bellabox/shared/widgets/buttons/bella_icon_button.dart';
import 'package:bellabox/shared/widgets/buttons/bella_primary_button.dart';
import 'package:bellabox/shared/widgets/cards/product_card.dart';
import 'package:bellabox/shared/widgets/cards/section_header.dart';
import 'package:bellabox/shared/widgets/dialogs/bella_snackbar.dart';
import 'package:bellabox/shared/widgets/loaders/shimmer_box.dart';
import 'package:bellabox/shared/widgets/states/error_state.dart';

class ProductDetailsPage extends ConsumerStatefulWidget {
  final String slug;
  const ProductDetailsPage({super.key, required this.slug});

  @override
  ConsumerState<ProductDetailsPage> createState() =>
      _ProductDetailsPageState();
}

class _ProductDetailsPageState extends ConsumerState<ProductDetailsPage> {
  final _galleryController = PageController();
  int _quantity = 1;
  ProductVariant? _selectedVariant;
  bool _adding = false;

  @override
  void dispose() {
    _galleryController.dispose();
    super.dispose();
  }

  Future<void> _addToCart(Product product) async {
    setState(() => _adding = true);
    final error = await ref.read(cartProvider.notifier).addItem(
          productId: product.id,
          variantId: _selectedVariant?.id,
          quantity: _quantity,
        );
    if (mounted) {
      setState(() => _adding = false);
      BellaSnackbar.show(
        context,
        error ?? context.tr('product.addedToCart'),
        type: error == null ? BellaSnackType.success : BellaSnackType.error,
      );
    }
  }

  void _openFullscreenGallery(List<String> images, int initialIndex) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (context) => Scaffold(
          backgroundColor: Colors.black,
          appBar: AppBar(
            backgroundColor: Colors.black,
            iconTheme: const IconThemeData(color: Colors.white),
          ),
          body: PhotoViewGallery.builder(
            itemCount: images.length,
            pageController: PageController(initialPage: initialIndex),
            builder: (context, i) => PhotoViewGalleryPageOptions(
              imageProvider: CachedNetworkImageProvider(images[i]),
              minScale: PhotoViewComputedScale.contained,
              maxScale: PhotoViewComputedScale.covered * 3,
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final productAsync = ref.watch(productDetailsProvider(widget.slug));
    final wishlist = ref.watch(wishlistProvider);

    return Scaffold(
      body: productAsync.when(
        loading: () => const _DetailsShimmer(),
        error: (e, _) => SafeArea(
          child: Column(
            children: [
              Align(
                alignment: AlignmentDirectional.topStart,
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: BackButton(onPressed: () => context.pop()),
                ),
              ),
              Expanded(
                child: ErrorStateView(
                  onRetry: () =>
                      ref.invalidate(productDetailsProvider(widget.slug)),
                ),
              ),
            ],
          ),
        ),
        data: (product) {
          final effectiveStock =
              _selectedVariant?.stock ?? product.stock;
          final effectivePrice = _selectedVariant?.salePrice ??
              _selectedVariant?.price ??
              product.effectivePrice;
          final isWishlisted = wishlist.contains(product.id);

          return Column(
            children: [
              Expanded(
                child: CustomScrollView(
                  slivers: [
                    // ── Gallery ──
                    SliverToBoxAdapter(
                      child: Stack(
                        children: [
                          AspectRatio(
                            aspectRatio: 1,
                            child: product.images.isEmpty
                                ? Container(
                                    color: AppColors.scaffoldOverlay,
                                    child: const Icon(
                                      Icons.image_outlined,
                                      size: 64,
                                      color: AppColors.textTertiary,
                                    ),
                                  )
                                : PageView.builder(
                                    controller: _galleryController,
                                    itemCount: product.images.length,
                                    itemBuilder: (context, i) =>
                                        GestureDetector(
                                      onTap: () => _openFullscreenGallery(
                                        product.images,
                                        i,
                                      ),
                                      child: CachedNetworkImage(
                                        imageUrl: product.images[i],
                                        fit: BoxFit.cover,
                                        placeholder: (_, __) =>
                                            const ShimmerBox(radius: 0),
                                        errorWidget: (_, __, ___) =>
                                            const Icon(
                                          Icons.broken_image_outlined,
                                        ),
                                      ),
                                    ),
                                  ),
                          ),
                          // Top bar over gallery
                          Positioned(
                            top: 0,
                            left: 0,
                            right: 0,
                            child: SafeArea(
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 8,
                                ),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    BellaIconButton(
                                      icon: Directionality.of(context) ==
                                              TextDirection.rtl
                                          ? Icons.arrow_forward_rounded
                                          : Icons.arrow_back_rounded,
                                      semanticLabel:
                                          context.tr('common.back'),
                                      onPressed: () => context.pop(),
                                    ),
                                    BellaIconButton(
                                      icon: isWishlisted
                                          ? Icons.favorite_rounded
                                          : Icons.favorite_border_rounded,
                                      iconColor: isWishlisted
                                          ? AppColors.error
                                          : AppColors.primary,
                                      semanticLabel:
                                          context.tr('profile.wishlist'),
                                      onPressed: () => ref
                                          .read(wishlistProvider.notifier)
                                          .toggle(product.id),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          // Page indicator
                          if (product.images.length > 1)
                            Positioned(
                              bottom: 16,
                              left: 0,
                              right: 0,
                              child: Center(
                                child: SmoothPageIndicator(
                                  controller: _galleryController,
                                  count: product.images.length,
                                  effect: const WormEffect(
                                    dotColor: Colors.white54,
                                    activeDotColor: AppColors.secondary,
                                    dotHeight: 8,
                                    dotWidth: 8,
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),

                    // ── Info ──
                    SliverToBoxAdapter(
                      child: Container(
                        decoration: const BoxDecoration(
                          color: AppColors.background,
                          borderRadius: BorderRadius.vertical(
                            top: Radius.circular(AppDimensions.radius24),
                          ),
                        ),
                        transform: Matrix4.translationValues(0, -20, 0),
                        padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (product.brandName != null)
                              Text(
                                product.brandName!.toUpperCase(),
                                style: AppTextStyles.labelSmall.copyWith(
                                  color: AppColors.secondary,
                                  letterSpacing: 2,
                                ),
                              ),
                            const SizedBox(height: 6),
                            Text(product.name, style: AppTextStyles.h2),
                            const SizedBox(height: 12),
                            // Rating + stock
                            Row(
                              children: [
                                if (product.ratingCount > 0) ...[
                                  const Icon(
                                    Icons.star_rounded,
                                    color: AppColors.ratingActive,
                                    size: 20,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    product.ratingAvg.toStringAsFixed(1),
                                    style: AppTextStyles.labelLarge,
                                  ),
                                  Text(
                                    ' (${product.ratingCount})',
                                    style: AppTextStyles.bodySmall,
                                  ),
                                  const SizedBox(width: 16),
                                ],
                                _StockBadge(
                                  stock: effectiveStock,
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            // Price
                            Wrap(
                              crossAxisAlignment: WrapCrossAlignment.center,
                              spacing: 10,
                              runSpacing: 6,
                              children: [
                                Text(
                                  Formatters.price(effectivePrice),
                                  style: AppTextStyles.priceLarge,
                                ),
                                if (product.hasDiscount &&
                                    _selectedVariant == null) ...[
                                  Text(
                                    Formatters.price(product.price),
                                    style: AppTextStyles.priceOld,
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 3,
                                    ),
                                    decoration: BoxDecoration(
                                      color: AppColors.error
                                          .withValues(alpha: 0.1),
                                      borderRadius: BorderRadius.circular(
                                        AppDimensions.radiusPill,
                                      ),
                                    ),
                                    child: Text(
                                      '-${Formatters.discountPercentage(product.price, product.salePrice!)}',
                                      style: AppTextStyles.labelSmall
                                          .copyWith(color: AppColors.error),
                                    ),
                                  ),
                                ],
                              ],
                            ),

                            // ── Variants ──
                            if (product.variants.isNotEmpty) ...[
                              const SizedBox(height: 20),
                              Wrap(
                                spacing: 10,
                                runSpacing: 10,
                                children: product.variants.map((v) {
                                  final selected =
                                      _selectedVariant?.id == v.id;
                                  return ChoiceChip(
                                    label: Text(v.name),
                                    selected: selected,
                                    onSelected: v.inStock
                                        ? (sel) => setState(() =>
                                            _selectedVariant =
                                                sel ? v : null)
                                        : null,
                                  );
                                }).toList(),
                              ),
                            ],

                            // ── Expandable sections ──
                            const SizedBox(height: 20),
                            if (product.description != null &&
                                product.description!.isNotEmpty)
                              _ExpandableSection(
                                title: context.tr('product.description'),
                                content: product.description!,
                                initiallyExpanded: true,
                              ),
                            if (product.ingredients != null &&
                                product.ingredients!.isNotEmpty)
                              _ExpandableSection(
                                title: context.tr('product.ingredients'),
                                content: product.ingredients!,
                              ),
                            if (product.howToUse != null &&
                                product.howToUse!.isNotEmpty)
                              _ExpandableSection(
                                title: context.tr('product.howToUse'),
                                content: product.howToUse!,
                              ),

                            // ── Reviews placeholder ──
                            const SizedBox(height: 8),
                            _ExpandableSection(
                              title: context.tr('product.reviews'),
                              content: context.tr('product.reviewsSoon'),
                            ),
                          ],
                        ),
                      ),
                    ),

                    // ── Related products ──
                    SliverToBoxAdapter(
                      child: _RelatedProducts(productId: product.id),
                    ),
                    const SliverToBoxAdapter(child: SizedBox(height: 24)),
                  ],
                ),
              ),

              // ── Bottom bar: quantity + add to cart ──
              _BottomBar(
                quantity: _quantity,
                inStock: effectiveStock > 0,
                adding: _adding,
                onQuantityChanged: (q) => setState(() => _quantity = q),
                maxQuantity: effectiveStock,
                onAddToCart: () => _addToCart(product),
              ),
            ],
          );
        },
      ),
    );
  }
}

// ─────────────────────────────────────────────

class _StockBadge extends StatelessWidget {
  final int stock;
  const _StockBadge({required this.stock});

  @override
  Widget build(BuildContext context) {
    final (label, color) = stock <= 0
        ? (context.tr('product.outOfStock'), AppColors.error)
        : stock <= 5
            ? (context.tr('product.lowStock'), AppColors.warning)
            : (context.tr('product.inStock'), AppColors.success);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppDimensions.radiusPill),
      ),
      child: Text(
        label,
        style: AppTextStyles.labelSmall.copyWith(color: color),
      ),
    );
  }
}

class _ExpandableSection extends StatelessWidget {
  final String title;
  final String content;
  final bool initiallyExpanded;

  const _ExpandableSection({
    required this.title,
    required this.content,
    this.initiallyExpanded = false,
  });

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
      child: ExpansionTile(
        tilePadding: EdgeInsets.zero,
        childrenPadding: const EdgeInsets.only(bottom: 16),
        initiallyExpanded: initiallyExpanded,
        title: Text(title, style: AppTextStyles.h4),
        iconColor: AppColors.primary,
        collapsedIconColor: AppColors.textSecondary,
        children: [
          Align(
            alignment: AlignmentDirectional.centerStart,
            child: Text(
              content,
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textSecondary,
                height: 1.7,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _RelatedProducts extends ConsumerWidget {
  final int productId;
  const _RelatedProducts({required this.productId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final related = ref.watch(relatedProductsProvider(productId));
    return related.when(
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
      data: (products) {
        if (products.isEmpty) return const SizedBox.shrink();
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SectionHeader(title: context.tr('product.related')),
            SizedBox(
              height: 290,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                itemCount: products.length,
                separatorBuilder: (_, __) => const SizedBox(width: 14),
                itemBuilder: (context, i) {
                  final p = products[i];
                  return SizedBox(
                    width: 175,
                    child: ProductCard(
                      product: p.toCardData(),
                      onTap: () => context.push(
                        '${RouteNames.productDetails}/${p.slug}',
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }
}

class _BottomBar extends StatelessWidget {
  final int quantity;
  final int maxQuantity;
  final bool inStock;
  final bool adding;
  final ValueChanged<int> onQuantityChanged;
  final VoidCallback onAddToCart;

  const _BottomBar({
    required this.quantity,
    required this.maxQuantity,
    required this.inStock,
    required this.adding,
    required this.onQuantityChanged,
    required this.onAddToCart,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
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
        child: Row(
          children: [
            // Quantity stepper
            Container(
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius:
                    BorderRadius.circular(AppDimensions.radiusPill),
              ),
              child: Row(
                children: [
                  IconButton(
                    onPressed: quantity > 1
                        ? () => onQuantityChanged(quantity - 1)
                        : null,
                    icon: const Icon(Icons.remove_rounded, size: 20),
                    constraints: const BoxConstraints(
                      minWidth: AppDimensions.minTouchTarget,
                      minHeight: AppDimensions.minTouchTarget,
                    ),
                  ),
                  Text('$quantity', style: AppTextStyles.h4),
                  IconButton(
                    onPressed: quantity < maxQuantity
                        ? () => onQuantityChanged(quantity + 1)
                        : null,
                    icon: const Icon(Icons.add_rounded, size: 20),
                    constraints: const BoxConstraints(
                      minWidth: AppDimensions.minTouchTarget,
                      minHeight: AppDimensions.minTouchTarget,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: BellaPrimaryButton(
                label: inStock
                    ? context.tr('product.addToCart')
                    : context.tr('product.outOfStock'),
                loading: adding,
                icon: Icons.shopping_bag_outlined,
                onPressed: inStock ? onAddToCart : null,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DetailsShimmer extends StatelessWidget {
  const _DetailsShimmer();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          AspectRatio(aspectRatio: 1, child: ShimmerBox(radius: 0)),
          Padding(
            padding: EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ShimmerLine(width: 80, height: 12),
                SizedBox(height: 12),
                ShimmerLine(width: 220, height: 20),
                SizedBox(height: 16),
                ShimmerLine(width: 120, height: 16),
                SizedBox(height: 24),
                ShimmerBox(width: double.infinity, height: 80),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
