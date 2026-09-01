import 'package:asm/core/storage/shared_preferences_provider.dart';
import 'package:asm/core/supabase/supabase_provider.dart';
import 'package:asm/core/widgets/asm_checkbox.dart';
import 'package:asm/features/categories/data/category_repository.dart';
import 'package:asm/features/categories/domain/category.dart';
import 'package:asm/features/categories/presentation/category_providers.dart';
import 'package:asm/features/listings/data/listing_repository.dart';
import 'package:asm/features/listings/domain/create_listing_draft.dart';
import 'package:asm/features/listings/domain/listing.dart';
import 'package:asm/features/listings/presentation/create_listing_providers.dart';
import 'package:asm/features/listings/presentation/listing_providers.dart';
import 'package:asm/features/listings/presentation/widgets/create_listing/details_step.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../../helpers/fake_shared_preferences.dart';
import '../../../../../helpers/scrollable_list_interaction.dart';

class MockCategoryRepository extends Mock implements CategoryRepository {}

class MockListingRepository extends Mock implements ListingRepository {}

class MockSupabaseClient extends Mock implements SupabaseClient {}

const _listKey = Key('detailsStepList');

// AsmCheckbox toggelt bewusst nur ueber die Box selbst, nicht ueber das
// Label (siehe asm_checkbox.dart) -- mehrere Checkboxen auf diesem Screen,
// deshalb ueber die zugehoerige Label-Ancestor-Beziehung eindeutig finden.
Finder _checkboxToggleFor(String label) => find.descendant(
  of: find.ancestor(
    of: find.text(label),
    matching: find.byType(AsmCheckbox),
  ),
  matching: find.byType(GestureDetector),
);

