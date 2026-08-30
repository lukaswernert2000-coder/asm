import 'dart:io';

import 'package:asm/core/errors/app_exception.dart';
import 'package:asm/core/router/routes.dart';
import 'package:asm/core/theme/asm_colors.dart';
import 'package:asm/core/theme/asm_spacing.dart';
import 'package:asm/core/theme/asm_text_styles.dart';
import 'package:asm/core/utils/formatters.dart';
import 'package:asm/core/utils/plz_lookup.dart';
import 'package:asm/core/widgets/asm_button.dart';
import 'package:asm/core/widgets/asm_checkbox.dart';
import 'package:asm/core/widgets/asm_text_field.dart';
import 'package:asm/features/listings/domain/create_listing_draft.dart';
import 'package:asm/features/listings/domain/listing.dart';
import 'package:asm/features/listings/presentation/create_listing_providers.dart';
import 'package:asm/features/listings/presentation/listing_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:share_plus/share_plus.dart';

/// Schritt 4: Versand/Abholung, PLZ, Vorschau, Veroeffentlichen. Erst hier
/// entsteht die DB-Zeile -- vorher lebt alles nur lokal (siehe
/// CreateListingDraft).
class ShippingStep extends ConsumerStatefulWidget {
  const ShippingStep({
    super.key,
    Future<({String city, double lat, double lng})?> Function(String plz)?
    resolvePlz,
  }) : resolvePlz = resolvePlz ?? PlzLookup.resolve;

  final Future<({String city, double lat, double lng})?> Function(String plz)
  resolvePlz;

  @override
  ConsumerState<ShippingStep> createState() => _ShippingStepState();
}

class _ShippingStepState extends ConsumerState<ShippingStep> {
  late final CreateListingDraft _initialDraft = ref.read(
    createListingDraftProvider,
  );
  late final _plzController = TextEditingController(
    text: _initialDraft.postalCode ?? '',
  );

  late bool _ships = _initialDraft.ships;
  late bool _pickupOnly = _initialDraft.pickupOnly;
  String? _resolvedCity;
  double? _resolvedLat;
  double? _resolvedLng;
  String? _plzError;
  int _plzRequestId = 0;
  bool _publishing = false;
  String? _publishError;
  String? _publishedListingId;

  @override
  void initState() {
    super.initState();
    _resolvedCity = _initialDraft.city;
    _resolvedLat = _initialDraft.lat;
    _resolvedLng = _initialDraft.lng;
    _plzController.addListener(_onPlzChanged);
  }

