import 'package:freezed_annotation/freezed_annotation.dart';

part 'listing.freezed.dart';
part 'listing.g.dart';

enum ListingCondition {
  neu,
  neuwertig,
  gebraucht,
  @JsonValue('leichte_defekte')
  leichteDefekte,
  defekt,
  bastelobjekt,
}

enum ListingStatus { draft, active, reserved, sold, archived, blocked }

enum PropulsionType { saeg, aep, gbb, co2, hpa, federdruck, sonstige }

@freezed
abstract class Listing with _$Listing {
  const factory Listing({
    required String id,
    required String sellerId,
    required String categoryId,
    required String title,
    required String description,
    required int priceCents,
    required bool negotiable,
    required bool isGiveaway,
    required bool acceptsSwap,
    required ListingCondition condition,
    required ListingStatus status,
    required bool hasFMarking,
    required bool isModified,
    required bool ships,
    required bool pickupOnly,
    required String postalCode,
    required String city,
    required double lat,
    required double lng,
    required int viewCount,
    required DateTime createdAt,
    required DateTime updatedAt,
    String? manufacturer,
    String? model,
    double? joule,
    PropulsionType? propulsion,
    String? caliber,
    DateTime? publishedAt,
    DateTime? bumpedAt,
    DateTime? soldAt,
  }) = _Listing;

  factory Listing.fromJson(Map<String, dynamic> json) =>
      _$ListingFromJson(json);
}

@freezed
abstract class ListingDraft with _$ListingDraft {
  const factory ListingDraft({
    required String categoryId,
    required String title,
    required String description,
    required int priceCents,
    required ListingCondition condition,
    required String postalCode,
    required String city,
    required double lat,
    required double lng,
    @Default(false) bool negotiable,
    @Default(false) bool isGiveaway,
    @Default(false) bool acceptsSwap,
    String? manufacturer,
    String? model,
    double? joule,
    PropulsionType? propulsion,
    String? caliber,
    @Default(false) bool hasFMarking,
    @Default(false) bool isModified,
    @Default(false) bool ships,
    @Default(true) bool pickupOnly,
  }) = _ListingDraft;

  factory ListingDraft.fromJson(Map<String, dynamic> json) =>
      _$ListingDraftFromJson(json);
}
