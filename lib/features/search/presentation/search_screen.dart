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
import 'package:asm/features/listings/domain/listing.dart';
import 'package:asm/features/listings/domain/listing_filter.dart';
import 'package:asm/features/listings/presentation/listing_feed_controller.dart';
import 'package:asm/features/listings/presentation/widgets/listing_card.dart';
import 'package:asm/features/search/presentation/search_history_providers.dart';
import 'package:asm/features/search/presentation/widgets/filter_sheet.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

const _debounceDuration = Duration(milliseconds: 350);

/// Suche mit Verlauf, Debounce und Filter-Sheet. Siehe
/// 02-IMPLEMENTATION-PLAN.md Task 3.3/3.4. Suchergebnisse laufen ueber
/// `listingFeedProvider` (Task 3.2) mit dem vollen `ListingFilter` --
/// Pagination/Lade-/Fehlerzustand sind dort schon fertig getestet, hier
/// nicht dupliziert.
class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  final _controller = TextEditingController();
  Timer? _debounce;
  ListingFilter _filter = const ListingFilter();

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
    setState(
      () => _filter = _filter.copyWith(
        query: trimmed.isEmpty ? null : trimmed,
      ),
    );
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

  Future<void> _openFilterSheet() async {
    final result = await showFilterSheet(context, filter: _filter);
    if (result != null) setState(() => _filter = result);
  }

  void _removeCategory() =>
      setState(() => _filter = _filter.copyWith(categorySlug: null));
  void _removePrice() => setState(
    () => _filter = _filter.copyWith(minPrice: null, maxPrice: null),
  );
  void _removeConditions() =>
      setState(() => _filter = _filter.copyWith(conditions: null));
  void _removePropulsions() =>
      setState(() => _filter = _filter.copyWith(propulsions: null));
  void _removeJoule() => setState(
    () => _filter = _filter.copyWith(minJoule: null, maxJoule: null),
  );
  void _removeShips() =>
      setState(() => _filter = _filter.copyWith(ships: null));
  void _removeLocation() => setState(
    () => _filter = _filter.copyWith(lat: null, lng: null, radiusKm: null),
  );
  void _removeSort() =>
      setState(() => _filter = _filter.copyWith(sort: SortOption.newest));

  @override
  Widget build(BuildContext context) {
    final hasQuery = _filter.query?.isNotEmpty ?? false;
    final isIdle = !hasQuery && _filter.activeCount == 0;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AsmSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // AsmShell legt im Debug-Build einen Katalog-Button genau in
              // diese Ecke (siehe asm_shell.dart) -- ohne Abstand ueberlappt
              // er das Filter-Icon und faengt dessen Taps ab. Nur eine
              // Debug-Eigenheit, im Release-Build existiert der Button nicht.
              if (kDebugMode) const SizedBox(height: 44),
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Expanded(
                    child: AsmTextField(
                      controller: _controller,
                      label: 'Suche',
                    ),
                  ),
                  const SizedBox(width: AsmSpacing.xs),
                  Badge(
                    label: Text('${_filter.activeCount}'),
                    isLabelVisible: _filter.activeCount > 0,
                    child: IconButton(
                      icon: const Icon(LucideIcons.slidersHorizontal),
                      tooltip: 'Filter',
                      onPressed: _openFilterSheet,
                    ),
                  ),
                ],
              ),
              if (!isIdle && _filter.activeCount > 0) ...[
                const SizedBox(height: AsmSpacing.sm),
                _ActiveFilterChips(
                  filter: _filter,
                  onRemoveCategory: _removeCategory,
                  onRemovePrice: _removePrice,
                  onRemoveConditions: _removeConditions,
                  onRemovePropulsions: _removePropulsions,
                  onRemoveJoule: _removeJoule,
                  onRemoveShips: _removeShips,
                  onRemoveLocation: _removeLocation,
                  onRemoveSort: _removeSort,
                ),
              ],
              const SizedBox(height: AsmSpacing.md),
              Expanded(
                child: isIdle
                    ? _IdleSuggestions(onSelectHistory: _selectHistoryEntry)
                    : _SearchResults(filter: _filter),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ActiveFilterChips extends ConsumerWidget {
  const _ActiveFilterChips({
    required this.filter,
    required this.onRemoveCategory,
    required this.onRemovePrice,
    required this.onRemoveConditions,
    required this.onRemovePropulsions,
    required this.onRemoveJoule,
    required this.onRemoveShips,
    required this.onRemoveLocation,
    required this.onRemoveSort,
  });

  final ListingFilter filter;
  final VoidCallback onRemoveCategory;
  final VoidCallback onRemovePrice;
  final VoidCallback onRemoveConditions;
  final VoidCallback onRemovePropulsions;
  final VoidCallback onRemoveJoule;
  final VoidCallback onRemoveShips;
  final VoidCallback onRemoveLocation;
  final VoidCallback onRemoveSort;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categorySlug = filter.categorySlug;
    final categoryName = categorySlug == null
        ? null
        : ref.watch(categoryBySlugProvider(categorySlug)).valueOrNull?.name;

    return Wrap(
      spacing: AsmSpacing.xs,
      runSpacing: AsmSpacing.xs,
      children: [
        if (categorySlug != null)
          _RemovableChip(
            label: 'Kategorie: ${categoryName ?? categorySlug}',
            onDelete: onRemoveCategory,
          ),
        if (filter.minPrice != null || filter.maxPrice != null)
          _RemovableChip(
            label:
                'Preis: ${_rangeLabel(
                  filter.minPrice == null ? null : filter.minPrice! / 100,
                  filter.maxPrice == null ? null : filter.maxPrice! / 100,
                  suffix: ' €',
                )}',
            onDelete: onRemovePrice,
          ),
        if (filter.conditions != null && filter.conditions!.isNotEmpty)
          _RemovableChip(
            label: filter.conditions!.length == 1
                ? filter.conditions!.single.label
                : 'Zustand (${filter.conditions!.length})',
            onDelete: onRemoveConditions,
          ),
        if (filter.propulsions != null && filter.propulsions!.isNotEmpty)
          _RemovableChip(
            label: filter.propulsions!.length == 1
                ? filter.propulsions!.single.label
                : 'Antriebsart (${filter.propulsions!.length})',
            onDelete: onRemovePropulsions,
          ),
        if (filter.minJoule != null || filter.maxJoule != null)
          _RemovableChip(
            label: _rangeLabel(filter.minJoule, filter.maxJoule, suffix: ' J'),
            onDelete: onRemoveJoule,
          ),
        if (filter.ships ?? false)
          _RemovableChip(label: 'Versand möglich', onDelete: onRemoveShips),
        if (filter.lat != null || filter.lng != null || filter.radiusKm != null)
          _RemovableChip(
            label: filter.radiusKm != null
                ? 'Umkreis: ${filter.radiusKm} km'
                : 'Umkreis: ganz DE',
            onDelete: onRemoveLocation,
          ),
        if (filter.sort != SortOption.newest)
          _RemovableChip(
            label: _sortLabel(filter.sort),
            onDelete: onRemoveSort,
          ),
      ],
    );
  }

  String _rangeLabel(double? min, double? max, {required String suffix}) {
    if (min != null && max != null) {
      return '${_trimZero(min)}–${_trimZero(max)}$suffix';
    }
    if (min != null) return 'ab ${_trimZero(min)}$suffix';
    return 'bis ${_trimZero(max!)}$suffix';
  }

  String _trimZero(double value) => value == value.roundToDouble()
      ? value.round().toString()
      : value.toString();

  String _sortLabel(SortOption sort) => switch (sort) {
    SortOption.newest => 'Neueste',
    SortOption.priceAsc => 'Sortierung: Preis aufsteigend',
    SortOption.priceDesc => 'Sortierung: Preis absteigend',
    SortOption.distance => 'Sortierung: Entfernung',
  };
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
                _RemovableChip(
                  label: entry,
                  onTap: () => onSelectHistory(entry),
                  onDelete: () =>
                      unawaited(removeSearchHistoryEntry(ref, entry)),
                  deleteTooltip: '„$entry“ aus Verlauf entfernen',
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

/// Kompakter Chip mit Loeschen-Icon -- fuer Suchverlauf (Task 3.3) und
/// aktive Filter (Task 3.4). [onTap] ist optional: Verlaufseintraege
/// uebernehmen die Suche bei Tap, aktive Filter-Chips sind nur informativ.
class _RemovableChip extends StatelessWidget {
  const _RemovableChip({
    required this.label,
    required this.onDelete,
    this.onTap,
    this.deleteTooltip,
  });

  final String label;
  final VoidCallback onDelete;
  final VoidCallback? onTap;
  final String? deleteTooltip;

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
                label,
                style: AsmTextStyles.label.copyWith(
                  color: AsmColors.textSecondary,
                ),
              ),
              IconButton(
                icon: const Icon(LucideIcons.x, size: 14),
                tooltip: deleteTooltip ?? '„$label“ entfernen',
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
  const _SearchResults({required this.filter});

  final ListingFilter filter;

  @override
  ConsumerState<_SearchResults> createState() => _SearchResultsState();
}

class _SearchResultsState extends ConsumerState<_SearchResults> {
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
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
      unawaited(
        ref.read(listingFeedProvider(widget.filter).notifier).loadMore(),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final feedAsync = ref.watch(listingFeedProvider(widget.filter));

    return feedAsync.when(
      loading: () => const AsmSkeleton.listingGrid(),
      error: (error, stackTrace) => AsmErrorView(
        message: 'Inserate konnten nicht geladen werden',
        onRetry: () => ref.invalidate(listingFeedProvider(widget.filter)),
      ),
      data: (result) => result.items.isEmpty
          ? const AsmEmptyState(
              icon: LucideIcons.packageX,
              title: 'Keine Inserate gefunden',
            )
          : RefreshIndicator(
              onRefresh: () => ref
                  .read(listingFeedProvider(widget.filter).notifier)
                  .refresh(),
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
