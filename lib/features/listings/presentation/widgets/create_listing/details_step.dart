import 'package:asm/core/theme/asm_colors.dart';
import 'package:asm/core/theme/asm_spacing.dart';
import 'package:asm/core/theme/asm_text_styles.dart';
import 'package:asm/core/widgets/asm_button.dart';
import 'package:asm/core/widgets/asm_checkbox.dart';
import 'package:asm/core/widgets/asm_chip.dart';
import 'package:asm/core/widgets/asm_text_field.dart';
import 'package:asm/features/categories/presentation/category_providers.dart';
import 'package:asm/features/listings/domain/create_listing_draft.dart';
import 'package:asm/features/listings/domain/listing.dart';
import 'package:asm/features/listings/presentation/create_listing_providers.dart';
import 'package:asm/features/listings/presentation/listing_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Schritt 3: Titel, Beschreibung, Zustand, Hersteller (Autocomplete),
/// Modell, bei Bedarf (Kategorie verlangt Joule/Antriebsart) zusaetzlich
/// Joule, Antriebsart, Kaliber, "umgebaut", dazu Preis, VB, Tausch,
/// Verschenken.
class DetailsStep extends ConsumerStatefulWidget {
  const DetailsStep({required this.onNext, super.key});

  final VoidCallback onNext;

  @override
  ConsumerState<DetailsStep> createState() => _DetailsStepState();
}

class _DetailsStepState extends ConsumerState<DetailsStep> {
  // Nur beim allerersten Aufbau gelesen (befuellt die Controller/lokalen
  // Felder unten) -- danach ist der Draft ausschliesslich lokaler State bis
  // "Weiter" ihn zurueckschreibt.
  late final CreateListingDraft _initialDraft = ref.read(
    createListingDraftProvider,
  );

  late final _titleController = TextEditingController(
    text: _initialDraft.title ?? '',
  );
  late final _descriptionController = TextEditingController(
    text: _initialDraft.description ?? '',
  );
  late final _manufacturerController = TextEditingController(
    text: _initialDraft.manufacturer ?? '',
  );
  late final _modelController = TextEditingController(
    text: _initialDraft.model ?? '',
  );
  late final _priceController = TextEditingController(
    text: _initialDraft.priceCents != null
        ? (_initialDraft.priceCents! / 100).toStringAsFixed(2)
        : '',
  );

  late ListingCondition? _condition = _initialDraft.condition;
  late double? _joule = _initialDraft.joule;
  late PropulsionType? _propulsion = _initialDraft.propulsion;
  late String? _caliber = _initialDraft.caliber;
  late bool _isModified = _initialDraft.isModified;
  late bool _negotiable = _initialDraft.negotiable;
  late bool _acceptsSwap = _initialDraft.acceptsSwap;
  late bool _isGiveaway = _initialDraft.isGiveaway;

  String? _titleError;
  String? _descriptionError;
  String? _conditionError;
  String? _priceError;

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _manufacturerController.dispose();
    _modelController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  bool get _showPropulsionFields {
    final draft = ref.watch(createListingDraftProvider);
    if (draft.categoryId == null) return false;
    final category = ref
        .watch(categoryByIdProvider(draft.categoryId!))
        .valueOrNull;
    return category != null &&
        (category.requiresJoule || category.requiresPropulsion);
  }

  int? _parseEuro(String text) {
    final value = double.tryParse(text.trim().replaceAll(',', '.'));
    if (value == null) return null;
    return (value * 100).round();
  }

  bool _validate() {
    setState(() {
      final title = _titleController.text.trim();
      _titleError = title.length < 10 || title.length > 80
          ? 'Zwischen 10 und 80 Zeichen'
          : null;
      final description = _descriptionController.text.trim();
      _descriptionError = description.length < 15 || description.length > 5000
          ? 'Mindestens 15 Zeichen'
          : null;
      _conditionError = _condition == null ? 'Bitte auswaehlen' : null;
      final price = _isGiveaway ? 0 : _parseEuro(_priceController.text);
      _priceError = !_isGiveaway && price == null
          ? 'Bitte einen Preis angeben'
          : null;
    });
    return _titleError == null &&
        _descriptionError == null &&
        _conditionError == null &&
        _priceError == null;
  }

