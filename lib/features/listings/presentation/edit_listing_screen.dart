import 'package:asm/core/theme/asm_colors.dart';
import 'package:asm/core/theme/asm_spacing.dart';
import 'package:asm/core/theme/asm_text_styles.dart';
import 'package:asm/core/utils/plz_lookup.dart';
import 'package:asm/core/widgets/asm_button.dart';
import 'package:asm/core/widgets/asm_checkbox.dart';
import 'package:asm/core/widgets/asm_chip.dart';
import 'package:asm/core/widgets/asm_error_view.dart';
import 'package:asm/core/widgets/asm_skeleton.dart';
import 'package:asm/core/widgets/asm_text_field.dart';
import 'package:asm/features/categories/presentation/category_providers.dart';
import 'package:asm/features/listings/domain/listing.dart';
import 'package:asm/features/listings/presentation/listing_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Einzelner Bearbeiten-Screen (Task 4.3) -- anders als der 4-Schritte-
/// Erstellen-Flow (Task 4.2) eine eigene Seite, siehe 01-DESIGN-SYSTEM.md
/// Abschnitt "Inserat" ("Erstellen (4 Schritte) · Bearbeiten" als zwei
/// getrennte Eintraege). Kategorie und Fotos sind bewusst nicht editierbar:
/// `ListingRepository.update()` kannte Fotos noch nie (die laufen separat
/// ueber `ImageService`), und ein Kategoriewechsel koennte die bestehenden
/// F-Kennzeichen-/Joule-Anforderungen unterlaufen. Siehe DECISIONS.md.
class EditListingScreen extends ConsumerStatefulWidget {
  const EditListingScreen({
    required this.listingId,
    this.resolvePlz = PlzLookup.resolve,
    super.key,
  });

  final String listingId;

  /// Seam statt `PlzLookup.resolve` direkt aufzurufen -- siehe
  /// edit_profile_screen.dart fuer die Begruendung (laedt echt
  /// assets/data/plz.json, haengt in testWidgets an der FakeAsync-Zone).
  final Future<({String city, double lat, double lng})?> Function(String plz)
  resolvePlz;

  @override
  ConsumerState<EditListingScreen> createState() => _EditListingScreenState();
}

class _EditListingScreenState extends ConsumerState<EditListingScreen> {
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _manufacturerController = TextEditingController();
  final _modelController = TextEditingController();
  final _priceController = TextEditingController();
  final _plzController = TextEditingController();

  bool _prefilled = false;
  bool _submitAttempted = false;
  bool _saving = false;
  String? _saveError;

  ListingCondition? _condition;
  double? _joule;
  PropulsionType? _propulsion;
  String? _caliber;
  bool _isModified = false;
  bool _negotiable = false;
  bool _acceptsSwap = false;
  bool _isGiveaway = false;
  bool _ships = false;
  bool _pickupOnly = true;

  String? _resolvedCity;
  double? _resolvedLat;
  double? _resolvedLng;
  String? _plzError;
  int _plzRequestId = 0;

  String? _titleError;
  String? _descriptionError;
  String? _conditionError;
  String? _priceError;
  String? _deliveryError;

  @override
  void initState() {
    super.initState();
    _plzController.addListener(_onPlzChanged);
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _manufacturerController.dispose();
    _modelController.dispose();
    _priceController.dispose();
    _plzController.dispose();
    super.dispose();
  }

  void _prefill(Listing listing) {
    _titleController.text = listing.title;
    _descriptionController.text = listing.description;
    _manufacturerController.text = listing.manufacturer ?? '';
    _modelController.text = listing.model ?? '';
    _priceController.text = (listing.priceCents / 100)
        .toStringAsFixed(2)
        .replaceAll('.', ',');
    _plzController.text = listing.postalCode;
    _condition = listing.condition;
    _joule = listing.joule;
    _propulsion = listing.propulsion;
    _caliber = listing.caliber;
    _isModified = listing.isModified;
    _negotiable = listing.negotiable;
    _acceptsSwap = listing.acceptsSwap;
    _isGiveaway = listing.isGiveaway;
    _ships = listing.ships;
    _pickupOnly = listing.pickupOnly;
    _resolvedCity = listing.city;
    _resolvedLat = listing.lat;
    _resolvedLng = listing.lng;
  }

