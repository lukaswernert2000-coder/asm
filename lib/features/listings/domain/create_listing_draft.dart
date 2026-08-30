import 'package:asm/features/listings/domain/listing.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'create_listing_draft.freezed.dart';
part 'create_listing_draft.g.dart';

/// Ein lokal ausgewaehltes, ggf. schon komprimiertes Bild im Erstellen-Flow.
/// `localPath` zeigt auf die komprimierte Datei, `uploadedPath` wird erst
/// beim Veroeffentlichen gesetzt (Ergebnis von `ImageService.upload`).
@freezed
abstract class DraftImage with _$DraftImage {
  const factory DraftImage({
    required String localPath,
    required ImageKind kind,
    String? uploadedPath,
  }) = _DraftImage;

  factory DraftImage.fromJson(Map<String, dynamic> json) =>
      _$DraftImageFromJson(json);
}

/// Lokaler, nach jedem Schritt persistierter Zustand des 4-Schritte-
/// Erstellen-Flows (Task 4.2). Anders als [ListingDraft] sind hier alle
/// inhaltlichen Felder optional -- der Nutzer fuellt sie erst nach und nach.
/// Wird erst beim Veroeffentlichen in ein vollstaendiges [ListingDraft]
/// uebersetzt.
@freezed
abstract class CreateListingDraft with _$CreateListingDraft {
  const factory CreateListingDraft({
    @Default(0) int step,
    String? categoryId,
    @Default([]) List<DraftImage> images,
    String? title,
    String? description,
    ListingCondition? condition,
    String? manufacturer,
    String? model,
    double? joule,
    PropulsionType? propulsion,
    String? caliber,
    @Default(false) bool isModified,
    int? priceCents,
    @Default(false) bool negotiable,
    @Default(false) bool isGiveaway,
    @Default(false) bool acceptsSwap,
    @Default(false) bool ships,
    @Default(true) bool pickupOnly,
    String? postalCode,
    String? city,
    double? lat,
    double? lng,
  }) = _CreateListingDraft;

  const CreateListingDraft._();

  factory CreateListingDraft.fromJson(Map<String, dynamic> json) =>
      _$CreateListingDraftFromJson(json);

  bool get hasFMarking => images.any((i) => i.kind == ImageKind.fMarking);

  /// Alle Pflichtangaben fuer [toListingDraft] sind vorhanden.
  bool get isCompleteEnoughToPublish =>
      categoryId != null &&
      title != null &&
      description != null &&
      condition != null &&
      priceCents != null &&
      postalCode != null &&
      city != null &&
      lat != null &&
      lng != null;

  ListingDraft toListingDraft() {
    if (!isCompleteEnoughToPublish) {
      throw StateError('CreateListingDraft ist nicht vollstaendig genug.');
    }
    return ListingDraft(
      categoryId: categoryId!,
      title: title!,
      description: description!,
      priceCents: priceCents!,
      condition: condition!,
      postalCode: postalCode!,
      city: city!,
      lat: lat!,
      lng: lng!,
      negotiable: negotiable,
      isGiveaway: isGiveaway,
      acceptsSwap: acceptsSwap,
      manufacturer: manufacturer,
      model: model,
      joule: joule,
      propulsion: propulsion,
      caliber: caliber,
      hasFMarking: hasFMarking,
      isModified: isModified,
      ships: ships,
      pickupOnly: pickupOnly,
    );
  }
}
