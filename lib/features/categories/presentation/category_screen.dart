import 'dart:async';

import 'package:asm/core/router/routes.dart';
import 'package:asm/core/theme/asm_colors.dart';
import 'package:asm/core/theme/asm_spacing.dart';
import 'package:asm/core/widgets/asm_chip.dart';
import 'package:asm/core/widgets/asm_empty_state.dart';
import 'package:asm/core/widgets/asm_error_view.dart';
import 'package:asm/core/widgets/asm_skeleton.dart';
import 'package:asm/features/categories/presentation/category_providers.dart';
import 'package:asm/features/listings/domain/listing_filter.dart';
import 'package:asm/features/listings/presentation/listing_feed_controller.dart';
import 'package:asm/features/listings/presentation/listing_providers.dart';
import 'package:asm/features/listings/presentation/widgets/listing_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:shimmer/shimmer.dart';

/// Kategorie-Feed: Unterkategorien als Chip-Reihe, darunter der gefilterte,
/// paginierte Feed. Siehe 02-IMPLEMENTATION-PLAN.md Task 3.1/3.2.
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
    final viewMode = ref.watch(listingViewModeProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(categoryAsync.valueOrNull?.name ?? ''),
        actions: [
          IconButton(
            icon: Icon(
              viewMode == ListingViewMode.grid
                  ? LucideIcons.list
                  : LucideIcons.layoutGrid,
            ),
            tooltip: viewMode == ListingViewMode.grid
                ? 'Als Liste anzeigen'
                : 'Als Raster anzeigen',
            onPressed: () => unawaited(
              setListingViewMode(
                ref,
                viewMode == ListingViewMode.grid
                    ? ListingViewMode.list
                    : ListingViewMode.grid,
              ),
            ),
          ),
        ],
      ),
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
            Expanded(
              child: _Feed(
                categorySlug: _selectedSlug ?? widget.slug,
                viewMode: viewMode,
              ),
            ),
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

/// Nachladen bei 80 % Scrolltiefe, Pull-to-Refresh, Grid/Liste je
/// [ListingViewMode]. Siehe 02-IMPLEMENTATION-PLAN.md Task 3.2.
class _Feed extends ConsumerStatefulWidget {
  const _Feed({required this.categorySlug, required this.viewMode});

  final String categorySlug;
  final ListingViewMode viewMode;

  @override
  ConsumerState<_Feed> createState() => _FeedState();
}

class _FeedState extends ConsumerState<_Feed> {
  final _scrollController = ScrollController();
  late ListingFilter _filter = ListingFilter(
    categorySlug: widget.categorySlug,
  );

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void didUpdateWidget(covariant _Feed oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.categorySlug != widget.categorySlug) {
      _filter = ListingFilter(categorySlug: widget.categorySlug);
    }
  }

  @override
  void dispose() {
    _scrollController
      ..removeListener(_onScroll)
      ..dispose();
    super.dispose();
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;
    final position = _scrollController.position;
    if (position.maxScrollExtent > 0 &&
        position.pixels >= position.maxScrollExtent * 0.8) {
      unawaited(ref.read(listingFeedProvider(_filter).notifier).loadMore());
    }
  }

  @override
  Widget build(BuildContext context) {
    final feedAsync = ref.watch(listingFeedProvider(_filter));

    return feedAsync.when(
      loading: () => const Padding(
        padding: EdgeInsets.symmetric(horizontal: AsmSpacing.md),
        child: AsmSkeleton.listingGrid(),
      ),
      error: (error, stackTrace) => AsmErrorView(
        message: 'Inserate konnten nicht geladen werden',
        onRetry: () => ref.invalidate(listingFeedProvider(_filter)),
      ),
      data: (result) => result.items.isEmpty
          ? const AsmEmptyState(
              icon: LucideIcons.packageX,
              title: 'Keine Inserate gefunden',
            )
          : RefreshIndicator(
              onRefresh: () =>
                  ref.read(listingFeedProvider(_filter).notifier).refresh(),
              child: widget.viewMode == ListingViewMode.grid
                  ? _grid(result)
                  : _list(result),
            ),
    );
  }

  Widget _grid(ListingFeedState result) {
    final extra = result.isLoadingMore ? 2 : 0;
    return GridView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.all(AsmSpacing.md),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: AsmSpacing.sm,
        crossAxisSpacing: AsmSpacing.sm,
        childAspectRatio: 0.72,
      ),
      itemCount: result.items.length + extra,
      itemBuilder: (context, index) {
        if (index >= result.items.length) {
          return const AsmSkeleton.card();
        }
        final summary = result.items[index];
        return ListingCard.grid(
          summary: summary,
          onTap: () => context.push(AsmRoutes.listing(summary.id)),
        );
      },
    );
  }

  Widget _list(ListingFeedState result) {
    final extra = result.isLoadingMore ? 1 : 0;
    return ListView.separated(
      controller: _scrollController,
      padding: const EdgeInsets.all(AsmSpacing.md),
      itemCount: result.items.length + extra,
      separatorBuilder: (context, index) =>
          const SizedBox(height: AsmSpacing.sm),
      itemBuilder: (context, index) {
        if (index >= result.items.length) {
          return _listLoadingMoreRow();
        }
        final summary = result.items[index];
        return ListingCard.list(
          summary: summary,
          onTap: () => context.push(AsmRoutes.listing(summary.id)),
        );
      },
    );
  }

  Widget _listLoadingMoreRow() {
    return SizedBox(
      height: 112,
      child: Shimmer.fromColors(
        baseColor: AsmColors.shimmerBase,
        highlightColor: AsmColors.shimmerHi,
        period: const Duration(milliseconds: 1200),
        child: Container(
          decoration: BoxDecoration(
            color: AsmColors.shimmerBase,
            borderRadius: BorderRadius.circular(AsmRadius.md),
          ),
        ),
      ),
    );
  }
}
