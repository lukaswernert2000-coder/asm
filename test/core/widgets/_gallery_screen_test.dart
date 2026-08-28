import 'package:asm/core/router/routes.dart';
import 'package:asm/core/widgets/_gallery_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

void main() {
  testWidgets('bietet einen Weg zurueck zur App', (tester) async {
    final router = GoRouter(
      initialLocation: '/_gallery',
      routes: [
        GoRoute(
          path: '/_gallery',
          builder: (context, state) => const GalleryScreen(),
        ),
        GoRoute(
          path: AsmRoutes.home,
          builder: (context, state) => const Text('Start-Platzhalter'),
        ),
      ],
    );

    await tester.pumpWidget(MaterialApp.router(routerConfig: router));
    expect(find.text('Widget-Katalog'), findsOneWidget);

    await tester.tap(find.byTooltip('Zur App'));
    await tester.pumpAndSettle();

    expect(find.text('Start-Platzhalter'), findsOneWidget);
  });
}
