import 'package:asm/features/listings/domain/create_listing_draft.dart';
import 'package:asm/features/listings/domain/listing.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('CreateListingDraft', () {
    test('startet leer bei Schritt 0', () {
      const draft = CreateListingDraft();
      expect(draft.step, 0);
      expect(draft.images, isEmpty);
      expect(draft.isCompleteEnoughToPublish, isFalse);
    });

    test(
      'hasFMarking ist true, sobald ein Bild vom Kind fMarking dabei ist',
      () {
        const draft = CreateListingDraft(
          images: [
            DraftImage(localPath: '/a.jpg', kind: ImageKind.photo),
            DraftImage(localPath: '/b.jpg', kind: ImageKind.fMarking),
          ],
        );
        expect(draft.hasFMarking, isTrue);
      },
    );

    test('hasFMarking ist false ohne ein solches Bild', () {
      const draft = CreateListingDraft(
        images: [DraftImage(localPath: '/a.jpg', kind: ImageKind.photo)],
      );
      expect(draft.hasFMarking, isFalse);
    });

    test('isCompleteEnoughToPublish ist erst true, wenn alle Pflichtfelder gesetzt sind', () {
      const complete = CreateListingDraft(
        categoryId: 'c1',
        title: 'Ein Titel mit genug Zeichen',
        description: 'Eine ausreichend lange Beschreibung fuer den Test.',
        condition: ListingCondition.gebraucht,
        priceCents: 1000,
        postalCode: '76133',
        city: 'Karlsruhe',
        lat: 49,
        lng: 8.4,
      );
      expect(complete.isCompleteEnoughToPublish, isTrue);

      const missingPrice = CreateListingDraft(
        categoryId: 'c1',
        title: 'Ein Titel mit genug Zeichen',
        description: 'Eine ausreichend lange Beschreibung fuer den Test.',
        condition: ListingCondition.gebraucht,
        postalCode: '76133',
        city: 'Karlsruhe',
        lat: 49,
        lng: 8.4,
      );
      expect(missingPrice.isCompleteEnoughToPublish, isFalse);
    });

    test('toListingDraft wirft, wenn Pflichtfelder fehlen', () {
      const draft = CreateListingDraft();
      expect(draft.toListingDraft, throwsStateError);
    });

    test('toListingDraft mappt alle Felder korrekt, hasFMarking aus Bildern abgeleitet', () {
      const draft = CreateListingDraft(
        categoryId: 'c1',
        title: 'Ein Titel mit genug Zeichen',
        description: 'Eine ausreichend lange Beschreibung fuer den Test.',
        condition: ListingCondition.neuwertig,
        manufacturer: 'ASG Corp',
        model: 'X1',
        joule: 1.2,
        propulsion: PropulsionType.aep,
        caliber: '6mm',
        isModified: true,
        priceCents: 5000,
        negotiable: true,
        acceptsSwap: true,
        ships: true,
        pickupOnly: false,
        postalCode: '76133',
        city: 'Karlsruhe',
        lat: 49,
        lng: 8.4,
        images: [DraftImage(localPath: '/f.jpg', kind: ImageKind.fMarking)],
      );

      final result = draft.toListingDraft();

      expect(result.categoryId, 'c1');
      expect(result.title, 'Ein Titel mit genug Zeichen');
      expect(result.priceCents, 5000);
      expect(result.condition, ListingCondition.neuwertig);
      expect(result.manufacturer, 'ASG Corp');
      expect(result.joule, 1.2);
      expect(result.propulsion, PropulsionType.aep);
      expect(result.caliber, '6mm');
      expect(result.isModified, isTrue);
      expect(result.negotiable, isTrue);
      expect(result.acceptsSwap, isTrue);
      expect(result.ships, isTrue);
      expect(result.pickupOnly, isFalse);
      expect(result.hasFMarking, isTrue);
      expect(result.postalCode, '76133');
      expect(result.city, 'Karlsruhe');
      expect(result.lat, 49.0);
      expect(result.lng, 8.4);
    });

    test('JSON-Roundtrip erhaelt alle Felder inkl. Bilder', () {
      const draft = CreateListingDraft(
        step: 2,
        categoryId: 'c1',
        title: 'Titel',
        images: [
          DraftImage(localPath: '/a.jpg', kind: ImageKind.ownershipProof),
        ],
      );

      final restored = CreateListingDraft.fromJson(draft.toJson());

      expect(restored, draft);
    });
  });
}
