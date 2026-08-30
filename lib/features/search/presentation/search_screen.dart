import 'dart:async';

import 'package:asm/core/router/routes.dart';
import 'package:asm/core/theme/asm_colors.dart';
import 'package:asm/core/theme/asm_spacing.dart';
import 'package:asm/core/theme/asm_text_styles.dart';
import 'package:asm/core/widgets/asm_chip.dart';
import 'package:asm/core/widgets/asm_empty_state.dart';
import 'package:asm/core/widgets/asm_error_view.dart';
import 'package:asm/core/widgets/asm_skeleton.dart';
import 'package:asm/core/widgets/asm_text_field.dart';
import 'package:asm/features/categories/presentation/category_providers.dart';
import 'package:asm/features/listings/domain/listing_filter.dart';
import 'package:asm/features/listings/presentation/listing_feed_controller.dart';
import 'package:asm/features/listings/presentation/widgets/listing_card.dart';
import 'package:asm/features/search/presentation/search_history_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

const _debounceDuration = Duration(milliseconds: 350);

/// Suche mit Verlauf und Debounce. Siehe 02-IMPLEMENTATION-PLAN.md Task 3.3.
/// Suchergebnisse laufen ueber `listingFeedProvider` (Task 3.2) mit
/// `ListingFilter(query: ...)` -- Pagination/Lade-/Fehlerzustand sind dort
/// schon fertig getestet, hier nicht dupliziert.
class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  final _controller = TextEditingController();
  Timer? _debounce;
  String _query = '';

  @override
  void initState() {
    super.initState();
    _controller.addListener(_onControllerChanged);
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _controller
      ..removeListener(_onControllerChanged)
      ..dispose();
    super.dispose();
  }

  void _onControllerChanged() {
    _debounce?.cancel();
    _debounce = Timer(_debounceDuration, () => _commitQuery(_controller.text));
  }

  void _commitQuery(String value) {
    final trimmed = value.trim();
    setState(() => _query = trimmed);
    if (trimmed.isNotEmpty) {
      unawaited(addSearchHistoryEntry(ref, trimmed));
    }
  }

  void _selectHistoryEntry(String query) {
    _debounce?.cancel();
    _controller.value = TextEditingValue(
      text: query,
      selection: TextSelection.collapsed(offset: query.length),
    );
    _commitQuery(query);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AsmSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AsmTextField(controller: _controller, label: 'Suche'),
              const SizedBox(height: AsmSpacing.md),
              Expanded(
                child: _query.isEmpty
                    ? _IdleSuggestions(onSelectHistory: _selectHistoryEntry)
                    : _SearchResults(query: _query),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _IdleSuggestions extends ConsumerWidget {
  const _IdleSuggestions({required this.onSelectHistory});

  final ValueChanged<String> onSelectHistory;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final history = ref.watch(searchHistoryProvider);
    final rootCategoriesAsync = ref.watch(rootCategoriesProvider);

    return ListView(
      children: [
        if (history.isNotEmpty) ...[
          const Text('Verlauf', style: AsmTextStyles.titleS),
          const SizedBox(height: AsmSpacing.sm),
          Wrap(
            spacing: AsmSpacing.xs,
            runSpacing: AsmSpacing.xs,
            children: [
              for (final entry in history)
                _HistoryChip(
                  query: entry,
                  onTap: () => onSelectHistory(entry),
                  onDelete: () =>
                      unawaited(removeSearchHistoryEntry(ref, entry)),
                ),
            ],
          ),
          const SizedBox(height: AsmSpacing.lg),
        ],
        const Text('Beliebte Kategorien', style: AsmTextStyles.titleS),
        const SizedBox(height: AsmSpacing.sm),
        rootCategoriesAsync.when(
          loading: () => const SizedBox.shrink(),
          error: (error, stackTrace) => const SizedBox.shrink(),
          data: (categories) => Wrap(
            spacing: AsmSpacing.xs,
            runSpacing: AsmSpacing.xs,
            children: [
              for (final category in categories)
                AsmChip(
                  label: category.name,
                  selected: false,
                  onTap: () => context.push(AsmRoutes.category(category.slug)),
                ),
            ],
          ),
        ),
      ],
    );
  }
}

class _HistoryChip extends StatelessWidget {
  const _HistoryChip({
    required this.query,
    required this.onTap,
    required this.onDelete,
  });

  final String query;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AsmColors.surfaceRaised,
      borderRadius: BorderRadius.circular(AsmRadius.full),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AsmRadius.full),
        child: Padding(
          padding: const EdgeInsets.only(
            left: AsmSpacing.sm,
            right: AsmSpacing.xxs,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                query,
                style: AsmTextStyles.label.copyWith(
                  color: AsmColors.textSecondary,
                ),
              ),
              IconButton(
                icon: const Icon(LucideIcons.x, size: 14),
                tooltip: '„$query“ aus Verlauf entfernen',
                color: AsmColors.textTertiary,
                onPressed: onDelete,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SearchResults extends ConsumerStatefulWidget {
  const _SearchResults({required this.query});

  final String query;

  @override
  ConsumerState<_SearchResults> createState() => _SearchResultsState();
}

class _SearchResultsState extends ConsumerState<_SearchResults> {
  final _scrollController = ScrollController();
  late ListingFilter _filter = ListingFilter(query: widget.query);

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void didUpdateWidget(covariant _SearchResults oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.query != widget.query) {
      _filter = ListingFilter(query: widget.query);
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
      loading: () => const AsmSkeleton.listingGrid(),
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
              child: _grid(result),
            ),
    );
  }

  Widget _grid(ListingFeedState result) {
    final extra = result.isLoadingMore ? 2 : 0;
    return GridView.builder(
      controller: _scrollController,
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
}
