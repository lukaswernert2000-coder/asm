import 'dart:async';

import 'package:asm/core/errors/app_exception.dart';
import 'package:asm/core/router/app_router.dart';
import 'package:asm/core/router/routes.dart';
import 'package:asm/core/storage/shared_preferences_provider.dart';
import 'package:asm/features/auth/data/auth_repository.dart';
import 'package:asm/features/auth/domain/asm_user.dart';
import 'package:asm/features/auth/presentation/auth_controller.dart';
import 'package:asm/features/categories/data/category_repository.dart';
import 'package:asm/features/categories/domain/category.dart';
import 'package:asm/features/categories/presentation/category_overview_screen.dart';
import 'package:asm/features/categories/presentation/category_providers.dart';
import 'package:asm/features/categories/presentation/category_screen.dart';
import 'package:asm/features/listings/data/listing_repository.dart';
import 'package:asm/features/listings/domain/listing_filter.dart';
import 'package:asm/features/listings/domain/listing_summary.dart';
import 'package:asm/features/listings/presentation/edit_listing_screen.dart';
import 'package:asm/features/listings/presentation/listing_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../helpers/fake_shared_preferences.dart';

class MockAuthRepository extends Mock implements AuthRepository {}

class MockCategoryRepository extends Mock implements CategoryRepository {}

class MockListingRepository extends Mock implements ListingRepository {}

void main() {
  late MockCategoryRepository categoryRepository;
  late MockListingRepository listingRepository;

  setUpAll(() {
    registerFallbackValue(const ListingFilter());
  });

  setUp(() {
    categoryRepository = MockCategoryRepository();
    listingRepository = MockListingRepository();
    when(() => categoryRepository.roots()).thenAnswer((_) async => []);
    when(() => listingRepository.search(any())).thenAnswer(
      (_) async => (items: <ListingSummary>[], total: 0),
    );
  });

  List<Override> baseOverrides(SharedPreferencesWithCache prefs) => [
    sharedPreferencesProvider.overrideWithValue(prefs),
    categoryRepositoryProvider.overrideWithValue(categoryRepository),
    listingRepositoryProvider.overrideWithValue(listingRepository),
  ];

  test('Detailroute enthaelt die Inserats-ID', () {
    expect(AsmRoutes.listing('abc-123'), '/listing/abc-123');
  });

  test('Kategorieroute nutzt den Slug', () {
    expect(AsmRoutes.category('langwaffen-saeg'), '/category/langwaffen-saeg');
  });

  group('appRouterProvider', () {
    testWidgets('startet auf der echten App, nicht im Debug-Katalog', (
      tester,
    ) async {
      final container = ProviderContainer(
        overrides: baseOverrides(await fakeSharedPreferences()),
      );
      addTearDown(container.dispose);
      final router = container.read(appRouterProvider);

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: MaterialApp.router(routerConfig: router),
        ),
      );

      expect(find.text('Widget-Katalog'), findsNothing);
      expect(find.byType(CategoryOverviewScreen), findsOneWidget);
      // Nur noch das Bottom-Nav-Label -- die Start-Branch selbst zeigt
      // keinen Platzhalter-Titel "Start" mehr, siehe Task 3.1.
      expect(find.text('Start'), findsOneWidget);
    });

    testWidgets('Debug-Katalog ist aus der App-Shell erreichbar', (
      tester,
    ) async {
      final container = ProviderContainer(
        overrides: baseOverrides(await fakeSharedPreferences()),
      );
      addTearDown(container.dispose);
      final router = container.read(appRouterProvider);

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: MaterialApp.router(routerConfig: router),
        ),
      );

      await tester.tap(find.byTooltip('Widget-Katalog'));
      // Kein pumpAndSettle: die Gallery zeigt AsmSkeleton mit einer
      // Shimmer-Animation, die nie zur Ruhe kommt.
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.text('Widget-Katalog'), findsOneWidget);
    });
  });

  group('Kategorie-Route', () {
    testWidgets('/category/:slug rendert CategoryScreen mit dem Slug', (
      tester,
    ) async {
      when(
        () => categoryRepository.bySlug('langwaffen'),
      ).thenAnswer(
        (_) async => const Category(
          id: 'c1',
          slug: 'langwaffen',
          name: 'Gewehre & MPs',
          sortOrder: 1,
          requiresAge18: true,
          requiresFMarking: true,
          requiresJoule: true,
          requiresPropulsion: true,
          isActive: true,
          icon: 'rifle',
        ),
      );
      when(
        () => categoryRepository.children('langwaffen'),
      ).thenAnswer((_) async => []);

      final container = ProviderContainer(
        overrides: baseOverrides(await fakeSharedPreferences()),
      );
      addTearDown(container.dispose);
      final router = container.read(appRouterProvider);

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: MaterialApp.router(routerConfig: router),
        ),
      );

      unawaited(router.push('/category/langwaffen'));
      await tester.pumpAndSettle();

      final screen = tester.widget<CategoryScreen>(
        find.byType(CategoryScreen),
      );
      expect(screen.slug, 'langwaffen');
      expect(find.widgetWithText(AppBar, 'Gewehre & MPs'), findsOneWidget);
    });

    testWidgets('/listing/:id rendert einen Platzhalter statt zu brechen', (
      tester,
    ) async {
      final container = ProviderContainer(
        overrides: baseOverrides(await fakeSharedPreferences()),
      );
      addTearDown(container.dispose);
      final router = container.read(appRouterProvider);

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: MaterialApp.router(routerConfig: router),
        ),
      );

      unawaited(router.push('/listing/l1'));
      await tester.pumpAndSettle();

      expect(find.widgetWithText(AppBar, 'Inserat'), findsOneWidget);
    });

    testWidgets('/listing/:id/edit rendert EditListingScreen mit der ID', (
      tester,
    ) async {
      when(
        () => listingRepository.byId('l1'),
      ).thenAnswer((_) async => throw const NotFoundException());
      final container = ProviderContainer(
        overrides: baseOverrides(await fakeSharedPreferences()),
      );
      addTearDown(container.dispose);
      final router = container.read(appRouterProvider);

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: MaterialApp.router(routerConfig: router),
        ),
      );

      unawaited(router.push('/listing/l1/edit'));
      await tester.pumpAndSettle();

      final screen = tester.widget<EditListingScreen>(
        find.byType(EditListingScreen),
      );
      expect(screen.listingId, 'l1');
    });
  });

  group('Auth-Guard', () {
    late MockAuthRepository repository;

    setUp(() {
      repository = MockAuthRepository();
      when(
        () => repository.authStateChanges(),
      ).thenAnswer((_) => const Stream<AsmUser?>.empty());
    });

    testWidgets('/create ohne Session landet auf dem Login-Screen', (
      tester,
    ) async {
      final container = ProviderContainer(
        overrides: [
          authRepositoryProvider.overrideWithValue(repository),
          ...baseOverrides(await fakeSharedPreferences()),
        ],
      );
      addTearDown(container.dispose);
      final router = container.read(appRouterProvider);

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: MaterialApp.router(routerConfig: router),
        ),
      );

      unawaited(router.push(AsmRoutes.create));
      await tester.pumpAndSettle();

      expect(find.widgetWithText(AppBar, 'Anmelden'), findsOneWidget);
    });
  });
}
