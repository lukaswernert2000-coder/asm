import 'package:asm/core/errors/app_exception.dart';
import 'package:asm/core/router/routes.dart';
import 'package:asm/core/widgets/asm_button.dart';
import 'package:asm/core/widgets/asm_text_field.dart';
import 'package:asm/features/auth/data/auth_repository.dart';
import 'package:asm/features/auth/presentation/auth_controller.dart';
import 'package:asm/features/auth/presentation/login_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mocktail/mocktail.dart';

class MockAuthRepository extends Mock implements AuthRepository {}

Finder _fieldFor(String label) => find.descendant(
  of: find.widgetWithText(AsmTextField, label),
  matching: find.byType(TextField),
);

Finder submitButton() => find.widgetWithText(AsmButton, 'Anmelden');

void main() {
  late MockAuthRepository repository;

  Widget wrap() => ProviderScope(
    overrides: [authRepositoryProvider.overrideWithValue(repository)],
    child: MaterialApp.router(
      routerConfig: GoRouter(
        initialLocation: AsmRoutes.login,
        routes: [
          GoRoute(
            path: AsmRoutes.login,
            builder: (context, state) => const LoginScreen(),
          ),
          GoRoute(
            path: AsmRoutes.forgotPassword,
            builder: (context, state) =>
                const Scaffold(body: Text('Passwort-vergessen-Screen')),
          ),
          GoRoute(
            path: AsmRoutes.register,
            builder: (context, state) =>
                const Scaffold(body: Text('Registrierungs-Screen')),
          ),
        ],
      ),
    ),
  );

  setUp(() {
    repository = MockAuthRepository();
  });

  testWidgets('Absenden ist deaktiviert, solange ein Feld leer ist', (
    tester,
  ) async {
    await tester.pumpWidget(wrap());

    expect(tester.widget<AsmButton>(submitButton()).onPressed, isNull);

    await tester.enterText(_fieldFor('E-Mail'), 'nutzer@example.de');
    await tester.pump();
    expect(tester.widget<AsmButton>(submitButton()).onPressed, isNull);

    await tester.enterText(_fieldFor('Passwort'), 'geheim123');
    await tester.pump();
    expect(tester.widget<AsmButton>(submitButton()).onPressed, isNotNull);
  });

  testWidgets('ruft signIn mit den eingegebenen Daten auf', (tester) async {
    when(
      () => repository.signIn(
        email: any(named: 'email'),
        password: any(named: 'password'),
      ),
    ).thenAnswer((_) async {});

    await tester.pumpWidget(wrap());
    await tester.enterText(_fieldFor('E-Mail'), 'nutzer@example.de');
    await tester.enterText(_fieldFor('Passwort'), 'geheim123');
    await tester.pump();

    await tester.tap(submitButton());
    await tester.pumpAndSettle();

    verify(
      () => repository.signIn(
        email: 'nutzer@example.de',
        password: 'geheim123',
      ),
    ).called(1);
  });

  testWidgets(
    'zeigt bei fehlgeschlagenem Login immer die generische Fehlermeldung, '
    'nie die rohe Exception-Message (Nutzer-Enumeration)',
    (tester) async {
      when(
        () => repository.signIn(
          email: any(named: 'email'),
          password: any(named: 'password'),
        ),
      ).thenThrow(const ValidationException('Nutzer existiert nicht'));

      await tester.pumpWidget(wrap());
      await tester.enterText(_fieldFor('E-Mail'), 'nutzer@example.de');
      await tester.enterText(_fieldFor('Passwort'), 'falsch123');
      await tester.pump();

      await tester.tap(submitButton());
      await tester.pumpAndSettle();

      expect(find.text('E-Mail oder Passwort ist falsch'), findsOneWidget);
      expect(find.text('Nutzer existiert nicht'), findsNothing);
    },
  );

  testWidgets('Tap auf "Passwort vergessen" navigiert dorthin', (
    tester,
  ) async {
    await tester.pumpWidget(wrap());

    await tester.tap(find.text('Passwort vergessen?'));
    await tester.pumpAndSettle();

    expect(find.text('Passwort-vergessen-Screen'), findsOneWidget);
  });

  testWidgets('Tap auf "Registrieren" navigiert dorthin', (tester) async {
    await tester.pumpWidget(wrap());

    await tester.tap(find.text('Registrieren'));
    await tester.pumpAndSettle();

    expect(find.text('Registrierungs-Screen'), findsOneWidget);
  });
}