  Future<void> _onPlzChanged() async {
    final plz = _plzController.text.trim();
    final requestId = ++_plzRequestId;
    if (plz.length != 5) {
      setState(() {
        _resolvedCity = null;
        _resolvedLat = null;
        _resolvedLng = null;
        _plzError = null;
      });
      return;
    }
    final result = await widget.resolvePlz(plz);
    if (!mounted || requestId != _plzRequestId) return;
    setState(() {
      if (result == null) {
        _resolvedCity = null;
        _resolvedLat = null;
        _resolvedLng = null;
        _plzError = 'Unbekannte Postleitzahl';
      } else {
        _resolvedCity = result.city;
        _resolvedLat = result.lat;
        _resolvedLng = result.lng;
        _plzError = null;
      }
    });
  }

  int? _parseEuro(String text) {
    final value = double.tryParse(text.trim().replaceAll(',', '.'));
    if (value == null) return null;
    return (value * 100).round();
  }

  bool _showPropulsionFields(String categoryId) {
    final category = ref.watch(categoryByIdProvider(categoryId)).valueOrNull;
    return category != null &&
        (category.requiresJoule || category.requiresPropulsion);
  }

  bool _validate({required bool showPropulsionFields}) {
    setState(() {
      final title = _titleController.text.trim();
      _titleError = title.length < 10 || title.length > 80
          ? 'Zwischen 10 und 80 Zeichen'
          : null;
      final description = _descriptionController.text.trim();
      _descriptionError = description.length < 30 || description.length > 5000
          ? 'Mindestens 30 Zeichen'
          : null;
      _conditionError = _condition == null ? 'Bitte auswaehlen' : null;
      final price = _isGiveaway ? 0 : _parseEuro(_priceController.text);
      _priceError = !_isGiveaway && price == null
          ? 'Bitte einen Preis angeben'
          : null;
      _deliveryError = !(_ships || _pickupOnly)
          ? 'Abholung oder Versand waehlen'
          : null;
    });
    return _titleError == null &&
        _descriptionError == null &&
        _conditionError == null &&
        _priceError == null &&
        _deliveryError == null &&
        _resolvedCity != null;
  }

