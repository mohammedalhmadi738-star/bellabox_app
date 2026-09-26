import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:bellabox/core/localization/app_localizations.dart';
import 'package:bellabox/core/routing/route_names.dart';
import 'package:bellabox/core/theme/app_colors.dart';
import 'package:bellabox/core/theme/app_dimensions.dart';
import 'package:bellabox/features/categories/presentation/providers/categories_providers.dart';
import 'package:bellabox/features/products/domain/entities/product.dart' as domain;
import 'package:bellabox/features/wishlist/presentation/providers/wishlist_provider.dart';
import 'package:bellabox/shared/widgets/cards/product_card.dart';
import 'package:bellabox/shared/widgets/states/empty_state.dart';
import 'package:bellabox/shared/widgets/states/error_state.dart';

class CategoryDetailsPage extends ConsumerStatefulWidget {
  final String slug;
  final domain.Category? category;

  const CategoryDetailsPage({
    super.key,
    required this.slug,
    this.category,
  });

  @override
  ConsumerState<CategoryDetailsPage> createState() =>
      _CategoryDetailsPageState();
}

class _CategoryDetailsPageState extends ConsumerState<CategoryDetailsPage> {
  final _scrollController = ScrollController();
  domain.Category? _resolved;

  @override
  void initState() {
    super.initState();
    _resolved = widget.category;
    _scrollController.addListener(_onScroll);
    if (_resolved == null) {
      // Resolve category by slug from the cached full list
      Future.microtask(() async {
        final cats = await ref.read(allCategoriesProvider.future);
        final found = _findBySlug(cats, widget.slug);
        if (mounted) setState(() => _resolved = found);
      });
    }
  }

  domain.Category? _findBySlug(List<domain.Category> cats, String slug) {
    for (final c in cats) {
      if (c.slug == slug) return c;
      final child = _findBySlug(c.children, slug);
      if (child != null) return child;
    }
    return null;
  }

  void _onScroll() {
    if (_resolved == null) return;
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 400) {
      ref
          .read(categoryProductsProvider(_resolved!.id).notifier)
          .loadMore();
    }
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final category = _resolved;
    if (category == null) {
      return Scaffold(
        appBar: AppBar(),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    final state = ref.watch(categoryProductsProvider(category.id));
    final wishlist = ref.watch(wishlistProvider);

    return Scaffold(
      appBar: AppBar(title: Text(category.name)),
      body: RefreshIndicator(
        color: AppColors.primary,
        onRefresh: () =>
            ref.read(categoryProductsProvider(category.id).notifier).refresh(),
        child: Builder(
          builder: (context) {
            if (state.initialLoading) {
              return GridView.builder(
                padding: const EdgeInsets.all(20),
                gridDelegate:
                    const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 14,
                  crossAxisSpacing: 14,
                  childAspectRatio: AppDimensions.productCardAspectRatio,
                ),
                itemCount: 6,
                itemBuilder: (_, __) => const ProductCardShimmer(),
              );
            }
            if (state.error != null && state.items.isEmpty) {
              return ErrorStateView(
                message: state.error,
                onRetry: () => ref
                    .read(categoryProductsProvider(category.id).notifier)
                    .loadFirst(),
              );
            }
            if (state.items.isEmpty) {
              return EmptyState(
                icon: Icons.inventory_2_outlined,
                title: context.tr('search.noResults'),
              );
            }
            return CustomScrollView(
              controller: _scrollController,
              slivers: [
                SliverPadding(
                  padding: const EdgeInsets.all(20),
                  sliver: SliverGrid(
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      mainAxisSpacing: 14,
                      crossAxisSpacing: 14,
                      childAspectRatio:
                          AppDimensions.productCardAspectRatio,
                    ),
                    delegate: SliverChildBuilderDelegate(
                      (context, i) {
                        final product = state.items[i];
                        return ProductCard(
                          product: product.toCardData(),
                          isWishlisted: wishlist.contains(product.id),
                          onTap: () => context.push(
                            '${RouteNames.productDetails}/${product.slug}',
                          ),
                          onWishlistTap: () => ref
                              .read(wishlistProvider.notifier)
                              .toggle(product.id),
                        );
                      },
                      childCount: state.items.length,
                    ),
                  ),
                ),
                if (state.loadingMore)
                  const SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.all(24),
                      child: Center(
                        child: SizedBox(
                          width: 28,
                          height: 28,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                      ),
                    ),
                  ),
                const SliverToBoxAdapter(child: SizedBox(height: 40)),
              ],
            );
          },
        ),
      ),
    );
  }
}