  @override
  void dispose() {
    _plzController.dispose();
    super.dispose();
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

  /// [draft] allein reicht nicht -- postalCode/city/lat/lng sind erst nach
  /// dem Veroeffentlichen-Tap gemergt (siehe [_publish]), bis dahin leben sie
  /// nur in [_resolvedCity] & Co. Deshalb hier mit den lokalen Werten
  /// zusammenfuehren, statt nur den (in dieser Hinsicht noch unvollstaendigen)
  /// Provider-Draft zu pruefen.
  bool _canPublish(CreateListingDraft draft) {
    if (!(_ships || _pickupOnly) || _resolvedCity == null) return false;
    return draft
        .copyWith(
          postalCode: _plzController.text.trim(),
          city: _resolvedCity,
          lat: _resolvedLat,
          lng: _resolvedLng,
        )
        .isCompleteEnoughToPublish;
  }

  Future<void> _publish() async {
    // Der Button ist bis _canPublish() erst per onPressed gesperrt -- hier
    // angekommen sind PLZ und Versandart also bereits gueltig.
    setState(() {
      _publishing = true;
      _publishError = null;
    });
    try {
      final repository = ref.read(listingRepositoryProvider);
      final imageService = ref.read(imageServiceProvider);
      var draft = ref
          .read(createListingDraftProvider)
          .copyWith(
            postalCode: _plzController.text.trim(),
            city: _resolvedCity,
            lat: _resolvedLat,
            lng: _resolvedLng,
            ships: _ships,
            pickupOnly: _pickupOnly,
          );
      final finalDraft = draft.toListingDraft();

      final String listingId;
      if (_publishedListingId != null) {
        // Erneuter Versuch nach zuvor fehlgeschlagenem Bild-Upload/Status-
        // Wechsel -- Zeile existiert schon, nicht nochmal anlegen.
        listingId = _publishedListingId!;
        await repository.update(listingId, finalDraft);
      } else {
        listingId = await repository.create(finalDraft);
      }
      _publishedListingId = listingId;

      final updatedImages = <DraftImage>[];
      for (final image in draft.images) {
        if (image.uploadedPath != null) {
          updatedImages.add(image);
          continue;
        }
        final path = await imageService.upload(
          File(image.localPath),
          listingId: listingId,
          kind: image.kind,
        );
        updatedImages.add(image.copyWith(uploadedPath: path));
      }
      draft = draft.copyWith(images: updatedImages);
      await updateCreateListingDraft(ref, (_) => draft);

      await repository.setStatus(listingId, ListingStatus.active);
      await clearCreateListingDraft(ref);

      if (!mounted) return;
      await Navigator.of(context).pushReplacement<void, void>(
        MaterialPageRoute(
          builder: (_) => _PublishSuccessScreen(listingId: listingId),
        ),
      );
    } on AppException catch (error) {
      if (!mounted) return;
      setState(() => _publishError = error.message);
    } finally {
      if (mounted) setState(() => _publishing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final draft = ref.watch(createListingDraftProvider);

    return Column(
      children: [
        Expanded(
          child: ListView(
            key: const Key('shippingStepList'),
            padding: const EdgeInsets.all(AsmSpacing.md),
            children: [
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
              const SizedBox(height: AsmSpacing.lg),
              const Text('Ort', style: AsmTextStyles.titleS),
              const SizedBox(height: AsmSpacing.sm),
              AsmTextField(
                key: const Key('shippingStepPlz'),
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
              const SizedBox(height: AsmSpacing.xl),
              const Text('Vorschau', style: AsmTextStyles.titleS),
              const SizedBox(height: AsmSpacing.sm),
              _Preview(draft: draft),
              if (_publishError != null) ...[
                const SizedBox(height: AsmSpacing.md),
                Text(
                  _publishError!,
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
            key: const Key('shippingStepPublish'),
            label: 'Veröffentlichen',
            isLoading: _publishing,
            onPressed: (_publishing || !_canPublish(draft)) ? null : _publish,
          ),
        ),
      ],
    );
  }
}

class _Preview extends StatelessWidget {
  const _Preview({required this.draft});

  final CreateListingDraft draft;

  @override
  Widget build(BuildContext context) {
    final titleImage = draft.images
        .where((i) => i.kind == ImageKind.photo)
        .firstOrNull;

    return Container(
      padding: const EdgeInsets.all(AsmSpacing.md),
      decoration: BoxDecoration(
        color: AsmColors.surfaceRaised,
        borderRadius: BorderRadius.circular(AsmRadius.md),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(AsmRadius.sm),
            child: titleImage != null
                ? Image.file(
                    File(titleImage.localPath),
                    width: 72,
                    height: 72,
                    fit: BoxFit.cover,
                  )
                : Container(width: 72, height: 72, color: AsmColors.surface),
          ),
          const SizedBox(width: AsmSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  draft.title ?? '(kein Titel)',
                  style: AsmTextStyles.titleS,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: AsmSpacing.xxs),
                Text(
                  draft.isGiveaway
                      ? 'Verschenken'
                      : Formatters.price(draft.priceCents ?? 0),
                  style: AsmTextStyles.bodyM.copyWith(
                    color: AsmColors.brandBright,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PublishSuccessScreen extends StatelessWidget {
  const _PublishSuccessScreen({required this.listingId});

  final String listingId;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AsmColors.bg,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(AsmSpacing.xl),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.check_circle,
                color: AsmColors.success,
                size: 64,
              ),
              const SizedBox(height: AsmSpacing.lg),
              const Text(
                'Inserat veröffentlicht!',
                style: AsmTextStyles.titleL,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AsmSpacing.xxl),
              AsmButton(
                key: const Key('publishSuccessView'),
                label: 'Inserat ansehen',
                onPressed: () => context.go(AsmRoutes.listing(listingId)),
              ),
              const SizedBox(height: AsmSpacing.sm),
              AsmButton(
                key: const Key('publishSuccessShare'),
                label: 'Teilen',
                variant: AsmButtonVariant.secondary,
                onPressed: () => SharePlus.instance.share(
                  ShareParams(
                    text:
                        'Schau dir mein Inserat auf ASM an: '
                        'https://asm-app.de/listing/$listingId',
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
