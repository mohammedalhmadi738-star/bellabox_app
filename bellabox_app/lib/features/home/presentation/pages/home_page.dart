import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:bellabox/core/localization/app_localizations.dart';
import 'package:bellabox/core/routing/route_names.dart';
import 'package:bellabox/core/theme/app_colors.dart';
import 'package:bellabox/core/theme/app_dimensions.dart';
import 'package:bellabox/core/theme/app_text_styles.dart';
import 'package:bellabox/features/auth/presentation/providers/auth_session_provider.dart';
import 'package:bellabox/features/cart/presentation/providers/cart_provider.dart';
import 'package:bellabox/features/home/presentation/providers/home_providers.dart';
import 'package:bellabox/features/products/domain/entities/product.dart' as domain;
import 'package:bellabox/features/wishlist/presentation/providers/wishlist_provider.dart';
import 'package:bellabox/shared/widgets/buttons/bella_icon_button.dart';
import 'package:bellabox/shared/widgets/cards/product_card.dart';
import 'package:bellabox/shared/widgets/cards/section_header.dart';
import 'package:bellabox/shared/widgets/dialogs/bella_snackbar.dart';
import 'package:bellabox/shared/widgets/loaders/shimmer_box.dart';

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);
    final cartCount = ref.watch(cartItemCountProvider);

    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: RefreshIndicator(
          color: AppColors.primary,
          onRefresh: () async {
            ref.invalidate(bannersProvider);
            ref.invalidate(homeCategoriesProvider);
            ref.invalidate(featuredProductsProvider);
            ref.invalidate(newArrivalsProvider);
            ref.invalidate(bestSellersProvider);
          },
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              // ── Header ──
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 12, 20, 4),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              user != null
                                  ? '${context.tr('home.hello')}, ${user.name.split(' ').first} 👋'
                                  : context.tr('home.hello'),
                              style: AppTextStyles.h2,
                            ),
                            Text(
                              'Bella Box',
                              style: AppTextStyles.labelSmall.copyWith(
                                color: AppColors.secondary,
                                letterSpacing: 2,
                              ),
                            ),
                          ],
                        ),
                      ),
                      BellaIconButton(
                        icon: Icons.notifications_none_rounded,
                        semanticLabel: context.tr('profile.notifications'),
                        onPressed: () =>
                            context.push(RouteNames.notifications),
                      ),
                      const SizedBox(width: 10),
                      BellaIconButton(
                        icon: Icons.shopping_bag_outlined,
                        badge: cartCount,
                        semanticLabel: context.tr('home.bottomNav.cart'),
                        onPressed: () => context.go(RouteNames.cart),
                      ),
                    ],
                  ),
                ),
              ),

              // ── Search bar ──
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
                  child: Semantics(
                    button: true,
                    label: context.tr('home.search'),
                    child: GestureDetector(
                      onTap: () => context.push(RouteNames.search),
                      child: Container(
                        height: 52,
                        padding:
                            const EdgeInsets.symmetric(horizontal: 20),
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius:
                              BorderRadius.circular(AppDimensions.radiusPill),
                          boxShadow: AppDimensions.shadowSm,
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.search_rounded,
                              color: AppColors.textTertiary,
                              size: 22,
                            ),
                            const SizedBox(width: 12),
                            Text(
                              context.tr('home.search'),
                              style: AppTextStyles.bodyMedium.copyWith(
                                color: AppColors.textTertiary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              // ── Hero banner ──
              const SliverToBoxAdapter(child: _BannerCarousel()),

              // ── Categories ──
              SliverToBoxAdapter(
                child: SectionHeader(
                  title: context.tr('home.categories'),
                  onSeeAll: () => context.go(RouteNames.categories),
                ),
              ),
              const SliverToBoxAdapter(child: _CategoryStrip()),

              // ── Featured ──
              SliverToBoxAdapter(
                child: SectionHeader(title: context.tr('home.featured')),
              ),
              SliverToBoxAdapter(
                child: _HorizontalProducts(provider: featuredProductsProvider),
              ),

              // ── New Arrivals ──
              SliverToBoxAdapter(
                child: SectionHeader(title: context.tr('home.newArrivals')),
              ),
              SliverToBoxAdapter(
                child: _HorizontalProducts(provider: newArrivalsProvider),
              ),

              // ── Best Sellers / Offers ──
              SliverToBoxAdapter(
                child: SectionHeader(title: context.tr('home.bestSellers')),
              ),
              SliverToBoxAdapter(
                child: _HorizontalProducts(provider: bestSellersProvider),
              ),

              const SliverToBoxAdapter(child: SizedBox(height: 110)),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────

class _BannerCarousel extends ConsumerWidget {
  const _BannerCarousel();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final banners = ref.watch(bannersProvider);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: banners.when(
        loading: () => const Padding(
          padding: EdgeInsets.symmetric(horizontal: 20),
          child: AspectRatio(
            aspectRatio: 16 / 8,
            child: ShimmerBox(radius: AppDimensions.radius24),
          ),
        ),
        error: (_, __) => const SizedBox.shrink(),
        data: (items) {
          if (items.isEmpty) return const SizedBox.shrink();
          return CarouselSlider.builder(
            itemCount: items.length,
            options: CarouselOptions(
              aspectRatio: 16 / 8,
              viewportFraction: 0.92,
              enlargeCenterPage: true,
              enlargeFactor: 0.15,
              autoPlay: items.length > 1,
              autoPlayInterval: const Duration(seconds: 5),
            ),
            itemBuilder: (context, index, _) {
              final banner = items[index];
              return GestureDetector(
                onTap: () => _handleBannerTap(context, banner),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(AppDimensions.radius24),
                  child: CachedNetworkImage(
                    imageUrl: banner.imageUrl,
                    fit: BoxFit.cover,
                    width: double.infinity,
                    placeholder: (_, __) => const ShimmerBox(radius: 0),
                    errorWidget: (_, __, ___) => Container(
                      color: AppColors.secondaryLight,
                      child: const Icon(
                        Icons.image_outlined,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  void _handleBannerTap(BuildContext context, domain.Banner banner) {
    switch (banner.linkType) {
      case 'product':
        if (banner.linkValue != null) {
          context.push('${RouteNames.productDetails}/${banner.linkValue}');
        }
      case 'category':
        if (banner.linkValue != null) {
          context.push(
            '${RouteNames.categoryDetails}/${banner.linkValue}',
          );
        }
      default:
        break; // TODO(phase5): external URL banners via url_launcher
    }
  }
}

// ─────────────────────────────────────────────

class _CategoryStrip extends ConsumerWidget {
  const _CategoryStrip();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categories = ref.watch(homeCategoriesProvider);

    return SizedBox(
      height: 104,
      child: categories.when(
        loading: () => ListView.separated(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 20),
          itemCount: 5,
          separatorBuilder: (_, __) => const SizedBox(width: 14),
          itemBuilder: (_, __) => const Column(
            children: [
              ShimmerBox(width: 68, height: 68, radius: 34),
              SizedBox(height: 8),
              ShimmerLine(width: 48, height: 10),
            ],
          ),
        ),
        error: (_, __) => const SizedBox.shrink(),
        data: (items) {
          final topLevel =
              items.where((c) => c.parentId == null).toList();
          final display = topLevel.isEmpty ? items : topLevel;
          return ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            itemCount: display.length,
            separatorBuilder: (_, __) => const SizedBox(width: 14),
            itemBuilder: (context, i) {
              final cat = display[i];
              return Semantics(
                button: true,
                label: cat.name,
                child: GestureDetector(
                  onTap: () => context.push(
                    '${RouteNames.categoryDetails}/${cat.slug}',
                    extra: cat,
                  ),
                  child: SizedBox(
                    width: 72,
                    child: Column(
                      children: [
                        Container(
                          width: 68,
                          height: 68,
                          decoration: BoxDecoration(
                            color: AppColors.surface,
                            shape: BoxShape.circle,
                            boxShadow: AppDimensions.shadowSm,
                          ),
                          clipBehavior: Clip.antiAlias,
                          child: cat.image != null
                              ? CachedNetworkImage(
                                  imageUrl: cat.image!,
                                  fit: BoxFit.cover,
                                  errorWidget: (_, __, ___) => const Icon(
                                    Icons.category_outlined,
                                    color: AppColors.secondary,
                                  ),
                                )
                              : const Icon(
                                  Icons.category_outlined,
                                  color: AppColors.secondary,
                                ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          cat.name,
                          style: AppTextStyles.labelSmall,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

// ─────────────────────────────────────────────

class _HorizontalProducts extends ConsumerWidget {
  final AutoDisposeFutureProvider<List<domain.Product>> provider;
  const _HorizontalProducts({required this.provider});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final productsAsync = ref.watch(provider);
    final wishlist = ref.watch(wishlistProvider);

    return SizedBox(
      height: 300,
      child: productsAsync.when(
        loading: () => ListView.separated(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 20),
          itemCount: 3,
          separatorBuilder: (_, __) => const SizedBox(width: 14),
          itemBuilder: (_, __) => const SizedBox(
            width: 180,
            child: ProductCardShimmer(),
          ),
        ),
        error: (e, _) => Center(
          child: TextButton.icon(
            onPressed: () => ref.invalidate(provider),
            icon: const Icon(Icons.refresh_rounded, size: 18),
            label: Text(context.tr('common.retry')),
          ),
        ),
        data: (products) {
          if (products.isEmpty) return const SizedBox.shrink();
          return ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            itemCount: products.length,
            separatorBuilder: (_, __) => const SizedBox(width: 14),
            itemBuilder: (context, i) {
              final product = products[i];
              return SizedBox(
                width: 180,
                child: ProductCard(
                  product: product.toCardData(),
                  isWishlisted: wishlist.contains(product.id),
                  onTap: () => context.push(
                    '${RouteNames.productDetails}/${product.slug}',
                  ),
                  onWishlistTap: () => ref
                      .read(wishlistProvider.notifier)
                      .toggle(product.id),
                  onAddToCart: () async {
                    final error = await ref
                        .read(cartProvider.notifier)
                        .addItem(productId: product.id);
                    if (context.mounted) {
                      BellaSnackbar.show(
                        context,
                        error ?? context.tr('product.addedToCart'),
                        type: error == null
                            ? BellaSnackType.success
                            : BellaSnackType.error,
                      );
                    }
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
