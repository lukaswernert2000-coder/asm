import 'package:asm/core/router/routes.dart';
import 'package:asm/core/theme/asm_spacing.dart';
import 'package:asm/core/widgets/asm_chip.dart';
import 'package:asm/core/widgets/asm_empty_state.dart';
import 'package:asm/core/widgets/asm_error_view.dart';
import 'package:asm/core/widgets/asm_skeleton.dart';
import 'package:asm/features/categories/presentation/category_providers.dart';
import 'package:asm/features/listings/domain/listing_filter.dart';
import 'package:asm/features/listings/presentation/listing_providers.dart';
import 'package:asm/features/listings/presentation/widgets/listing_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

/// Kategorie-Feed: Unterkategorien als Chip-Reihe, darunter der gefilterte
/// Feed. Siehe 02-IMPLEMENTATION-PLAN.md Task 3.1.
class CategoryScreen extends ConsumerStatefulWidget {
  const CategoryScreen({required this.slug, super.key});

  final String slug;

  @override
  ConsumerState<CategoryScreen> createState() => _CategoryScreenState();
}

class _CategoryScreenState extends ConsumerState<CategoryScreen> {
  String? _selectedSlug;

  @override
  Widget build(BuildContext context) {
    final categoryAsync = ref.watch(categoryBySlugProvider(widget.slug));

    return Scaffold(
      appBar: AppBar(title: Text(categoryAsync.valueOrNull?.name ?? '')),
      body: categoryAsync.when(
        loading: () => const Padding(
          padding: EdgeInsets.all(AsmSpacing.md),
          child: AsmSkeleton.listingGrid(),
        ),
        error: (error, stackTrace) => AsmErrorView(
          message: 'Kategorie konnte nicht geladen werden',
          onRetry: () => ref.invalidate(categoryBySlugProvider(widget.slug)),
        ),
        data: (category) => Column(
          children: [
            const SizedBox(height: AsmSpacing.sm),
            SizedBox(
              height: 34,
              child: _SubcategoryChips(
                parentSlug: widget.slug,
                selectedSlug: _selectedSlug,
                onSelect: (slug) => setState(() => _selectedSlug = slug),
              ),
            ),
            const SizedBox(height: AsmSpacing.sm),
            Expanded(child: _Feed(categorySlug: _selectedSlug ?? widget.slug)),
          ],
        ),
      ),
    );
  }
}

class _SubcategoryChips extends ConsumerWidget {
  const _SubcategoryChips({
    required this.parentSlug,
    required this.selectedSlug,
    required this.onSelect,
  });

  final String parentSlug;
  final String? selectedSlug;
  final ValueChanged<String?> onSelect;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final childrenAsync = ref.watch(categoryChildrenProvider(parentSlug));

    return childrenAsync.when(
      loading: () => const SizedBox.shrink(),
      error: (error, stackTrace) => const SizedBox.shrink(),
      data: (children) => ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: AsmSpacing.md),
        itemCount: children.length + 1,
        separatorBuilder: (context, index) =>
            const SizedBox(width: AsmSpacing.xs),
        itemBuilder: (context, index) {
          if (index == 0) {
            return AsmChip(
              label: 'Alle',
              selected: selectedSlug == null,
              onTap: () => onSelect(null),
            );
          }
          final child = children[index - 1];
          return AsmChip(
            label: child.name,
            selected: selectedSlug == child.slug,
            onTap: () => onSelect(child.slug),
          );
        },
      ),
    );
  }
}

class _Feed extends ConsumerWidget {
  const _Feed({required this.categorySlug});

  final String categorySlug;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filter = ListingFilter(categorySlug: categorySlug);
    final feedAsync = ref.watch(categoryFeedProvider(filter));

    return feedAsync.when(
      loading: () => const Padding(
        padding: EdgeInsets.symmetric(horizontal: AsmSpacing.md),
        child: AsmSkeleton.listingGrid(),
      ),
      error: (error, stackTrace) => AsmErrorView(
        message: 'Inserate konnten nicht geladen werden',
        onRetry: () => ref.invalidate(categoryFeedProvider(filter)),
      ),
      data: (result) => result.items.isEmpty
          ? const AsmEmptyState(
              icon: LucideIcons.packageX,
              title: 'Keine Inserate gefunden',
            )
          : GridView.builder(
              padding: const EdgeInsets.all(AsmSpacing.md),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: AsmSpacing.sm,
                crossAxisSpacing: AsmSpacing.sm,
                childAspectRatio: 0.72,
              ),
              itemCount: result.items.length,
              itemBuilder: (context, index) {
                final summary = result.items[index];
                return ListingCard.grid(
                  summary: summary,
                  onTap: () => context.push(AsmRoutes.listing(summary.id)),
                );
              },
            ),
    );
  }
}
