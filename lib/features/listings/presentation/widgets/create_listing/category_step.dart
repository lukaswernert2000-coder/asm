import 'package:asm/core/theme/asm_colors.dart';
import 'package:asm/core/theme/asm_spacing.dart';
import 'package:asm/core/theme/asm_text_styles.dart';
import 'package:asm/core/widgets/asm_button.dart';
import 'package:asm/core/widgets/asm_chip.dart';
import 'package:asm/core/widgets/asm_text_field.dart';
import 'package:asm/features/categories/domain/category.dart';
import 'package:asm/features/categories/presentation/category_providers.dart';
import 'package:asm/features/listings/presentation/create_listing_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Schritt 1: Kategorie waehlen, zwei Ebenen, Suchfeld ueber allen
/// Kategorien. Jede Kategorie hat hier genau eine Ebene Kinder (siehe
/// categories.sql) -- nur ein Kind ist ueberhaupt waehlbar, ein Wurzelknoten
/// allein reicht nicht zum Weiterblaettern.
class CategoryStep extends ConsumerStatefulWidget {
  const CategoryStep({required this.onNext, super.key});

  final VoidCallback onNext;

  @override
  ConsumerState<CategoryStep> createState() => _CategoryStepState();
}

class _CategoryStepState extends ConsumerState<CategoryStep> {
  final _searchController = TextEditingController();
  String? _expandedRootSlug;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final draft = ref.watch(createListingDraftProvider);
    final query = _searchController.text.trim();

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(AsmSpacing.md),
          child: AsmTextField(
            key: const Key('categoryStepSearch'),
            controller: _searchController,
            label: 'Kategorie suchen',
          ),
        ),
        Expanded(
          child: query.isEmpty
              ? _RootAndChildrenList(
                  selectedCategoryId: draft.categoryId,
                  expandedRootSlug: _expandedRootSlug,
                  onExpandRoot: (slug) =>
                      setState(() => _expandedRootSlug = slug),
                  onSelectLeaf: _selectLeaf,
                )
              : _SearchResults(
                  query: query,
                  selectedCategoryId: draft.categoryId,
                  onSelectLeaf: _selectLeaf,
                ),
        ),
        Padding(
          padding: const EdgeInsets.all(AsmSpacing.md),
          child: AsmButton(
            key: const Key('categoryStepNext'),
            label: 'Weiter',
            onPressed: draft.categoryId != null
                ? () async {
                    await updateCreateListingDraft(
                      ref,
                      (d) => d.copyWith(step: 1),
                    );
                    widget.onNext();
                  }
                : null,
          ),
        ),
      ],
    );
  }

  Future<void> _selectLeaf(Category category) async {
    await updateCreateListingDraft(
      ref,
      (d) => d.copyWith(categoryId: category.id),
    );
  }
}

class _RootAndChildrenList extends ConsumerWidget {
  const _RootAndChildrenList({
    required this.selectedCategoryId,
    required this.expandedRootSlug,
    required this.onExpandRoot,
    required this.onSelectLeaf,
  });

  final String? selectedCategoryId;
  final String? expandedRootSlug;
  final ValueChanged<String> onExpandRoot;
  final ValueChanged<Category> onSelectLeaf;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final rootsAsync = ref.watch(rootCategoriesProvider);

    return rootsAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stackTrace) =>
          const Center(child: Text('Kategorien konnten nicht geladen werden.')),
      data: (roots) => ListView(
        key: const Key('categoryStepRootList'),
        padding: const EdgeInsets.symmetric(horizontal: AsmSpacing.md),
        children: [
          for (final root in roots)
            _RootTile(
              root: root,
              expanded: expandedRootSlug == root.slug,
              selectedCategoryId: selectedCategoryId,
              onTap: () => onExpandRoot(root.slug),
              onSelectLeaf: onSelectLeaf,
            ),
        ],
      ),
    );
  }
}

class _RootTile extends ConsumerWidget {
  const _RootTile({
    required this.root,
    required this.expanded,
    required this.selectedCategoryId,
    required this.onTap,
    required this.onSelectLeaf,
  });

  final Category root;
  final bool expanded;
  final String? selectedCategoryId;
  final VoidCallback onTap;
  final ValueChanged<Category> onSelectLeaf;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: AsmSpacing.sm),
            child: Row(
              children: [
                Expanded(
                  child: Text(root.name, style: AsmTextStyles.titleS),
                ),
                Icon(
                  expanded ? Icons.expand_less : Icons.expand_more,
                  color: AsmColors.textSecondary,
                ),
              ],
            ),
          ),
        ),
        if (expanded)
          _ChildrenWrap(
            parentSlug: root.slug,
            selectedCategoryId: selectedCategoryId,
            onSelectLeaf: onSelectLeaf,
          ),
      ],
    );
  }
}

class _ChildrenWrap extends ConsumerWidget {
  const _ChildrenWrap({
    required this.parentSlug,
    required this.selectedCategoryId,
    required this.onSelectLeaf,
  });

  final String parentSlug;
  final String? selectedCategoryId;
  final ValueChanged<Category> onSelectLeaf;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final childrenAsync = ref.watch(categoryChildrenProvider(parentSlug));

    return Padding(
      padding: const EdgeInsets.only(bottom: AsmSpacing.sm),
      child: childrenAsync.when(
        loading: () => const SizedBox.shrink(),
        error: (error, stackTrace) => const SizedBox.shrink(),
        data: (children) => Wrap(
          spacing: AsmSpacing.xs,
          runSpacing: AsmSpacing.xs,
          children: [
            for (final child in children)
              AsmChip(
                label: child.name,
                selected: selectedCategoryId == child.id,
                onTap: () => onSelectLeaf(child),
              ),
          ],
        ),
      ),
    );
  }
}

class _SearchResults extends ConsumerWidget {
  const _SearchResults({
    required this.query,
    required this.selectedCategoryId,
    required this.onSelectLeaf,
  });

  final String query;
  final String? selectedCategoryId;
  final ValueChanged<Category> onSelectLeaf;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final allAsync = ref.watch(allCategoriesProvider);

    return allAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stackTrace) =>
          const Center(child: Text('Kategorien konnten nicht geladen werden.')),
      data: (all) {
        final lowerQuery = query.toLowerCase();
        // Nur Kinder sind waehlbare Blaetter (siehe categories.sql: jede
        // Wurzel hat mindestens ein Kind, es gibt keine blattfoermigen
        // Wurzeln).
        final results = all
            .where(
              (c) =>
                  c.parentId != null &&
                  c.name.toLowerCase().contains(lowerQuery),
            )
            .toList();

        if (results.isEmpty) {
          return const Center(child: Text('Keine Kategorie gefunden.'));
        }
        return ListView(
          key: const Key('categoryStepSearchList'),
          padding: const EdgeInsets.symmetric(horizontal: AsmSpacing.md),
          children: [
            for (final category in results)
              ListTile(
                key: Key('categoryResult_${category.slug}'),
                title: Text(category.name),
                selected: selectedCategoryId == category.id,
                onTap: () => onSelectLeaf(category),
              ),
          ],
        );
      },
    );
  }
}
