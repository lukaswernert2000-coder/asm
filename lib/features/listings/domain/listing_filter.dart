import 'package:asm/features/listings/domain/listing.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'listing_filter.freezed.dart';

enum SortOption { newest, priceAsc, priceDesc, distance }

@freezed
abstract class ListingFilter with _$ListingFilter {
  const factory ListingFilter({
    String? query,
    String? categorySlug,
    int? minPrice,
    int? maxPrice,
    List<ListingCondition>? conditions,
    List<PropulsionType>? propulsions,
    double? minJoule,
    double? maxJoule,
    bool? ships,
    double? lat,
    double? lng,
    int? radiusKm,
    @Default(SortOption.newest) SortOption sort,
  }) = _ListingFilter;
}
