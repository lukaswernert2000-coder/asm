import 'package:asm/core/router/routes.dart';
import 'package:asm/features/auth/presentation/confirm_email_required_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

void main() {
  Widget wrap() => MaterialApp.router(
    routerConfig: GoRouter(
      initialLocation: AsmRoutes.confirmEmail,
      routes: [
        GoRoute(
          path: AsmRoutes.confirmEmail,
          builder: (context, state) => const ConfirmEmailRequiredScreen(),
        ),
        GoRoute(
          path: AsmRoutes.home,
          builder: (context, state) => const Scaffold(body: Text('Start')),
        ),
      ],
    ),
  );

  testWidgets('zeigt den Hinweistext zur E-Mail-Bestaetigung', (tester) async {
    await tester.pumpWidget(wrap());

    expect(find.text('Bitte bestätige zuerst deine E-Mail'), findsOneWidget);
  });

  testWidgets('Button fuehrt zurueck zum Start', (tester) async {
    await tester.pumpWidget(wrap());

    await tester.tap(find.text('Zur Startseite'));
    await tester.pumpAndSettle();

    expect(find.text('Start'), findsOneWidget);
  });
}
