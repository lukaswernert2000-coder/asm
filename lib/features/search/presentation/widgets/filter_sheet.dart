import 'package:asm/core/theme/asm_colors.dart';
import 'package:asm/core/theme/asm_spacing.dart';
import 'package:asm/core/theme/asm_text_styles.dart';
import 'package:asm/core/utils/plz_lookup.dart';
import 'package:asm/core/widgets/asm_button.dart';
import 'package:asm/core/widgets/asm_chip.dart';
import 'package:asm/core/widgets/asm_text_field.dart';
import 'package:asm/features/categories/presentation/category_providers.dart';
import 'package:asm/features/listings/domain/listing.dart';
import 'package:asm/features/listings/domain/listing_filter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

const _radiusOptionsKm = [5, 10, 25, 50, 100, 200];
const _priceSliderMaxEuro = 2000.0;

/// Oeffnet das Filter-Sheet vorbefuellt mit [filter]. Liefert den neuen
/// Filter bei "Anwenden" zurueck, `null` beim Wegwischen ohne Anwenden.
/// Siehe 02-IMPLEMENTATION-PLAN.md Task 3.4.
Future<ListingFilter?> showFilterSheet(
  BuildContext context, {
  required ListingFilter filter,
  Future<({String city, double lat, double lng})?> Function(String plz)?
  resolvePlz,
}) {
  return showModalBottomSheet<ListingFilter>(
    context: context,
    isScrollControlled: true,
    // SearchScreen laeuft im Branch-Navigator der Shell (StatefulShellRoute,
    // app_router.dart). Ohne useRootNavigator haengt das Sheet an diesem
    // verschachtelten Navigator und rendert unterhalb der Scaffold-Ebenen
    // von AsmShell (FAB, BottomNav) statt darueber -- die faingen dann Taps
    // im unteren Sheet-Bereich ab, das Sheet selbst bleibt unberuehrt.
    useRootNavigator: true,
    backgroundColor: AsmColors.surface,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(AsmRadius.lg)),
    ),
    builder: (context) => FilterSheet(
      initialFilter: filter,
      resolvePlz: resolvePlz ?? PlzLookup.resolve,
    ),
  );
}

class FilterSheet extends ConsumerStatefulWidget {
  const FilterSheet({
    required this.initialFilter,
    required this.resolvePlz,
    super.key,
  });

  final ListingFilter initialFilter;

  /// Seam statt `PlzLookup.resolve` direkt aufzurufen -- laedt echt
  /// `assets/data/plz.json` per `rootBundle`, was in `testWidgets` an der
  /// FakeAsync-Zone haengen bleibt (gleiches Muster wie EditProfileScreen).
  final Future<({String city, double lat, double lng})?> Function(String plz)
  resolvePlz;

  @override
  ConsumerState<FilterSheet> createState() => _FilterSheetState();
}

class _FilterSheetState extends ConsumerState<FilterSheet> {
  late ListingFilter _draft = widget.initialFilter;
  late final _minPriceController = TextEditingController(
    text: _draft.minPrice != null ? (_draft.minPrice! ~/ 100).toString() : '',
  );
  late final _maxPriceController = TextEditingController(
    text: _draft.maxPrice != null ? (_draft.maxPrice! ~/ 100).toString() : '',
  );
  final _plzController = TextEditingController();
  String? _resolvedCity;
  String? _plzError;
  int _plzRequestId = 0;

  @override
  void initState() {
    super.initState();
    _minPriceController.addListener(_onMinPriceChanged);
    _maxPriceController.addListener(_onMaxPriceChanged);
    _plzController.addListener(_onPlzChanged);
  }

  @override
  void dispose() {
    _minPriceController.dispose();
    _maxPriceController.dispose();
    _plzController.dispose();
    super.dispose();
  }

  void _onMinPriceChanged() {
    setState(
      () => _draft = _draft.copyWith(
        minPrice: _parseEuro(_minPriceController.text),
      ),
    );
  }

  void _onMaxPriceChanged() {
    setState(
      () => _draft = _draft.copyWith(
        maxPrice: _parseEuro(_maxPriceController.text),
      ),
    );
  }

