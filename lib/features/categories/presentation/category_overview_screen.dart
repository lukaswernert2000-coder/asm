import 'package:asm/core/router/routes.dart';
import 'package:asm/core/theme/asm_spacing.dart';
import 'package:asm/core/theme/asm_text_styles.dart';
import 'package:asm/core/widgets/asm_error_view.dart';
import 'package:asm/core/widgets/asm_skeleton.dart';
import 'package:asm/features/categories/presentation/category_providers.dart';
import 'package:asm/features/categories/presentation/widgets/category_tile.dart';
import 'package:asm/features/listings/domain/listing_filter.dart';
import 'package:asm/features/listings/presentation/listing_providers.dart';
import 'package:asm/features/listings/presentation/widgets/listing_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// Startseite: Kategorien-Grid + "Neu eingestellt".
/// Siehe 02-IMPLEMENTATION-PLAN.md Task 3.1.
class CategoryOverviewScreen extends ConsumerWidget {
  const CategoryOverviewScreen({super.key});

  static const _newestFilter = ListingFilter();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categoriesAsync = ref.watch(rootCategoriesProvider);
    final newestAsync = ref.watch(categoryFeedProvider(_newestFilter));
    final columns = MediaQuery.sizeOf(context).width >= 600 ? 4 : 3;

    return Scaffold(
      body: SafeArea(
        child: categoriesAsync.when(
          loading: () => const Padding(
            padding: EdgeInsets.all(AsmSpacing.md),
            child: AsmSkeleton.listingGrid(),
          ),
          error: (error, stackTrace) => AsmErrorView(
            message: 'Kategorien konnten nicht geladen werden',
            onRetry: () => ref.invalidate(rootCategoriesProvider),
          ),
          data: (categories) => ListView(
            padding: const EdgeInsets.all(AsmSpacing.md),
            children: [
              const Text('Kategorien', style: AsmTextStyles.titleL),
              const SizedBox(height: AsmSpacing.sm),
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: columns,
                  mainAxisSpacing: AsmSpacing.sm,
                  crossAxisSpacing: AsmSpacing.sm,
                ),
                itemCount: categories.length,
                itemBuilder: (context, index) {
                  final category = categories[index];
                  return CategoryTile(
                    category: category,
                    onTap: () =>
                        context.push(AsmRoutes.category(category.slug)),
                  );
                },
              ),
              const SizedBox(height: AsmSpacing.xl),
              const Text('Neu eingestellt', style: AsmTextStyles.titleL),
              const SizedBox(height: AsmSpacing.sm),
              SizedBox(
                height: 260,
                child: newestAsync.when(
                  loading: () => const AsmSkeleton.listingGrid(),
                  error: (error, stackTrace) => const SizedBox.shrink(),
                  data: (result) => result.items.isEmpty
                      ? const SizedBox.shrink()
                      : ListView.separated(
                          scrollDirection: Axis.horizontal,
                          itemCount: result.items.length,
                          separatorBuilder: (context, index) =>
                              const SizedBox(width: AsmSpacing.sm),
                          itemBuilder: (context, index) {
                            final summary = result.items[index];
                            return SizedBox(
                              width: 160,
                              child: ListingCard.grid(
                                summary: summary,
                                onTap: () => context.push(
                                  AsmRoutes.listing(summary.id),
                                ),
                              ),
                            );
                          },
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
