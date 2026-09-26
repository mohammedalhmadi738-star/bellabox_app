import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import 'package:bellabox/core/localization/app_localizations.dart';
import 'package:bellabox/core/theme/app_colors.dart';
import 'package:bellabox/core/theme/app_dimensions.dart';
import 'package:bellabox/core/theme/app_text_styles.dart';
import 'package:bellabox/core/utils/formatters.dart';
import 'package:bellabox/shared/widgets/loaders/shimmer_box.dart';

class ProductCardData {
  final int id;
  final String slug;
  final String name;
  final String? brand;
  final String? imageUrl;
  final double price;
  final double? salePrice;
  final double? rating;
  final int? reviewCount;
  final bool inStock;

  const ProductCardData({
    required this.id,
    required this.slug,
    required this.name,
    this.brand,
    this.imageUrl,
    required this.price,
    this.salePrice,
    this.rating,
    this.reviewCount,
    this.inStock = true,
  });
}

class ProductCard extends StatelessWidget {
  final ProductCardData product;
  final VoidCallback? onTap;
  final VoidCallback? onWishlistTap;
  final VoidCallback? onAddToCart;
  final bool isWishlisted;

  const ProductCard({
    super.key,
    required this.product,
    this.onTap,
    this.onWishlistTap,
    this.onAddToCart,
    this.isWishlisted = false,
  });

  @override
  Widget build(BuildContext context) {
    final hasDiscount = product.salePrice != null && product.salePrice! < product.price;
    return RepaintBoundary(
      child: Semantics(
        button: true,
        label: product.name,
        child: Material(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppDimensions.radius20),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: onTap,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Image
                AspectRatio(
                  aspectRatio: 1,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      Container(
                        color: AppColors.scaffoldOverlay,
                        child: product.imageUrl == null
                            ? const Icon(
                                Icons.image_outlined,
                                color: AppColors.textTertiary,
                                size: 40,
                              )
                            : CachedNetworkImage(
                                imageUrl: product.imageUrl!,
                                fit: BoxFit.cover,
                                placeholder: (_, __) =>
                                    const ShimmerBox(radius: 0),
                                errorWidget: (_, __, ___) => const Icon(
                                  Icons.image_not_supported_outlined,
                                  color: AppColors.textTertiary,
                                ),
                              ),
                      ),
                      // Discount badge
                      if (hasDiscount)
                        Positioned(
                          top: 10,
                          right: 10,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.error,
                              borderRadius: BorderRadius.circular(
                                AppDimensions.radiusPill,
                              ),
                            ),
                            child: Text(
                              '-${Formatters.discountPercentage(product.price, product.salePrice!)}',
                              style: AppTextStyles.labelSmall.copyWith(
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      // Wishlist button
                      Positioned(
                        top: 10,
                        left: 10,
                        child: Material(
                          color: AppColors.surface,
                          shape: const CircleBorder(),
                          child: InkWell(
                            customBorder: const CircleBorder(),
                            onTap: onWishlistTap,
                            child: Padding(
                              padding: const EdgeInsets.all(6),
                              child: Icon(
                                isWishlisted
                                    ? Icons.favorite_rounded
                                    : Icons.favorite_border_rounded,
                                size: 18,
                                color: isWishlisted
                                    ? AppColors.error
                                    : AppColors.textSecondary,
                              ),
                            ),
                          ),
                        ),
                      ),
                      // Out of stock overlay
                      if (!product.inStock)
                        Positioned.fill(
                          child: Container(
                            color: Colors.white.withValues(alpha: 0.7),
                            alignment: Alignment.center,
                            child: Text(
                              context.tr('product.outOfStock'),
                              style: AppTextStyles.labelMedium
                                  .copyWith(color: AppColors.error),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                // Content
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (product.brand != null) ...[
                        Text(
                          product.brand!,
                          style: AppTextStyles.labelSmall.copyWith(
                            color: AppColors.textSecondary,
                            letterSpacing: 1,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                      ],
                      Text(
                        product.name,
                        style: AppTextStyles.labelLarge,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 8),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.baseline,
                        textBaseline: TextBaseline.alphabetic,
                        children: [
                          Text(
                            Formatters.price(product.salePrice ?? product.price),
                            style: AppTextStyles.priceMedium,
                          ),
                          if (hasDiscount) ...[
                            const SizedBox(width: 6),
                            Flexible(
                              child: Text(
                                Formatters.price(product.price),
                                style: AppTextStyles.priceOld,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ],
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

class ProductCardShimmer extends StatelessWidget {
  const ProductCardShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppDimensions.radius20),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const AspectRatio(aspectRatio: 1, child: ShimmerBox(radius: 0)),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                ShimmerLine(width: 60, height: 10),
                SizedBox(height: 8),
                ShimmerLine(width: 140, height: 14),
                SizedBox(height: 6),
                ShimmerLine(width: 80, height: 14),
                SizedBox(height: 10),
                ShimmerLine(width: 60, height: 16),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
