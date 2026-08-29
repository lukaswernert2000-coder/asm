import 'dart:async';

import 'package:asm/core/router/app_router.dart';
import 'package:asm/core/router/routes.dart';
import 'package:asm/core/storage/shared_preferences_provider.dart';
import 'package:asm/features/auth/data/auth_repository.dart';
import 'package:asm/features/auth/domain/asm_user.dart';
import 'package:asm/features/auth/presentation/auth_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../helpers/fake_shared_preferences.dart';

class MockAuthRepository extends Mock implements AuthRepository {}

void main() {
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
        overrides: [
          sharedPreferencesProvider.overrideWithValue(
            await fakeSharedPreferences(),
          ),
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

      expect(find.text('Widget-Katalog'), findsNothing);
      // Bottom-Nav-Label und Platzhalter-Titel der Start-Branch.
      expect(find.text('Start'), findsNWidgets(2));
    });

    testWidgets('Debug-Katalog ist aus der App-Shell erreichbar', (
      tester,
    ) async {
      final container = ProviderContainer(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(
            await fakeSharedPreferences(),
          ),
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

      await tester.tap(find.byTooltip('Widget-Katalog'));
      // Kein pumpAndSettle: die Gallery zeigt AsmSkeleton mit einer
      // Shimmer-Animation, die nie zur Ruhe kommt.
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.text('Widget-Katalog'), findsOneWidget);
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
          sharedPreferencesProvider.overrideWithValue(
            await fakeSharedPreferences(),
          ),
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
