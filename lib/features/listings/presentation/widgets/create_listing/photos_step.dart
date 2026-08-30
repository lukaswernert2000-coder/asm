import 'dart:async';
import 'dart:io';

import 'package:asm/core/theme/asm_colors.dart';
import 'package:asm/core/theme/asm_spacing.dart';
import 'package:asm/core/theme/asm_text_styles.dart';
import 'package:asm/core/utils/formatters.dart';
import 'package:asm/core/widgets/asm_button.dart';
import 'package:asm/features/categories/presentation/category_providers.dart';
import 'package:asm/features/listings/domain/create_listing_draft.dart';
import 'package:asm/features/listings/domain/listing.dart';
import 'package:asm/features/listings/presentation/create_listing_providers.dart';
import 'package:asm/features/listings/presentation/listing_providers.dart';
import 'package:asm/features/profile/presentation/profile_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:reorderable_grid_view/reorderable_grid_view.dart';

const _maxPhotos = 12;
const _thumbSize = 96.0;

/// Schritt 2: Foto-Grid (Drag-to-Reorder, erstes Bild = Titelbild, 1-12
/// Stueck) plus die zwei Einzel-Pflicht-Slots F-Kennzeichen (nur wenn die
/// Kategorie es verlangt) und Besitznachweis (immer).
class PhotosStep extends ConsumerStatefulWidget {
  const PhotosStep({required this.onNext, super.key});

  final VoidCallback onNext;

  @override
  ConsumerState<PhotosStep> createState() => _PhotosStepState();
}

class _PhotosStepState extends ConsumerState<PhotosStep> {
  bool _busy = false;

  Future<void> _addPhotos() async {
    final draft = ref.read(createListingDraftProvider);
    final currentPhotos = draft.images
        .where((i) => i.kind == ImageKind.photo)
        .length;
    final remaining = _maxPhotos - currentPhotos;
    if (remaining <= 0 || _busy) return;
    final source = await _askSource(context);
    if (source == null) return;
    await _runBusy(() async {
      final imageService = ref.read(imageServiceProvider);
      final List<XFile> picked;
      if (source == _Source.gallery) {
        picked = await imageService.pickFromGallery(max: remaining);
      } else {
        final photo = await imageService.pickFromCamera();
        picked = photo == null ? [] : [photo];
      }
      final compressedImages = <DraftImage>[];
      for (final xfile in picked) {
        final compressed = await imageService.compress(File(xfile.path));
        compressedImages.add(
          DraftImage(localPath: compressed.path, kind: ImageKind.photo),
        );
      }
      if (compressedImages.isEmpty) return;
      await updateCreateListingDraft(
        ref,
        (d) => d.copyWith(images: [...d.images, ...compressedImages]),
      );
    });
  }

  Future<void> _pickSingle(ImageKind kind) async {
    if (_busy) return;
    final source = await _askSource(context);
    if (source == null) return;
    await _runBusy(() async {
      final imageService = ref.read(imageServiceProvider);
      final xfile = source == _Source.gallery
          ? (await imageService.pickFromGallery(max: 1)).firstOrNull
          : await imageService.pickFromCamera();
      if (xfile == null) return;
      final compressed = await imageService.compress(File(xfile.path));
      await updateCreateListingDraft(ref, (d) {
        final withoutKind = d.images.where((i) => i.kind != kind).toList();
        return d.copyWith(
          images: [
            ...withoutKind,
            DraftImage(localPath: compressed.path, kind: kind),
          ],
        );
      });
    });
  }

