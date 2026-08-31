import 'dart:io';

import 'package:asm/core/errors/app_exception.dart';
import 'package:asm/core/storage/shared_preferences_provider.dart';
import 'package:asm/core/supabase/supabase_provider.dart';
import 'package:asm/features/listings/data/image_service.dart';
import 'package:asm/features/listings/data/listing_repository.dart';
import 'package:asm/features/listings/domain/create_listing_draft.dart';
import 'package:asm/features/listings/domain/listing.dart';
import 'package:asm/features/listings/presentation/listing_providers.dart';
import 'package:asm/features/listings/presentation/widgets/create_listing/shipping_step.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../../helpers/fake_shared_preferences.dart';
import '../../../../../helpers/scrollable_list_interaction.dart';

class MockListingRepository extends Mock implements ListingRepository {}

class MockImageService extends Mock implements ImageService {}

class MockSupabaseClient extends Mock implements SupabaseClient {}

class FakeListingDraft extends Fake implements ListingDraft {}

const _listKey = Key('shippingStepList');
const _completeDraft = CreateListingDraft(
  categoryId: 'c1',
  title: 'Ein gueltiger Titel',
  description: 'Eine ausreichend lange Beschreibung fuer den Test hier.',
  condition: ListingCondition.gebraucht,
  priceCents: 5000,
);

