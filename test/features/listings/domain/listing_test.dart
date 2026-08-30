import 'package:asm/features/listings/domain/listing.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Listing.fromJson', () {
    Map<String, dynamic> json({
      String condition = 'gebraucht',
      Object? propulsion = 'saeg',
    }) => {
      'id': 'l1',
      'seller_id': 's1',
      'category_id': 'c1',
      'title': 'G36 S-AEG mit Tuning-Gearbox',
      'description': 'Beschreibung mit mehr als dreissig Zeichen.',
      'price_cents': 35000,
      'negotiable': false,
      'is_giveaway': false,
      'accepts_swap': false,
      'condition': condition,
      'status': 'active',
      'manufacturer': null,
      'model': null,
      'joule': 1.2,
      'propulsion': propulsion,
      'caliber': null,
      'has_f_marking': true,
      'is_modified': false,
      'ships': true,
      'pickup_only': false,
      'postal_code': '76133',
      'city': 'Karlsruhe',
      'lat': 49.0069,
      'lng': 8.4037,
      'view_count': 0,
      'created_at': '2026-08-29T09:00:00.000Z',
      'updated_at': '2026-08-29T09:00:00.000Z',
      'published_at': null,
      'bumped_at': null,
      'sold_at': null,
    };

    test('mappt Snake-Case-Felder korrekt auf das Modell', () {
      final listing = Listing.fromJson(json());

      expect(listing.id, 'l1');
      expect(listing.sellerId, 's1');
      expect(listing.priceCents, 35000);
      expect(listing.hasFMarking, isTrue);
      expect(listing.pickupOnly, isFalse);
      expect(listing.joule, 1.2);
      expect(listing.createdAt, DateTime.parse('2026-08-29T09:00:00.000Z'));
    });

    test('dekodiert "leichte_defekte" auf ListingCondition.leichteDefekte', () {
      final listing = Listing.fromJson(json(condition: 'leichte_defekte'));
      expect(listing.condition, ListingCondition.leichteDefekte);
    });

    test('propulsion ist null-safe, wenn kein Antrieb gesetzt ist', () {
      final listing = Listing.fromJson(json(propulsion: null));
      expect(listing.propulsion, isNull);
    });
  });

  group('Listing bump-Faehigkeit', () {
    Listing listing({
      required DateTime createdAt,
      DateTime? publishedAt,
      DateTime? bumpedAt,
    }) => Listing(
      id: 'l1',
      sellerId: 's1',
      categoryId: 'c1',
      title: 'G36 S-AEG mit Tuning-Gearbox',
      description: 'Beschreibung mit mehr als dreissig Zeichen.',
      priceCents: 35000,
      negotiable: false,
      isGiveaway: false,
      acceptsSwap: false,
      condition: ListingCondition.gebraucht,
      status: ListingStatus.active,
      hasFMarking: false,
      isModified: false,
      ships: true,
      pickupOnly: false,
      postalCode: '76133',
      city: 'Karlsruhe',
      lat: 49.0069,
      lng: 8.4037,
      viewCount: 0,
      createdAt: createdAt,
      updatedAt: createdAt,
      publishedAt: publishedAt,
      bumpedAt: bumpedAt,
    );

    test('lastBumpReference nimmt bumpedAt, wenn gesetzt', () {
      final l = listing(
        createdAt: DateTime(2026),
        publishedAt: DateTime(2026, 1, 2),
        bumpedAt: DateTime(2026, 1, 10),
      );
      expect(l.lastBumpReference, DateTime(2026, 1, 10));
    });

    test(
      'lastBumpReference faellt auf publishedAt zurueck, wenn nie gebumpt',
      () {
        final l = listing(
          createdAt: DateTime(2026),
          publishedAt: DateTime(2026, 1, 2),
        );
        expect(l.lastBumpReference, DateTime(2026, 1, 2));
      },
    );

    test(
      'lastBumpReference faellt auf createdAt zurueck, wenn weder gebumpt noch veroeffentlicht',
      () {
        final l = listing(createdAt: DateTime(2026));
        expect(l.lastBumpReference, DateTime(2026));
      },
    );

    test(
      'canBump ist wahr, wenn der letzte Bump 14 Tage oder laenger her ist',
      () {
        final now = DateTime(2026, 8, 30);
        final l = listing(
          createdAt: DateTime(2026, 8),
          bumpedAt: now.subtract(const Duration(days: 14)),
        );
        expect(l.canBump(now: now), isTrue);
      },
    );

    test(
      'canBump ist falsch, wenn der letzte Bump weniger als 14 Tage her ist',
      () {
        final now = DateTime(2026, 8, 30);
        final l = listing(
          createdAt: DateTime(2026, 8),
          bumpedAt: now.subtract(const Duration(days: 13)),
        );
        expect(l.canBump(now: now), isFalse);
      },
    );
  });

  group('ListingDraft.toJson', () {
    test('serialisiert auf Snake-Case-Feldnamen fuer Insert/Update', () {
      const draft = ListingDraft(
        categoryId: 'c1',
        title: 'Testinserat mit gueltiger Laenge',
        description:
            'Beschreibung mit mehr als dreissig Zeichen und genug Inhalt.',
        priceCents: 12000,
        condition: ListingCondition.neuwertig,
        hasFMarking: true,
        postalCode: '76133',
        city: 'Karlsruhe',
        lat: 49.0069,
        lng: 8.4037,
      );

      final json = draft.toJson();

      expect(json['category_id'], 'c1');
      expect(json['price_cents'], 12000);
      expect(json['has_f_marking'], true);
      expect(json['condition'], 'neuwertig');
      expect(json['pickup_only'], true, reason: 'Default ist Abholung');
    });
  });
}