  Future<void> _runBusy(Future<void> Function() action) async {
    setState(() => _busy = true);
    try {
      await action();
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  void _removeImage(DraftImage image) {
    unawaited(
      updateCreateListingDraft(
        ref,
        (d) => d.copyWith(
          images: d.images.where((i) => i != image).toList(),
        ),
      ),
    );
  }

  void _reorderPhotos(List<DraftImage> photos, int oldIndex, int newIndex) {
    final reordered = [...photos];
    final moved = reordered.removeAt(oldIndex);
    reordered.insert(newIndex, moved);
    final draft = ref.read(createListingDraftProvider);
    final others = draft.images.where((i) => i.kind != ImageKind.photo);
    unawaited(
      updateCreateListingDraft(
        ref,
        (d) => d.copyWith(images: [...reordered, ...others]),
      ),
    );
  }

  Future<_Source?> _askSource(BuildContext context) {
    return showModalBottomSheet<_Source>(
      context: context,
      backgroundColor: AsmColors.surface,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(LucideIcons.image),
              title: const Text('Aus der Galerie'),
              onTap: () => Navigator.of(context).pop(_Source.gallery),
            ),
            ListTile(
              leading: const Icon(LucideIcons.camera),
              title: const Text('Foto aufnehmen'),
              onTap: () => Navigator.of(context).pop(_Source.camera),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final draft = ref.watch(createListingDraftProvider);
    final photos = draft.images
        .where((i) => i.kind == ImageKind.photo)
        .toList();
    final fMarking = draft.images
        .where((i) => i.kind == ImageKind.fMarking)
        .firstOrNull;
    final ownershipProof = draft.images
        .where((i) => i.kind == ImageKind.ownershipProof)
        .firstOrNull;
    final categoryAsync = draft.categoryId != null
        ? ref.watch(categoryByIdProvider(draft.categoryId!))
        : null;
    final requiresFMarking =
        categoryAsync?.valueOrNull?.requiresFMarking ?? false;
    final profileAsync = ref.watch(currentProfileProvider);
    final username = profileAsync.valueOrNull?.username ?? '…';
    final today = Formatters.date(DateTime.now());

    final canProceed =
        photos.isNotEmpty &&
        (!requiresFMarking || fMarking != null) &&
        ownershipProof != null;

    return Column(
      children: [
        Expanded(
          child: ListView(
            key: const Key('photosStepList'),
            padding: const EdgeInsets.all(AsmSpacing.md),
            children: [
              Row(
                children: [
                  const Text('Fotos', style: AsmTextStyles.titleS),
                  const Spacer(),
                  Text(
                    '${photos.length}/$_maxPhotos',
                    style: AsmTextStyles.bodyS.copyWith(
                      color: AsmColors.textSecondary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AsmSpacing.sm),
              Text(
                'Das erste Bild ist das Titelbild. Zum Sortieren gedrueckt halten und ziehen.',
                style: AsmTextStyles.bodyS.copyWith(
                  color: AsmColors.textSecondary,
                ),
              ),
              const SizedBox(height: AsmSpacing.sm),
              SizedBox(
                height: _thumbSize,
                child: CustomScrollView(
                  scrollDirection: Axis.horizontal,
                  slivers: [
                    ReorderableSliverGridView.count(
                      crossAxisCount: 1,
                      crossAxisSpacing: AsmSpacing.xs,
                      mainAxisSpacing: AsmSpacing.xs,
                      onReorder: (oldIndex, newIndex) =>
                          _reorderPhotos(photos, oldIndex, newIndex),
                      footer: photos.length < _maxPhotos
                          ? [
                              _AddTile(
                                key: const Key('photosStepAdd'),
                                busy: _busy,
                                onTap: _addPhotos,
                              ),
                            ]
                          : const [],
                      children: [
                        for (final photo in photos)
                          _PhotoTile(
                            key: ValueKey(photo.localPath),
                            image: photo,
                            isTitle: photos.first == photo,
                            onRemove: () => _removeImage(photo),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AsmSpacing.xl),
              if (requiresFMarking) ...[
                _SingleSlot(
                  key: const Key('photosStepFMarking'),
                  title: 'F-Kennzeichen',
                  explanation:
                      'Ein Foto des "F" im Fuenfeck auf der Waffe, gut lesbar.',
                  image: fMarking,
                  busy: _busy,
                  onTap: () => _pickSingle(ImageKind.fMarking),
                  onRemove: () => _removeImage(fMarking!),
                ),
                const SizedBox(height: AsmSpacing.xl),
              ],
              _SingleSlot(
                key: const Key('photosStepOwnershipProof'),
                title: 'Besitznachweis',
                explanation:
                    'Zettel mit deinem Nutzernamen $username und dem '
                    'heutigen Datum $today neben den Artikel legen und '
                    'fotografieren.',
                image: ownershipProof,
                busy: _busy,
                onTap: () => _pickSingle(ImageKind.ownershipProof),
                onRemove: () => _removeImage(ownershipProof!),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(AsmSpacing.md),
          child: AsmButton(
            key: const Key('photosStepNext'),
            label: 'Weiter',
            onPressed: canProceed
                ? () async {
                    await updateCreateListingDraft(
                      ref,
                      (d) => d.copyWith(step: 2),
                    );
                    widget.onNext();
                  }
                : null,
          ),
        ),
      ],
    );
  }
}

enum _Source { gallery, camera }

class _AddTile extends StatelessWidget {
  const _AddTile({required this.busy, required this.onTap, super.key});

  final bool busy;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: busy ? null : onTap,
      child: Container(
        width: _thumbSize,
        height: _thumbSize,
        decoration: BoxDecoration(
          border: Border.all(color: AsmColors.border),
          borderRadius: BorderRadius.circular(AsmRadius.md),
        ),
        child: busy
            ? const Center(
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              )
            : const Icon(LucideIcons.plus, color: AsmColors.textSecondary),
      ),
    );
  }
}

class _PhotoTile extends StatelessWidget {
  const _PhotoTile({
    required this.image,
    required this.isTitle,
    required this.onRemove,
    super.key,
  });

  final DraftImage image;
  final bool isTitle;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(AsmRadius.md),
          child: Image.file(
            File(image.localPath),
            width: _thumbSize,
            height: _thumbSize,
            fit: BoxFit.cover,
          ),
        ),
        if (isTitle)
          Positioned(
            left: 4,
            bottom: 4,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: AsmColors.scrim,
                borderRadius: BorderRadius.circular(AsmRadius.sm),
              ),
              child: const Text(
                'Titelbild',
                style: TextStyle(color: Colors.white, fontSize: 10),
              ),
            ),
          ),
        Positioned(
          right: 2,
          top: 2,
          child: GestureDetector(
            key: Key('removeImage_${image.localPath}'),
            onTap: onRemove,
            child: const CircleAvatar(
              radius: 10,
              backgroundColor: AsmColors.scrim,
              child: Icon(LucideIcons.x, size: 12, color: Colors.white),
            ),
          ),
        ),
      ],
    );
  }
}

class _SingleSlot extends StatelessWidget {
  const _SingleSlot({
    required this.title,
    required this.explanation,
    required this.image,
    required this.busy,
    required this.onTap,
    required this.onRemove,
    super.key,
  });

  final String title;
  final String explanation;
  final DraftImage? image;
  final bool busy;
  final VoidCallback onTap;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: AsmTextStyles.titleS),
        const SizedBox(height: AsmSpacing.xxs),
        Text(
          explanation,
          style: AsmTextStyles.bodyS.copyWith(color: AsmColors.textSecondary),
        ),
        const SizedBox(height: AsmSpacing.sm),
        if (image == null)
          _AddTile(busy: busy, onTap: onTap)
        else
          _PhotoTile(image: image!, isTitle: false, onRemove: onRemove),
      ],
    );
  }
}