  int? _parseEuro(String text) {
    final value = double.tryParse(text.trim().replaceAll(',', '.'));
    if (value == null) return null;
    return (value * 100).round();
  }

  Future<void> _onPlzChanged() async {
    final plz = _plzController.text.trim();
    final requestId = ++_plzRequestId;
    if (plz.length != 5) {
      setState(() {
        _resolvedCity = null;
        _plzError = null;
        _draft = _draft.copyWith(lat: null, lng: null, radiusKm: null);
        if (_draft.sort == SortOption.distance) {
          _draft = _draft.copyWith(sort: SortOption.newest);
        }
      });
      return;
    }
    final result = await widget.resolvePlz(plz);
    if (!mounted || requestId != _plzRequestId) return;
    setState(() {
      if (result == null) {
        _resolvedCity = null;
        _plzError = 'Unbekannte Postleitzahl';
        _draft = _draft.copyWith(lat: null, lng: null, radiusKm: null);
      } else {
        _resolvedCity = result.city;
        _plzError = null;
        _draft = _draft.copyWith(lat: result.lat, lng: result.lng);
      }
    });
  }

  bool get _plzResolved => _draft.lat != null && _draft.lng != null;

  void _toggleCondition(ListingCondition condition) {
    final current = _draft.conditions ?? const [];
    final next = current.contains(condition)
        ? current.where((c) => c != condition).toList()
        : [...current, condition];
    setState(
      () => _draft = _draft.copyWith(conditions: next.isEmpty ? null : next),
    );
  }

  void _togglePropulsion(PropulsionType propulsion) {
    final current = _draft.propulsions ?? const [];
    final next = current.contains(propulsion)
        ? current.where((p) => p != propulsion).toList()
        : [...current, propulsion];
    setState(
      () => _draft = _draft.copyWith(propulsions: next.isEmpty ? null : next),
    );
  }

  void _selectCategory(String? slug) {
    setState(
      () => _draft = _draft.copyWith(
        categorySlug: slug,
        minJoule: null,
        maxJoule: null,
        propulsions: null,
      ),
    );
  }

