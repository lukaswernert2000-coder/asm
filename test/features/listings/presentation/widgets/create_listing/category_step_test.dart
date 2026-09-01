import 'package:asm/core/storage/shared_preferences_provider.dart';
import 'package:asm/core/supabase/supabase_provider.dart';
import 'package:asm/features/categories/data/category_repository.dart';
import 'package:asm/features/categories/domain/category.dart';
import 'package:asm/features/categories/presentation/category_providers.dart';
import 'package:asm/features/listings/presentation/create_listing_providers.dart';
import 'package:asm/features/listings/presentation/widgets/create_listing/category_step.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../../helpers/fake_shared_preferences.dart';

class MockCategoryRepository extends Mock implements CategoryRepository {}

class MockSupabaseClient extends Mock implements SupabaseClient {}

void main() {
  late MockCategoryRepository categoryRepository;

  const pistolen = Category(
    id: 'p1',
    slug: 'pistolen',
    name: 'Pistolen',
    sortOrder: 1,
    requiresAge18: true,
    requiresFMarking: true,
    requiresJoule: true,
    requiresPropulsion: true,
    isActive: true,
  );
  const zubehoer = Category(
    id: 'p2',
    slug: 'zubehoer',
    name: 'Zubehör',
    sortOrder: 2,
    requiresAge18: false,
    requiresFMarking: false,
    requiresJoule: false,
    requiresPropulsion: false,
    isActive: true,
  );
  const revolver = Category(
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
  const magazine = Category(
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
    when(
      () => categoryRepository.roots(),
    ).thenAnswer((_) async => [pistolen, zubehoer]);
    when(
      () => categoryRepository.children('pistolen'),
    ).thenAnswer((_) async => [revolver]);
    when(
      () => categoryRepository.children('zubehoer'),
    ).thenAnswer((_) async => [magazine]);
    when(
      () => categoryRepository.all(),
    ).thenAnswer((_) async => [pistolen, zubehoer, revolver, magazine]);
  });

  Future<ProviderContainer> pumpScreen(WidgetTester tester) async {
    final container = ProviderContainer(
      overrides: [
        categoryRepositoryProvider.overrideWithValue(categoryRepository),
        supabaseProvider.overrideWithValue(MockSupabaseClient()),
        sharedPreferencesProvider.overrideWithValue(
          await fakeSharedPreferences(),
        ),
      ],
    );
    addTearDown(container.dispose);
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp(
          home: Scaffold(body: CategoryStep(onNext: () {})),
        ),
      ),
    );
    await tester.pumpAndSettle();
    return container;
  }

  testWidgets('zeigt Wurzelkategorien, Weiter ist zunaechst deaktiviert', (
    tester,
  ) async {
    await pumpScreen(tester);

    expect(find.text('Pistolen'), findsOneWidget);
    expect(find.text('Zubehör'), findsOneWidget);
    expect(find.text('Revolver'), findsNothing);

    final inkWell = tester.widget<InkWell>(
      find.descendant(
        of: find.byKey(const Key('categoryStepNext')),
        matching: find.byType(InkWell),
      ),
    );
    expect(inkWell.onTap, isNull);
  });

  testWidgets(
    'Tap auf Wurzel zeigt ihre Kinder, Auswahl eines Kindes aktiviert Weiter',
    (
      tester,
    ) async {
      final container = await pumpScreen(tester);

      await tester.tap(find.text('Pistolen'));
      await tester.pumpAndSettle();
      expect(find.text('Revolver'), findsOneWidget);

      await tester.tap(find.text('Revolver'));
      await tester.pumpAndSettle();

      expect(
        container.read(createListingDraftProvider).categoryId,
        'c1',
      );
    },
  );

  testWidgets(
    'erneutes Tippen auf eine expandierte Wurzel klappt sie wieder ein',
    (tester) async {
      await pumpScreen(tester);

      await tester.tap(find.text('Pistolen'));
      await tester.pumpAndSettle();
      expect(find.text('Revolver'), findsOneWidget);

      await tester.tap(find.text('Pistolen'));
      await tester.pumpAndSettle();

      expect(find.text('Revolver'), findsNothing);
    },
  );

  testWidgets(
    'Wurzel antippen klappt eine zuvor expandierte andere Wurzel ein',
    (tester) async {
      await pumpScreen(tester);

      await tester.tap(find.text('Pistolen'));
      await tester.pumpAndSettle();
      expect(find.text('Revolver'), findsOneWidget);

      await tester.tap(find.text('Zubehör'));
      await tester.pumpAndSettle();

      expect(find.text('Revolver'), findsNothing);
      expect(find.text('Magazine'), findsOneWidget);
    },
  );

  testWidgets('Weiter ruft onNext und setzt Schritt auf 1', (tester) async {
    var nextCalled = false;
    final container = ProviderContainer(
      overrides: [
        categoryRepositoryProvider.overrideWithValue(categoryRepository),
        supabaseProvider.overrideWithValue(MockSupabaseClient()),
        sharedPreferencesProvider.overrideWithValue(
          await fakeSharedPreferences(),
        ),
      ],
    );
    addTearDown(container.dispose);
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp(
          home: Scaffold(
            body: CategoryStep(onNext: () => nextCalled = true),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Pistolen'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Revolver'));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('categoryStepNext')));
    await tester.pumpAndSettle();

    expect(nextCalled, isTrue);
    expect(container.read(createListingDraftProvider).step, 1);
  });

  testWidgets('Suche filtert auf Blattkategorien ueber alle Wurzeln', (
    tester,
  ) async {
    final container = await pumpScreen(tester);

    await tester.enterText(
      find.byKey(const Key('categoryStepSearch')),
      'maga',
    );
    await tester.pumpAndSettle();

    expect(find.text('Magazine'), findsOneWidget);
    expect(find.text('Revolver'), findsNothing);
    // Wurzeln selbst sind nie Treffer (kein Blatt).
    expect(find.text('Zubehör'), findsNothing);

    await tester.tap(find.text('Magazine'));
    await tester.pumpAndSettle();

    expect(container.read(createListingDraftProvider).categoryId, 'c2');
  });
}
