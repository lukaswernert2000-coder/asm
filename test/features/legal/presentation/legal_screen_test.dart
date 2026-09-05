import 'package:asm/features/legal/presentation/legal_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

Future<void> pumpBriefly(WidgetTester tester) async {
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 50));
}

/// Eigener Mini-Router statt `appRouterProvider`: fuer den
/// Kreuzverweis-Test (Tap auf einen `[Text](anderePage.md)`-Link) reicht die
/// eine Route, ohne den ganzen App-Provider-Graphen mocken zu muessen.
Future<GoRouter> pumpScreen(
  WidgetTester tester, {
  required String page,
  required Future<String> Function(String page) loadMarkdown,
}) async {
  final router = GoRouter(
    initialLocation: '/legal/$page',
    routes: [
      GoRoute(
        path: '/legal/:page',
        builder: (context, state) => LegalScreen(
          page: state.pathParameters['page']!,
          loadMarkdown: loadMarkdown,
        ),
      ),
    ],
  );
  await tester.pumpWidget(MaterialApp.router(routerConfig: router));
  await pumpBriefly(tester);
  return router;
}

void main() {
  testWidgets('zeigt den richtigen Titel je Seite', (tester) async {
    await pumpScreen(
      tester,
      page: 'agb',
      loadMarkdown: (page) async => '# Test',
    );

    expect(find.widgetWithText(AppBar, 'AGB'), findsOneWidget);
  });

  testWidgets('zeigt den geladenen Markdown-Inhalt', (tester) async {
    await pumpScreen(
      tester,
      page: 'datenschutz',
      loadMarkdown: (page) async => '# Datenschutzerklärung\n\nEin Testabsatz.',
    );

    // "Datenschutzerklärung" steht auch im AppBar-Titel -- hier reicht der
    // Absatztext, um zu belegen, dass der geladene Markdown-Body ankommt.
    expect(find.text('Ein Testabsatz.'), findsOneWidget);
  });

  testWidgets(
    'zeigt einen Entwurf-Hinweis statt des rohen HTML-Kommentars, wenn die erste Zeile ein ENTWURF-Marker ist',
    (tester) async {
      await pumpScreen(
        tester,
        page: 'agb',
        loadMarkdown: (page) async =>
            '<!-- ENTWURF – anwaltlich prüfen -->\n\n# Test',
      );

      expect(find.textContaining('<!--'), findsNothing);
      expect(find.textContaining('anwaltlich prüfen'), findsOneWidget);
    },
  );

  testWidgets('zeigt keinen Entwurf-Hinweis ohne ENTWURF-Marker', (
    tester,
  ) async {
    await pumpScreen(
      tester,
      page: 'agb',
      loadMarkdown: (page) async => '# Test',
    );

    expect(find.textContaining('anwaltlich prüfen'), findsNothing);
  });

  testWidgets(
    'Tap auf einen relativen .md-Link navigiert zur verlinkten Seite',
    (tester) async {
      await pumpScreen(
        tester,
        page: 'agb',
        loadMarkdown: (page) async => switch (page) {
          'agb' =>
            '# AGB\n\nSiehe [Nutzungsbedingungen](nutzungsbedingungen.md).',
          _ => '# Nutzungsbedingungen\n\nZielinhalt.',
        },
      );
      expect(find.text('Zielinhalt.'), findsNothing);

      // Der Linktext steht als TextSpan innerhalb desselben Absatzes wie
      // "Siehe " -- kein eigenstaendiges Text-Widget, `tester.tap(find.text(...))`
      // faende es deshalb nicht.
      await tester.tapOnText(find.textRange.ofSubstring('Nutzungsbedingungen'));
      await pumpBriefly(tester);

      expect(find.text('Zielinhalt.'), findsOneWidget);
      expect(
        find.widgetWithText(AppBar, 'Nutzungsbedingungen'),
        findsOneWidget,
      );
    },
  );
}
