import 'package:asm/core/theme/asm_colors.dart';
import 'package:flutter/widgets.dart' show Color;
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

enum ImageKind { photo, fMarking, ownershipProof }

/// Deutsche Anzeigetexte. Siehe `00-SPEC.md` Abschnitt 6.1/6.2.
extension ListingConditionLabel on ListingCondition {
  String get label => switch (this) {
    ListingCondition.neu => 'Neu',
    ListingCondition.neuwertig => 'Neuwertig',
    ListingCondition.gebraucht => 'Gebraucht',
    ListingCondition.leichteDefekte => 'Leichte Defekte',
    ListingCondition.defekt => 'Defekt',
    ListingCondition.bastelobjekt => 'Bastelobjekt',
  };
}

/// Zustands-Badge-Farben, geteilt zwischen `ListingCard` (Feed) und der
/// Detailseite (Task 5.1) -- siehe 01-DESIGN-SYSTEM.md Abschnitt 5.4.
extension ListingConditionBadge on ListingCondition {
  Color get badgeColor => switch (this) {
    ListingCondition.neu || ListingCondition.neuwertig => AsmColors.success,
    ListingCondition.gebraucht => AsmColors.surfaceRaised,
    ListingCondition.leichteDefekte => AsmColors.warning,
    ListingCondition.defekt ||
    ListingCondition.bastelobjekt => AsmColors.danger,
  };

  Color get badgeTextColor => this == ListingCondition.gebraucht
      ? AsmColors.textSecondary
      : AsmColors.onBrand;
}

extension PropulsionTypeLabel on PropulsionType {
  String get label => switch (this) {
    PropulsionType.saeg => 'S-AEG',
    PropulsionType.aep => 'AEP',
    PropulsionType.gbb => 'GBB / Gas',
    PropulsionType.co2 => 'CO2',
    PropulsionType.hpa => 'HPA',
    PropulsionType.federdruck => 'Federdruck',
    PropulsionType.sonstige => 'Sonstige',
  };
}

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

const bumpCooldown = Duration(days: 14);

/// Spiegelt die `coalesce(bumped_at, published_at, created_at)`-Logik aus
/// `search_listings` (0007_search.sql), damit Client und Sortierung im
/// Feed dieselbe Referenzzeit verwenden.
extension ListingBump on Listing {
  DateTime get lastBumpReference => bumpedAt ?? publishedAt ?? createdAt;

  bool canBump({DateTime? now}) =>
      (now ?? DateTime.now()).difference(lastBumpReference) >= bumpCooldown;
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