  Future<void> _save(Listing original) async {
    setState(() => _submitAttempted = true);
    final showPropulsion = _showPropulsionFields(original.categoryId);
    if (!_validate(showPropulsionFields: showPropulsion)) return;

    setState(() {
      _saving = true;
      _saveError = null;
    });
    try {
      final draft = ListingDraft(
        categoryId: original.categoryId,
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
        priceCents: _isGiveaway ? 0 : _parseEuro(_priceController.text)!,
        condition: _condition!,
        postalCode: _plzController.text.trim(),
        city: _resolvedCity!,
        lat: _resolvedLat!,
        lng: _resolvedLng!,
        negotiable: _negotiable,
        isGiveaway: _isGiveaway,
        acceptsSwap: _acceptsSwap,
        manufacturer: _manufacturerController.text.trim().isEmpty
            ? null
            : _manufacturerController.text.trim(),
        model: _modelController.text.trim().isEmpty
            ? null
            : _modelController.text.trim(),
        joule: showPropulsion ? _joule : null,
        propulsion: showPropulsion ? _propulsion : null,
        caliber: showPropulsion ? _caliber : null,
        hasFMarking: original.hasFMarking,
        isModified: showPropulsion && _isModified,
        ships: _ships,
        pickupOnly: _pickupOnly,
      );
      await ref.read(listingRepositoryProvider).update(original.id, draft);
      refreshSellerListings(
        ref,
        sellerId: original.sellerId,
        listingId: original.id,
      );
      if (!mounted) return;
      Navigator.of(context).pop();
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final listingAsync = ref.watch(listingByIdProvider(widget.listingId));

    return Scaffold(
      appBar: AppBar(title: const Text('Inserat bearbeiten')),
      body: listingAsync.when(
        loading: () => const Padding(
          padding: EdgeInsets.all(AsmSpacing.md),
          child: AsmSkeleton.detail(),
        ),
        error: (error, stackTrace) => AsmErrorView(
          message: 'Inserat konnte nicht geladen werden',
          onRetry: () => ref.invalidate(listingByIdProvider(widget.listingId)),
        ),
        data: (listing) {
          if (!_prefilled) {
            _prefilled = true;
            _prefill(listing);
          }
          return _buildForm(listing);
        },
      ),
    );
  }

  Widget _buildForm(Listing listing) {
    final showErrors = _submitAttempted;
    final showPropulsion = _showPropulsionFields(listing.categoryId);

    return Column(
      children: [
        Expanded(
          child: ListView(
            key: const Key('editListingList'),
            padding: const EdgeInsets.all(AsmSpacing.md),
            children: [
              AsmTextField(
                key: const Key('editListingTitle'),
                controller: _titleController,
                label: 'Titel',
                errorText: showErrors ? _titleError : null,
                maxLength: 80,
              ),
              const SizedBox(height: AsmSpacing.md),
              AsmTextField(
                key: const Key('editListingDescription'),
                controller: _descriptionController,
                label: 'Beschreibung',
                errorText: showErrors ? _descriptionError : null,
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
              if (showErrors && _conditionError != null)
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
                key: const Key('editListingModel'),
                controller: _modelController,
                label: 'Modell',
              ),
              if (showPropulsion) ...[
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
                  key: const Key('editListingJoule'),
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
                  key: const Key('editListingPrice'),
                  controller: _priceController,
                  label: 'Preis in €',
                  errorText: showErrors ? _priceError : null,
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
              const SizedBox(height: AsmSpacing.lg),
              const Text('Versand', style: AsmTextStyles.titleS),
              const SizedBox(height: AsmSpacing.sm),
              AsmCheckbox(
                value: _pickupOnly,
                onChanged: (v) => setState(() => _pickupOnly = v),
                label: const Text('Abholung'),
              ),
              const SizedBox(height: AsmSpacing.sm),
              AsmCheckbox(
                value: _ships,
                onChanged: (v) => setState(() => _ships = v),
                label: const Text('Versand möglich'),
              ),
              if (showErrors && _deliveryError != null)
                Padding(
                  padding: const EdgeInsets.only(top: AsmSpacing.xxs),
                  child: Text(
                    _deliveryError!,
                    style: AsmTextStyles.bodyS.copyWith(
                      color: AsmColors.dangerText,
                    ),
                  ),
                ),
              const SizedBox(height: AsmSpacing.lg),
              const Text('Ort', style: AsmTextStyles.titleS),
              const SizedBox(height: AsmSpacing.sm),
              AsmTextField(
                key: const Key('editListingPlz'),
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
              if (_saveError != null) ...[
                const SizedBox(height: AsmSpacing.md),
                Text(
                  _saveError!,
                  style: AsmTextStyles.bodyS.copyWith(
                    color: AsmColors.dangerText,
                  ),
                ),
              ],
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(AsmSpacing.md),
          child: AsmButton(
            key: const Key('editListingSave'),
            label: 'Speichern',
            isLoading: _saving,
            onPressed: _saving ? null : () => _save(listing),
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
        textController.addListener(() => controller.text = textController.text);
        return AsmTextField(
          key: const Key('editListingManufacturer'),
          controller: textController,
          focusNode: focusNode,
          label: 'Hersteller',
        );
      },
    );
  }
}
