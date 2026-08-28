import 'package:asm/core/router/app_router.dart';
import 'package:asm/core/router/routes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

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
      final container = ProviderContainer();
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
      final container = ProviderContainer();
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
}