void main() {
  late MockCategoryRepository categoryRepository;
  late MockListingRepository listingRepository;

  const pistolenLeaf = Category(
    id: 'c1',
    slug: 'pistolen-revolver',
    name: 'Revolver',
    sortOrder: 1,
    requiresAge18: true,
    requiresFMarking: true,
    requiresJoule: true,
    requiresPropulsion: true,
    isActive: true,
    parentId: 'p1',
  );
  const accessoryLeaf = Category(
    id: 'c2',
    slug: 'zubehoer-magazine',
    name: 'Magazine',
    sortOrder: 1,
    requiresAge18: false,
    requiresFMarking: false,
    requiresJoule: false,
    requiresPropulsion: false,
    isActive: true,
    parentId: 'p2',
  );

  setUp(() {
    categoryRepository = MockCategoryRepository();
    listingRepository = MockListingRepository();
    when(
      () => categoryRepository.all(),
    ).thenAnswer((_) async => [pistolenLeaf, accessoryLeaf]);
    when(
      () => listingRepository.manufacturers(),
    ).thenAnswer((_) async => ['ASG Corp', 'Airsoft GmbH']);
  });

  Future<ProviderContainer> pumpScreen(
    WidgetTester tester, {
    required CreateListingDraft draft,
    VoidCallback? onNext,
  }) async {
    final container = ProviderContainer(
      overrides: [
        categoryRepositoryProvider.overrideWithValue(categoryRepository),
        listingRepositoryProvider.overrideWithValue(listingRepository),
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
          home: Scaffold(body: DetailsStep(onNext: onNext ?? () {})),
        ),
      ),
    );
    await tester.pumpAndSettle();
    return container;
  }

  testWidgets(
    'zeigt Joule/Antriebsart/Kaliber/umgebaut nur wenn die Kategorie es verlangt',
    (
      tester,
    ) async {
      await pumpScreen(
        tester,
        draft: const CreateListingDraft(categoryId: 'c2'),
      );
      await scrollListUntilVisible(tester, _listKey, find.text('Modell'));
      expect(find.text('Antriebsart'), findsNothing);
      expect(find.text('Kaliber'), findsNothing);
    },
  );

  testWidgets(
    'zeigt Joule/Antriebsart/Kaliber/umgebaut wenn die Kategorie es verlangt',
    (
      tester,
    ) async {
      await pumpScreen(
        tester,
        draft: const CreateListingDraft(categoryId: 'c1'),
      );
      await scrollListUntilVisible(tester, _listKey, find.text('Antriebsart'));
      expect(find.text('Antriebsart'), findsOneWidget);
      await scrollListUntilVisible(tester, _listKey, find.text('Kaliber'));
      expect(find.text('Kaliber'), findsOneWidget);
      await scrollListUntilVisible(
        tester,
        _listKey,
        find.text('Umgebaut (Antriebsart geaendert)'),
      );
      expect(find.text('Umgebaut (Antriebsart geaendert)'), findsOneWidget);
    },
  );

  testWidgets(
    'Weiter ohne gueltige Eingaben zeigt Fehler und blaettert nicht weiter',
    (
      tester,
    ) async {
      var nextCalled = false;
      await pumpScreen(
        tester,
        draft: const CreateListingDraft(categoryId: 'c2'),
        onNext: () => nextCalled = true,
      );

      await tester.tap(find.byKey(const Key('detailsStepNext')));
      await tester.pumpAndSettle();

      expect(nextCalled, isFalse);
      expect(find.text('Zwischen 10 und 80 Zeichen'), findsOneWidget);
      expect(find.text('Mindestens 15 Zeichen'), findsOneWidget);
      await scrollListUntilVisible(
        tester,
        _listKey,
        find.text('Bitte auswaehlen'),
      );
      expect(find.text('Bitte auswaehlen'), findsOneWidget);
      await scrollListUntilVisible(
        tester,
        _listKey,
        find.text('Bitte einen Preis angeben'),
      );
      expect(find.text('Bitte einen Preis angeben'), findsOneWidget);
    },
  );

  testWidgets('gueltige Eingaben blaettern weiter und schreiben den Entwurf', (
    tester,
  ) async {
    var nextCalled = false;
    final container = await pumpScreen(
      tester,
      draft: const CreateListingDraft(categoryId: 'c2'),
      onNext: () => nextCalled = true,
    );

    await enterTextInList(
      tester,
      _listKey,
      find.byKey(const Key('detailsStepTitle')),
      'Ein gueltiger Titel',
    );
    await enterTextInList(
      tester,
      _listKey,
      find.byKey(const Key('detailsStepDescription')),
      'Eine ausreichend lange Beschreibung mit genug Zeichen fuer den Test.',
    );
    await enterTextInList(
      tester,
      _listKey,
      find.byKey(const Key('detailsStepPrice')),
      '49,90',
    );
    await tapInList(tester, _listKey, find.text('Gebraucht'));

    await tester.tap(find.byKey(const Key('detailsStepNext')));
    await tester.pumpAndSettle();

    expect(nextCalled, isTrue);
    final draft = container.read(createListingDraftProvider);
    expect(draft.title, 'Ein gueltiger Titel');
    expect(draft.priceCents, 4990);
    expect(draft.condition, ListingCondition.gebraucht);
    expect(draft.step, 3);
  });

  testWidgets('Verschenken versteckt den Preis und setzt priceCents auf 0', (
    tester,
  ) async {
    final container = await pumpScreen(
      tester,
      draft: const CreateListingDraft(categoryId: 'c2'),
    );

    await enterTextInList(
      tester,
      _listKey,
      find.byKey(const Key('detailsStepTitle')),
      'Ein gueltiger Titel',
    );
    await enterTextInList(
      tester,
      _listKey,
      find.byKey(const Key('detailsStepDescription')),
      'Eine ausreichend lange Beschreibung mit genug Zeichen fuer den Test.',
    );
    await tapInList(tester, _listKey, find.text('Gebraucht'));
    await scrollListUntilVisible(tester, _listKey, find.text('Verschenken'));
    await tester.tap(_checkboxToggleFor('Verschenken'));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('detailsStepPrice')), findsNothing);

    await tester.tap(find.byKey(const Key('detailsStepNext')));
    await tester.pumpAndSettle();

    expect(container.read(createListingDraftProvider).priceCents, 0);
    expect(container.read(createListingDraftProvider).isGiveaway, isTrue);
  });

  testWidgets('Hersteller-Autocomplete schlaegt bestehende Werte vor', (
    tester,
  ) async {
    await pumpScreen(
      tester,
      draft: const CreateListingDraft(categoryId: 'c2'),
    );

    await enterTextInList(
      tester,
      _listKey,
      find.byKey(const Key('detailsStepManufacturer')),
      'ASG',
    );

    expect(find.text('ASG Corp'), findsOneWidget);
    expect(find.text('Airsoft GmbH'), findsNothing);
  });
}
