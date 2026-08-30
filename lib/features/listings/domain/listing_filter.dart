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

  const ListingFilter._();

  /// Anzahl aktiver Filtergruppen fuer das Badge am Filter-Icon
  /// (`02-IMPLEMENTATION-PLAN.md` Task 3.4). `query` zaehlt bewusst nicht mit
  /// -- das ist der Suchtext, kein Filter-Sheet-Wert. Min/Max eines Bereichs
  /// zaehlen zusammen als eine Gruppe, nicht doppelt.
  int get activeCount {
    var count = 0;
    if (categorySlug != null) count++;
    if (minPrice != null || maxPrice != null) count++;
    if (conditions != null && conditions!.isNotEmpty) count++;
    if (propulsions != null && propulsions!.isNotEmpty) count++;
    if (minJoule != null || maxJoule != null) count++;
    if (ships != null) count++;
    if (lat != null || lng != null || radiusKm != null) count++;
    if (sort != SortOption.newest) count++;
    return count;
  }
}
