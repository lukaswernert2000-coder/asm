import 'package:asm/features/listings/domain/listing.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'listing_summary.freezed.dart';
part 'listing_summary.g.dart';

@freezed
abstract class ListingSummary with _$ListingSummary {
  const factory ListingSummary({
    required String id,
    required String title,
    required int priceCents,
    required bool negotiable,
    required ListingCondition condition,
    required ListingStatus status,
    required String city,
    required String postalCode,
    required bool hasFMarking,
    required bool ships,
    required DateTime bumpedAt,
    required String sellerId,
    required String categorySlug,
    double? joule,
    String? coverPath,
    double? distanceKm,
  }) = _ListingSummary;

  factory ListingSummary.fromJson(Map<String, dynamic> json) =>
      _$ListingSummaryFromJson(json);
}