void main() {
  late MockListingRepository listingRepository;
  late MockImageService imageService;

  setUpAll(() {
    registerFallbackValue(FakeListingDraft());
    registerFallbackValue(ImageKind.photo);
    registerFallbackValue(ListingStatus.active);
    registerFallbackValue(File('fallback'));
  });

  setUp(() {
    listingRepository = MockListingRepository();
    imageService = MockImageService();
  });

  Future<Object?> resolvePlzFake(String plz) async {
    if (plz == '76133') {
      return (city: 'Karlsruhe', lat: 49.0, lng: 8.4);
    }
    return null;
  }

  Future<ProviderContainer> pumpScreen(
    WidgetTester tester, {
    CreateListingDraft draft = _completeDraft,
  }) async {
    final container = ProviderContainer(
      overrides: [
        listingRepositoryProvider.overrideWithValue(listingRepository),
        imageServiceProvider.overrideWithValue(imageService),
        supabaseProvider.overrideWithValue(MockSupabaseClient()),
        sharedPreferencesProvider.overrideWithValue(
          await fakeSharedPreferences(createListingDraft: draft),
        ),
      ],
    );
    addTearDown(container.dispose);
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp(
          home: Scaffold(
            body: ShippingStep(
              resolvePlz: (plz) async =>
                  await resolvePlzFake(plz)
                      as ({String city, double lat, double lng})?,
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    return container;
  }

  testWidgets('unbekannte PLZ zeigt einen Fehler', (tester) async {
    await pumpScreen(tester);
    await enterTextInList(
      tester,
      _listKey,
      find.byKey(const Key('shippingStepPlz')),
      '99999',
    );
    expect(find.text('Unbekannte Postleitzahl'), findsOneWidget);
  });

  testWidgets(
    'Veroeffentlichen ist deaktiviert bis PLZ aufgeloest ist, dann aktiv',
    (tester) async {
      await pumpScreen(tester);

      InkWell publishInkWell() => tester.widget<InkWell>(
        find.descendant(
          of: find.byKey(const Key('shippingStepPublish')),
          matching: find.byType(InkWell),
        ),
      );
      expect(publishInkWell().onTap, isNull);

      await enterTextInList(
        tester,
        _listKey,
        find.byKey(const Key('shippingStepPlz')),
        '76133',
      );

      expect(publishInkWell().onTap, isNotNull);
    },
  );

  testWidgets('gueltige PLZ loest den Ort auf', (tester) async {
    await pumpScreen(tester);
    await enterTextInList(
      tester,
      _listKey,
      find.byKey(const Key('shippingStepPlz')),
      '76133',
    );
    expect(find.text('Karlsruhe'), findsOneWidget);
  });

  testWidgets(
    'weder Abholung noch Versand zeigt einen Fehler beim Veroeffentlichen',
    (
      tester,
    ) async {
      await pumpScreen(
        tester,
        draft: _completeDraft.copyWith(ships: false, pickupOnly: false),
      );
      // PLZ aufloesen, damit nur noch die Versandart-Regel den Button sperrt --
      // sonst bliebe "Veroeffentlichen" schon wegen der fehlenden PLZ
      // deaktiviert und der Tap unten waere ein no-op.
      await enterTextInList(
        tester,
        _listKey,
        find.byKey(const Key('shippingStepPlz')),
        '76133',
      );

      final publishInkWell = tester.widget<InkWell>(
        find.descendant(
          of: find.byKey(const Key('shippingStepPublish')),
          matching: find.byType(InkWell),
        ),
      );
      expect(publishInkWell.onTap, isNull);
      verifyNever(() => listingRepository.create(any()));
    },
  );

  testWidgets(
    'erfolgreiches Veroeffentlichen legt an, laedt Bilder hoch und setzt aktiv',
    (tester) async {
      when(
        () => listingRepository.create(any()),
      ).thenAnswer((_) async => 'l1');
      when(
        () => listingRepository.update(any(), any()),
      ).thenAnswer((_) async {});
      when(
        () => listingRepository.setStatus(any(), any()),
      ).thenAnswer((_) async {});
      when(
        () => imageService.upload(
          any(),
          listingId: any(named: 'listingId'),
          kind: any(named: 'kind'),
        ),
      ).thenAnswer((_) async => 'listing-images/u1/l1/x.jpg');
      when(
        () => listingRepository.insertImage(
          any(),
          storagePath: any(named: 'storagePath'),
          kind: any(named: 'kind'),
          sortOrder: any(named: 'sortOrder'),
        ),
      ).thenAnswer((_) async {});

      final draft = _completeDraft.copyWith(
        ships: true,
        images: const [
          DraftImage(localPath: '/tmp/a.jpg', kind: ImageKind.photo),
        ],
      );
      await pumpScreen(tester, draft: draft);
      await enterTextInList(
        tester,
        _listKey,
        find.byKey(const Key('shippingStepPlz')),
        '76133',
      );

      await tester.tap(find.byKey(const Key('shippingStepPublish')));
      await tester.pumpAndSettle();

      verify(() => listingRepository.create(any())).called(1);
      verify(
        () => imageService.upload(
          any(),
          listingId: 'l1',
          kind: ImageKind.photo,
        ),
      ).called(1);
      verify(
        () => listingRepository.insertImage(
          'l1',
          storagePath: 'listing-images/u1/l1/x.jpg',
          kind: ImageKind.photo,
          sortOrder: 0,
        ),
      ).called(1);
      verify(
        () => listingRepository.setStatus('l1', ListingStatus.active),
      ).called(1);
      expect(find.text('Inserat veröffentlicht!'), findsOneWidget);
    },
  );

  testWidgets(
    'fehlgeschlagener Upload zeigt einen Fehler und legt beim erneuten Versuch die Zeile nicht doppelt an',
    (tester) async {
      when(
        () => listingRepository.create(any()),
      ).thenAnswer((_) async => 'l1');
      when(
        () => listingRepository.update(any(), any()),
      ).thenAnswer((_) async {});
      when(
        () => listingRepository.setStatus(any(), any()),
      ).thenAnswer((_) async {});
      var uploadAttempts = 0;
      when(
        () => imageService.upload(
          any(),
          listingId: any(named: 'listingId'),
          kind: any(named: 'kind'),
        ),
      ).thenAnswer((_) async {
        uploadAttempts++;
        if (uploadAttempts == 1) {
          throw const NetworkException();
        }
        return 'listing-images/u1/l1/x.jpg';
      });
      when(
        () => listingRepository.insertImage(
          any(),
          storagePath: any(named: 'storagePath'),
          kind: any(named: 'kind'),
          sortOrder: any(named: 'sortOrder'),
        ),
      ).thenAnswer((_) async {});

      final draft = _completeDraft.copyWith(
        ships: true,
        images: const [
          DraftImage(localPath: '/tmp/a.jpg', kind: ImageKind.photo),
        ],
      );
      await pumpScreen(tester, draft: draft);
      await enterTextInList(
        tester,
        _listKey,
        find.byKey(const Key('shippingStepPlz')),
        '76133',
      );

      await tester.tap(find.byKey(const Key('shippingStepPublish')));
      await tester.pumpAndSettle();
      expect(find.textContaining('Verbindung'), findsOneWidget);

      await tester.tap(find.byKey(const Key('shippingStepPublish')));
      await tester.pumpAndSettle();

      verify(() => listingRepository.create(any())).called(1);
      verify(
        () => listingRepository.update('l1', any()),
      ).called(1);
      expect(find.text('Inserat veröffentlicht!'), findsOneWidget);
    },
  );
}