  Future<void> _next() async {
    if (!_validate()) return;
    final priceCents = _isGiveaway ? 0 : _parseEuro(_priceController.text);
    await updateCreateListingDraft(
      ref,
      (d) => d.copyWith(
        step: 3,
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
        condition: _condition,
        manufacturer: _manufacturerController.text.trim().isEmpty
            ? null
            : _manufacturerController.text.trim(),
        model: _modelController.text.trim().isEmpty
            ? null
            : _modelController.text.trim(),
        joule: _showPropulsionFields ? _joule : null,
        propulsion: _showPropulsionFields ? _propulsion : null,
        caliber: _showPropulsionFields ? _caliber : null,
        isModified: _showPropulsionFields && _isModified,
        priceCents: priceCents,
        negotiable: _negotiable,
        acceptsSwap: _acceptsSwap,
        isGiveaway: _isGiveaway,
      ),
    );
    widget.onNext();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: ListView(
            key: const Key('detailsStepList'),
            padding: const EdgeInsets.all(AsmSpacing.md),
            children: [
              AsmTextField(
                key: const Key('detailsStepTitle'),
                controller: _titleController,
                label: 'Titel',
                errorText: _titleError,
                maxLength: 80,
              ),
              const SizedBox(height: AsmSpacing.md),
              AsmTextField(
                key: const Key('detailsStepDescription'),
                controller: _descriptionController,
                label: 'Beschreibung',
                errorText: _descriptionError,
                maxLines: 5,
                maxLength: 5000,
              ),
              const SizedBox(height: AsmSpacing.lg),
              const Text('Zustand', style: AsmTextStyles.titleS),
              const SizedBox(height: AsmSpacing.sm),
              Wrap(
                spacing: AsmSpacing.xs,
                runSpacing: AsmSpacing.xs,
                children: [
                  for (final condition in ListingCondition.values)
                    AsmChip(
                      label: condition.label,
                      selected: _condition == condition,
                      onTap: () => setState(() => _condition = condition),
                    ),
                ],
              ),
              if (_conditionError != null)
                Padding(
                  padding: const EdgeInsets.only(top: AsmSpacing.xxs),
                  child: Text(
                    _conditionError!,
                    style: AsmTextStyles.bodyS.copyWith(
                      color: AsmColors.dangerText,
                    ),
                  ),
                ),
              const SizedBox(height: AsmSpacing.lg),
              _ManufacturerField(controller: _manufacturerController),
              const SizedBox(height: AsmSpacing.md),
              AsmTextField(
                key: const Key('detailsStepModel'),
                controller: _modelController,
                label: 'Modell',
              ),
              if (_showPropulsionFields) ...[
                const SizedBox(height: AsmSpacing.lg),
                const Text('Antriebsart', style: AsmTextStyles.titleS),
                const SizedBox(height: AsmSpacing.sm),
                Wrap(
                  spacing: AsmSpacing.xs,
                  runSpacing: AsmSpacing.xs,
                  children: [
                    for (final propulsion in PropulsionType.values)
                      AsmChip(
                        label: propulsion.label,
                        selected: _propulsion == propulsion,
                        onTap: () => setState(() => _propulsion = propulsion),
                      ),
                  ],
                ),
                const SizedBox(height: AsmSpacing.lg),
                Text(
                  'Joule: ${(_joule ?? 0.5).toStringAsFixed(2)}',
                  style: AsmTextStyles.titleS,
                ),
                Slider(
                  key: const Key('detailsStepJoule'),
                  min: 0.1,
                  max: 7.5,
                  value: (_joule ?? 0.5).clamp(0.1, 7.5),
                  onChanged: (v) => setState(() => _joule = v),
                ),
                const SizedBox(height: AsmSpacing.md),
                const Text('Kaliber', style: AsmTextStyles.titleS),
                const SizedBox(height: AsmSpacing.sm),
                Wrap(
                  spacing: AsmSpacing.xs,
                  children: [
                    for (final caliber in const ['6mm', '8mm'])
                      AsmChip(
                        label: caliber,
                        selected: _caliber == caliber,
                        onTap: () => setState(() => _caliber = caliber),
                      ),
                  ],
                ),
                const SizedBox(height: AsmSpacing.md),
                AsmCheckbox(
                  value: _isModified,
                  onChanged: (v) => setState(() => _isModified = v),
                  label: const Text('Umgebaut (Antriebsart geaendert)'),
                ),
              ],
              const SizedBox(height: AsmSpacing.lg),
              AsmCheckbox(
                value: _isGiveaway,
                onChanged: (v) => setState(() {
                  _isGiveaway = v;
                  if (v) _priceController.clear();
                }),
                label: const Text('Verschenken'),
              ),
              if (!_isGiveaway) ...[
                const SizedBox(height: AsmSpacing.md),
                AsmTextField(
                  key: const Key('detailsStepPrice'),
                  controller: _priceController,
                  label: 'Preis in €',
                  errorText: _priceError,
                ),
                const SizedBox(height: AsmSpacing.md),
                AsmCheckbox(
                  value: _negotiable,
                  onChanged: (v) => setState(() => _negotiable = v),
                  label: const Text('Verhandlungsbasis (VB)'),
                ),
                const SizedBox(height: AsmSpacing.md),
                AsmCheckbox(
                  value: _acceptsSwap,
                  onChanged: (v) => setState(() => _acceptsSwap = v),
                  label: const Text('Tausch möglich'),
                ),
              ],
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(AsmSpacing.md),
          child: AsmButton(
            key: const Key('detailsStepNext'),
            label: 'Weiter',
            onPressed: _next,
          ),
        ),
      ],
    );
  }
}

class _ManufacturerField extends ConsumerWidget {
  const _ManufacturerField({required this.controller});

  final TextEditingController controller;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final manufacturersAsync = ref.watch(manufacturersProvider);
    final options = manufacturersAsync.valueOrNull ?? const <String>[];

    return Autocomplete<String>(
      initialValue: TextEditingValue(text: controller.text),
      optionsBuilder: (value) {
        if (value.text.trim().isEmpty) return const Iterable.empty();
        final query = value.text.toLowerCase();
        return options.where((o) => o.toLowerCase().contains(query));
      },
      onSelected: (selection) => controller.text = selection,
      fieldViewBuilder: (context, textController, focusNode, onSubmit) {
        // `Autocomplete` fuehrt seinen eigenen Controller -- mit dem von
        // aussen uebergebenen synchron halten, damit der Draft beim
        // Weiterblaettern den richtigen Wert liest.
        textController.addListener(() => controller.text = textController.text);
        return AsmTextField(
          key: const Key('detailsStepManufacturer'),
          controller: textController,
          focusNode: focusNode,
          label: 'Hersteller',
        );
      },
    );
  }
}
