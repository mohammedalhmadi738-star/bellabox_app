import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:bellabox/core/localization/app_localizations.dart';
import 'package:bellabox/core/routing/route_names.dart';
import 'package:bellabox/core/storage/local_storage.dart';
import 'package:bellabox/core/theme/app_colors.dart';
import 'package:bellabox/core/theme/app_dimensions.dart';
import 'package:bellabox/core/theme/app_text_styles.dart';
import 'package:bellabox/features/products/domain/entities/product.dart';
import 'package:bellabox/features/search/presentation/providers/search_provider.dart';
import 'package:bellabox/features/wishlist/presentation/providers/wishlist_provider.dart';
import 'package:bellabox/shared/widgets/cards/product_card.dart';
import 'package:bellabox/shared/widgets/states/empty_state.dart';
import 'package:bellabox/shared/widgets/states/error_state.dart';

class SearchPage extends ConsumerStatefulWidget {
  const SearchPage({super.key});

  @override
  ConsumerState<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends ConsumerState<SearchPage> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(searchProvider);

    return Scaffold(
      appBar: AppBar(
        titleSpacing: 0,
        title: Padding(
          padding: const EdgeInsetsDirectional.only(end: 16),
          child: TextField(
            controller: _controller,
            autofocus: true,
            textInputAction: TextInputAction.search,
            style: AppTextStyles.bodyLarge,
            decoration: InputDecoration(
              hintText: context.tr('search.hint'),
              prefixIcon: const Icon(
                Icons.search_rounded,
                color: AppColors.textTertiary,
                size: 20,
              ),
              suffixIcon: _controller.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.close_rounded, size: 18),
                      onPressed: () {
                        _controller.clear();
                        ref.read(searchProvider.notifier).clear();
                        setState(() {});
                      },
                    )
                  : null,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
            ),
            onChanged: (q) {
              ref.read(searchProvider.notifier).onQueryChanged(q);
              setState(() {});
            },
            onSubmitted: (q) => ref.read(searchProvider.notifier).submit(q),
          ),
        ),
      ),
      body: switch (state) {
        SearchIdle() => _RecentSearches(
            onSelect: (q) {
              _controller.text = q;
              ref.read(searchProvider.notifier).submit(q);
            },
          ),
        SearchLoading() => GridView.builder(
            padding: const EdgeInsets.all(20),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 14,
              crossAxisSpacing: 14,
              childAspectRatio: AppDimensions.productCardAspectRatio,
            ),
            itemCount: 6,
            itemBuilder: (_, __) => const ProductCardShimmer(),
          ),
        SearchResults(:final products) => _ResultsGrid(products: products),
        SearchEmpty(:final query) => EmptyState(
            icon: Icons.search_off_rounded,
            title: context.tr('search.noResults'),
            body: '${context.tr('search.noResultsHint')}\n"$query"',
          ),
        SearchError(:final message) => ErrorStateView(
            message: message,
            onRetry: () =>
                ref.read(searchProvider.notifier).submit(_controller.text),
          ),
      },
    );
  }
}

class _RecentSearches extends ConsumerWidget {
  final ValueChanged<String> onSelect;
  const _RecentSearches({required this.onSelect});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final recents = ref.watch(recentSearchesProvider);

    if (recents.isEmpty) {
      return EmptyState(
        icon: Icons.search_rounded,
        title: context.tr('search.startTyping'),
      );
    }

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                context.tr('search.recent'),
                style: AppTextStyles.h4,
              ),
            ),
            TextButton(
              onPressed: () async {
                await LocalStorage.clearRecentSearches();
                ref.invalidate(recentSearchesProvider);
              },
              child: Text(
                context.tr('search.clearAll'),
                style: AppTextStyles.labelMedium
                    .copyWith(color: AppColors.error),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: recents
              .map(
                (q) => ActionChip(
                  avatar: const Icon(
                    Icons.history_rounded,
                    size: 16,
                    color: AppColors.textSecondary,
                  ),
                  label: Text(q),
                  onPressed: () => onSelect(q),
                ),
              )
              .toList(),
        ),
      ],
    );
  }
}

class _ResultsGrid extends ConsumerWidget {
  final List<Product> products;
  const _ResultsGrid({required this.products});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final wishlist = ref.watch(wishlistProvider);

    return GridView.builder(
      padding: const EdgeInsets.all(20),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 14,
        crossAxisSpacing: 14,
        childAspectRatio: AppDimensions.productCardAspectRatio,
      ),
      itemCount: products.length,
      itemBuilder: (context, i) {
        final product = products[i];
        return ProductCard(
          product: product.toCardData(),
          isWishlisted: wishlist.contains(product.id),
          onTap: () => context.push(
            '${RouteNames.productDetails}/${product.slug}',
          ),
          onWishlistTap: () =>
              ref.read(wishlistProvider.notifier).toggle(product.id),
        );
      },
    );
  }
}
