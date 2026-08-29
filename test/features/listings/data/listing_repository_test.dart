import 'package:asm/features/listings/data/listing_repository.dart';
import 'package:asm/features/listings/domain/listing.dart';
import 'package:asm/features/listings/domain/listing_filter.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class MockSupabaseClient extends Mock implements SupabaseClient {}

void main() {
  late MockSupabaseClient client;

  setUp(() {
    client = MockSupabaseClient();
  });

  group('search', () {
    test('ruft die RPC mit den korrekt gemappten Parametern auf', () async {
      String? capturedFn;
      Map<String, dynamic>? capturedParams;
      final repository = SupabaseListingRepository(
        client,
        rpcCaller: (fn, params) async {
          capturedFn = fn;
          capturedParams = params;
          return <dynamic>[];
        },
      );

      const filter = ListingFilter(
        query: 'g36',
        categorySlug: 'langwaffen',
        maxPrice: 50000,
        conditions: [ListingCondition.leichteDefekte],
        sort: SortOption.priceAsc,
      );

      await repository.search(filter, limit: 10, offset: 5);

      expect(capturedFn, 'search_listings');
      expect(capturedParams!['p_query'], 'g36');
      expect(capturedParams!['p_category'], 'langwaffen');
      expect(capturedParams!['p_max_price'], 50000);
      expect(capturedParams!['p_conditions'], ['leichte_defekte']);
      expect(capturedParams!['p_sort'], 'price_asc');
      expect(capturedParams!['p_limit'], 10);
      expect(capturedParams!['p_offset'], 5);
    });

    test(
      'mappt die Antwort auf ListingSummary und liest total_count',
      () async {
        final repository = SupabaseListingRepository(
          client,
          rpcCaller: (fn, params) async => <dynamic>[
            {
              'id': 'l1',
              'title': 'G36 S-AEG mit Tuning-Gearbox',
              'price_cents': 35000,
              'negotiable': false,
              'condition': 'gebraucht',
              'status': 'active',
              'city': 'Karlsruhe',
              'postal_code': '76133',
              'joule': 1.2,
              'has_f_marking': true,
              'ships': true,
              'bumped_at': '2026-08-29T09:00:00.000Z',
              'seller_id': 's1',
              'category_slug': 'langwaffen-saeg',
              'cover_path': null,
              'distance_km': 0.0,
              'total_count': 1,
            },
          ],
        );

        final result = await repository.search(const ListingFilter());

        expect(result.total, 1);
        expect(result.items, hasLength(1));
        expect(result.items.single.title, 'G36 S-AEG mit Tuning-Gearbox');
        expect(result.items.single.categorySlug, 'langwaffen-saeg');
      },
    );

    test('liefert total 0 bei leerem Ergebnis', () async {
      final repository = SupabaseListingRepository(
        client,
        rpcCaller: (fn, params) async => <dynamic>[],
      );

      final result = await repository.search(const ListingFilter());

      expect(result.total, 0);
      expect(result.items, isEmpty);
    });
  });
}
