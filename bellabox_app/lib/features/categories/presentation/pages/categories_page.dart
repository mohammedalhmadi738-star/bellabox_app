import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:bellabox/core/localization/app_localizations.dart';
import 'package:bellabox/core/routing/route_names.dart';
import 'package:bellabox/core/theme/app_colors.dart';
import 'package:bellabox/core/theme/app_dimensions.dart';
import 'package:bellabox/core/theme/app_text_styles.dart';
import 'package:bellabox/features/categories/presentation/providers/categories_providers.dart';
import 'package:bellabox/shared/widgets/loaders/shimmer_box.dart';
import 'package:bellabox/shared/widgets/states/empty_state.dart';
import 'package:bellabox/shared/widgets/states/error_state.dart';

class CategoriesPage extends ConsumerWidget {
  const CategoriesPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categoriesAsync = ref.watch(allCategoriesProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(context.tr('categories.title')),
        automaticallyImplyLeading: false,
      ),
      body: RefreshIndicator(
        color: AppColors.primary,
        onRefresh: () async => ref.invalidate(allCategoriesProvider),
        child: categoriesAsync.when(
          loading: () => GridView.builder(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 120),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 14,
              crossAxisSpacing: 14,
              childAspectRatio: 1.2,
            ),
            itemCount: 6,
            itemBuilder: (_, __) =>
                const ShimmerBox(radius: AppDimensions.radius20),
          ),
          error: (e, _) => ErrorStateView(
            onRetry: () => ref.invalidate(allCategoriesProvider),
          ),
          data: (categories) {
            final topLevel =
                categories.where((c) => c.parentId == null).toList();
            final display = topLevel.isEmpty ? categories : topLevel;
            if (display.isEmpty) {
              return EmptyState(
                icon: Icons.category_outlined,
                title: context.tr('categories.empty'),
              );
            }
            return GridView.builder(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 120),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 14,
                crossAxisSpacing: 14,
                childAspectRatio: 1.2,
              ),
              itemCount: display.length,
              itemBuilder: (context, i) {
                final cat = display[i];
                return Semantics(
                  button: true,
                  label: cat.name,
                  child: Material(
                    color: AppColors.surface,
                    borderRadius:
                        BorderRadius.circular(AppDimensions.radius20),
                    clipBehavior: Clip.antiAlias,
                    child: InkWell(
                      onTap: () => context.push(
                        '${RouteNames.categoryDetails}/${cat.slug}',
                        extra: cat,
                      ),
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          if (cat.image != null)
                            CachedNetworkImage(
                              imageUrl: cat.image!,
                              fit: BoxFit.cover,
                              placeholder: (_, __) =>
                                  const ShimmerBox(radius: 0),
                              errorWidget: (_, __, ___) => Container(
                                color: AppColors.secondaryLight,
                              ),
                            )
                          else
                            Container(color: AppColors.secondaryLight),
                          // Gradient scrim for text legibility
                          Container(
                            decoration: const BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [
                                  Colors.transparent,
                                  Color(0x99000000),
                                ],
                              ),
                            ),
                          ),
                          Positioned(
                            bottom: 12,
                            left: 12,
                            right: 12,
                            child: Text(
                              cat.name,
                              style: AppTextStyles.h4.copyWith(
                                color: Colors.white,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
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
      ),
    );
  }
}