  void _reset() {
    setState(() {
      _draft = ListingFilter(query: widget.initialFilter.query);
      _minPriceController.clear();
      _maxPriceController.clear();
      _plzController.clear();
      _resolvedCity = null;
      _plzError = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return FractionallySizedBox(
      heightFactor: 0.9,
      alignment: Alignment.bottomCenter,
      child: SafeArea(
        child: Column(
          children: [
            Expanded(child: _buildList(context)),
            // Fest statt Teil der scrollbaren Liste: In einem sehr langen
            // ListView wurden Taps auf Buttons ganz am Ende auf dem
            // Test-Emulator zuverlaessig nicht mehr zugestellt (mit einem
            // unveraenderten Flutter-ElevatedButton an derselben Stelle
            // reproduzierbar ausgeschlossen -- AsmButton selbst war es
            // nicht). Als fixe Fusszeile ausserhalb der Liste ist "Anwenden"
            // ausserdem ohne Scrollen immer erreichbar -- ein Plus, keine
            // Notloesung.
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AsmSpacing.md,
                AsmSpacing.sm,
                AsmSpacing.md,
                AsmSpacing.md,
              ),
              child: Column(
                children: [
                  AsmButton(
                    label: 'Alle zurücksetzen',
                    variant: AsmButtonVariant.ghost,
                    onPressed: _reset,
                  ),
                  const SizedBox(height: AsmSpacing.sm),
                  AsmButton(
                    label: 'Anwenden',
                    onPressed: () => Navigator.of(context).pop(_draft),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildList(BuildContext context) {
    return ListView(
      key: const Key('filterSheetList'),
      padding: const EdgeInsets.all(AsmSpacing.md),
      children: [
        const Text('Filter', style: AsmTextStyles.titleL),
        const SizedBox(height: AsmSpacing.lg),
        _CategorySection(
          selectedSlug: _draft.categorySlug,
          onSelect: _selectCategory,
        ),
        const SizedBox(height: AsmSpacing.lg),
        _sectionTitle('Preis'),
        const SizedBox(height: AsmSpacing.sm),
        RangeSlider(
          key: const Key('filterPriceSlider'),
          max: _priceSliderMaxEuro,
          values: RangeValues(
            ((_draft.minPrice ?? 0) / 100).clamp(0, _priceSliderMaxEuro),
            ((_draft.maxPrice ?? _priceSliderMaxEuro * 100) / 100).clamp(
              0,
              _priceSliderMaxEuro,
            ),
          ),
          onChanged: (values) {
            setState(() {
              _draft = _draft.copyWith(
                minPrice: values.start == 0
                    ? null
                    : (values.start * 100).round(),
                maxPrice: values.end >= _priceSliderMaxEuro
                    ? null
                    : (values.end * 100).round(),
              );
              _minPriceController.text = values.start == 0
                  ? ''
                  : values.start.round().toString();
              _maxPriceController.text = values.end >= _priceSliderMaxEuro
                  ? ''
                  : values.end.round().toString();
            });
          },
        ),
        Row(
          children: [
            Expanded(
              child: AsmTextField(
                key: const Key('filterMinPrice'),
                controller: _minPriceController,
                label: 'Min. €',
              ),
            ),
            const SizedBox(width: AsmSpacing.sm),
            Expanded(
              child: AsmTextField(
                key: const Key('filterMaxPrice'),
                controller: _maxPriceController,
                label: 'Max. €',
              ),
            ),
          ],
        ),
        const SizedBox(height: AsmSpacing.lg),
        _sectionTitle('Zustand'),
        const SizedBox(height: AsmSpacing.sm),
        Wrap(
          spacing: AsmSpacing.xs,
          runSpacing: AsmSpacing.xs,
          children: [
            for (final condition in ListingCondition.values)
              AsmChip(
                label: condition.label,
                selected: _draft.conditions?.contains(condition) ?? false,
                onTap: () => _toggleCondition(condition),
              ),
          ],
        ),
        if (_showPropulsionAndJoule) ...[
          const SizedBox(height: AsmSpacing.lg),
          _sectionTitle('Antriebsart'),
          const SizedBox(height: AsmSpacing.sm),
          Wrap(
            spacing: AsmSpacing.xs,
            runSpacing: AsmSpacing.xs,
            children: [
              for (final propulsion in PropulsionType.values)
                AsmChip(
                  label: propulsion.label,
                  selected: _draft.propulsions?.contains(propulsion) ?? false,
                  onTap: () => _togglePropulsion(propulsion),
                ),
            ],
          ),
          const SizedBox(height: AsmSpacing.lg),
          _sectionTitle('Joule-Bereich'),
          const SizedBox(height: AsmSpacing.sm),
          RangeSlider(
            key: const Key('filterJouleSlider'),
            min: 0.1,
            max: 7.5,
            values: RangeValues(
              _draft.minJoule ?? 0.1,
              _draft.maxJoule ?? 7.5,
            ),
            onChanged: (values) => setState(() {
              _draft = _draft.copyWith(
                minJoule: values.start <= 0.1 ? null : values.start,
                maxJoule: values.end >= 7.5 ? null : values.end,
              );
            }),
          ),
        ],
        const SizedBox(height: AsmSpacing.lg),
        _sectionTitle('Versand'),
        const SizedBox(height: AsmSpacing.sm),
        AsmChip(
          label: 'Versand möglich',
          selected: _draft.ships ?? false,
          onTap: () => setState(
            () => _draft = _draft.copyWith(
              ships: (_draft.ships ?? false) ? null : true,
            ),
          ),
        ),
        const SizedBox(height: AsmSpacing.lg),
        _sectionTitle('Ort'),
        const SizedBox(height: AsmSpacing.sm),
        AsmTextField(
          key: const Key('filterPlz'),
          controller: _plzController,
          label: 'Postleitzahl',
          maxLength: 5,
          errorText: _plzError,
        ),
        if (_resolvedCity != null) ...[
          const SizedBox(height: AsmSpacing.xxs),
          Text(
            _resolvedCity!,
            style: AsmTextStyles.bodyS.copyWith(
              color: AsmColors.textSecondary,
            ),
          ),
        ],
        const SizedBox(height: AsmSpacing.sm),
        Wrap(
          spacing: AsmSpacing.xs,
          runSpacing: AsmSpacing.xs,
          children: [
            AsmChip(
              label: 'ganz DE',
              selected: _draft.radiusKm == null,
              onTap: _plzResolved
                  ? () => setState(
                      () => _draft = _draft.copyWith(radiusKm: null),
                    )
                  : null,
            ),
            for (final km in _radiusOptionsKm)
              AsmChip(
                label: '$km km',
                selected: _draft.radiusKm == km,
                onTap: _plzResolved
                    ? () => setState(
                        () => _draft = _draft.copyWith(radiusKm: km),
                      )
                    : null,
              ),
          ],
        ),
        const SizedBox(height: AsmSpacing.lg),
        _sectionTitle('Sortierung'),
        const SizedBox(height: AsmSpacing.sm),
        Wrap(
          spacing: AsmSpacing.xs,
          runSpacing: AsmSpacing.xs,
          children: [
            _sortChip('Neueste', SortOption.newest),
            _sortChip('Preis aufsteigend', SortOption.priceAsc),
            _sortChip('Preis absteigend', SortOption.priceDesc),
            _sortChip(
              'Entfernung',
              SortOption.distance,
              enabled: _plzResolved,
            ),
          ],
        ),
        const SizedBox(height: AsmSpacing.md),
      ],
    );
  }

  bool get _showPropulsionAndJoule {
    final slug = _draft.categorySlug;
    if (slug == null) return false;
    final category = ref.watch(categoryBySlugProvider(slug)).valueOrNull;
    return category != null &&
        (category.requiresJoule || category.requiresPropulsion);
  }

  Widget _sortChip(String label, SortOption option, {bool enabled = true}) {
    return AsmChip(
      label: label,
      selected: _draft.sort == option,
      onTap: enabled
          ? () => setState(() => _draft = _draft.copyWith(sort: option))
          : null,
    );
  }

  Widget _sectionTitle(String label) =>
      Text(label, style: AsmTextStyles.titleS);
}

class _CategorySection extends ConsumerWidget {
  const _CategorySection({required this.selectedSlug, required this.onSelect});

  final String? selectedSlug;
  final ValueChanged<String?> onSelect;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final rootsAsync = ref.watch(rootCategoriesProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Kategorie', style: AsmTextStyles.titleS),
        const SizedBox(height: AsmSpacing.sm),
        rootsAsync.when(
          loading: () => const SizedBox.shrink(),
          error: (error, stackTrace) => const SizedBox.shrink(),
          data: (roots) => Wrap(
            spacing: AsmSpacing.xs,
            runSpacing: AsmSpacing.xs,
            children: [
              AsmChip(
                label: 'Alle',
                selected: selectedSlug == null,
                onTap: () => onSelect(null),
              ),
              for (final root in roots)
                AsmChip(
                  label: root.name,
                  selected: selectedSlug == root.slug,
                  onTap: () => onSelect(root.slug),
                ),
            ],
          ),
        ),
        if (selectedSlug != null)
          Padding(
            padding: const EdgeInsets.only(top: AsmSpacing.xs),
            child: _ChildCategoryChips(
              parentSlug: selectedSlug!,
              selectedSlug: selectedSlug,
              onSelect: onSelect,
            ),
          ),
      ],
    );
  }
}

class _ChildCategoryChips extends ConsumerWidget {
  const _ChildCategoryChips({
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
      data: (children) => children.isEmpty
          ? const SizedBox.shrink()
          : Wrap(
              spacing: AsmSpacing.xs,
              runSpacing: AsmSpacing.xs,
              children: [
                for (final child in children)
                  AsmChip(
                    label: child.name,
                    selected: selectedSlug == child.slug,
                    onTap: () => onSelect(child.slug),
                  ),
              ],
            ),
    );
  }
}
