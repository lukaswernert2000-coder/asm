import 'package:asm/features/listings/domain/listing.dart';
import 'package:asm/features/listings/domain/listing_filter.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ListingFilter.activeCount', () {
    test('zaehlt 0 fuer eine leere Suche (query zaehlt nicht mit)', () {
      const filter = ListingFilter(query: 'pistole');
      expect(filter.activeCount, 0);
    });

    test('zaehlt Kategorie als einen aktiven Filter', () {
      const filter = ListingFilter(categorySlug: 'pistolen');
      expect(filter.activeCount, 1);
    });

    test('zaehlt min- und max-Preis zusammen als einen Filter', () {
      const filter = ListingFilter(minPrice: 1000, maxPrice: 5000);
      expect(filter.activeCount, 1);
    });

    test('zaehlt eine nicht-leere Zustandsliste als einen Filter', () {
      const filter = ListingFilter(conditions: [ListingCondition.neuwertig]);
      expect(filter.activeCount, 1);
    });

    test('zaehlt eine nicht-leere Antriebsartliste als einen Filter', () {
      const filter = ListingFilter(propulsions: [PropulsionType.saeg]);
      expect(filter.activeCount, 1);
    });

    test('zaehlt min- und max-Joule zusammen als einen Filter', () {
      const filter = ListingFilter(minJoule: 0.5, maxJoule: 1);
      expect(filter.activeCount, 1);
    });

    test('zaehlt ships als einen Filter', () {
      const filter = ListingFilter(ships: true);
      expect(filter.activeCount, 1);
    });

    test('zaehlt Ort (lat/lng/radiusKm) als einen Filter', () {
      const filter = ListingFilter(lat: 49, lng: 8, radiusKm: 25);
      expect(filter.activeCount, 1);
    });

    test('zaehlt eine vom Default abweichende Sortierung als einen Filter', () {
      const filter = ListingFilter(sort: SortOption.priceAsc);
      expect(filter.activeCount, 1);
    });

    test('summiert mehrere aktive Filtergruppen', () {
      const filter = ListingFilter(
        categorySlug: 'pistolen',
        minPrice: 1000,
        conditions: [ListingCondition.neuwertig],
        sort: SortOption.distance,
      );
      expect(filter.activeCount, 4);
    });

    test('ListingFilter() ohne Werte hat activeCount 0', () {
      expect(const ListingFilter().activeCount, 0);
    });
  });
}
