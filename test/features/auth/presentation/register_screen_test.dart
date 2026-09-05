import 'package:asm/core/widgets/asm_button.dart';
import 'package:asm/core/widgets/asm_text_field.dart';
import 'package:asm/features/auth/data/auth_repository.dart';
import 'package:asm/features/auth/presentation/auth_controller.dart';
import 'package:asm/features/auth/presentation/register_screen.dart';
import 'package:asm/features/legal/presentation/legal_screen.dart';
import 'package:asm/features/profile/data/profile_repository.dart';
import 'package:asm/features/profile/presentation/profile_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mocktail/mocktail.dart';

class MockAuthRepository extends Mock implements AuthRepository {}

class MockProfileRepository extends Mock implements ProfileRepository {}

Finder _fieldFor(String label) => find.descendant(
  of: find.widgetWithText(AsmTextField, label),
  matching: find.byType(TextField),
);

Finder _checkboxBox(Key checkboxKey) => find.descendant(
  of: find.byKey(checkboxKey),
  matching: find.byType(GestureDetector),
);

Future<void> _fillValidForm(WidgetTester tester) async {
  await tester.enterText(_fieldFor('Nutzername'), 'gear_hunter_42');
  await tester.enterText(_fieldFor('E-Mail'), 'nutzer@example.de');
  await tester.enterText(_fieldFor('Passwort'), 'gear1234');
  await tester.pump();
  await tester.tap(_fieldFor('Geburtsdatum'));
  await tester.pump();
  await tester.tap(_checkboxBox(const Key('agb_checkbox')));
  await tester.tap(_checkboxBox(const Key('datenschutz_checkbox')));
  await tester.pump();
}

void main() {
  late MockAuthRepository authRepository;
  late MockProfileRepository profileRepository;

  Widget wrap() => ProviderScope(
    overrides: [
      authRepositoryProvider.overrideWithValue(authRepository),
      profileRepositoryProvider.overrideWithValue(profileRepository),
    ],
    child: MaterialApp(
      home: RegisterScreen(pickBirthDate: (context) async => DateTime(2000)),
    ),
  );

  setUp(() {
    authRepository = MockAuthRepository();
    profileRepository = MockProfileRepository();
    when(
      () => profileRepository.isUsernameTaken(any()),
    ).thenAnswer((_) async => false);
    when(
      () => authRepository.signUp(
        email: any(named: 'email'),
        password: any(named: 'password'),
        data: any(named: 'data'),
      ),
    ).thenAnswer((_) async {});
  });

  Finder submitButton() => find.widgetWithText(AsmButton, 'Registrieren');

  testWidgets(
    'Absenden ist deaktiviert, solange ein Feld ungueltig ist',
    (tester) async {
      await tester.pumpWidget(wrap());

      expect(tester.widget<AsmButton>(submitButton()).onPressed, isNull);

      await _fillValidForm(tester);

      expect(tester.widget<AsmButton>(submitButton()).onPressed, isNotNull);
    },
  );

  testWidgets(
    'gueltiges Formular registriert und zeigt die Bestaetigungs-E-Mail-Ansicht',
    (tester) async {
      await tester.pumpWidget(wrap());
      await _fillValidForm(tester);

      await tester.tap(submitButton());
      await tester.pumpAndSettle();

      verify(
        () => authRepository.signUp(
          email: 'nutzer@example.de',
          password: 'gear1234',
          data: {'username': 'gear_hunter_42'},
        ),
      ).called(1);
      expect(find.text('Bestätige deine E-Mail'), findsOneWidget);
    },
  );

  testWidgets(
    'vergebener Nutzername zeigt Fehler und registriert nicht',
    (tester) async {
      when(
        () => profileRepository.isUsernameTaken('gear_hunter_42'),
      ).thenAnswer((_) async => true);

      await tester.pumpWidget(wrap());
      await _fillValidForm(tester);

      await tester.tap(submitButton());
      await tester.pumpAndSettle();

      expect(find.text('Nutzername ist vergeben'), findsOneWidget);
      verifyNever(
        () => authRepository.signUp(
          email: any(named: 'email'),
          password: any(named: 'password'),
          data: any(named: 'data'),
        ),
      );
    },
  );

  // Eigener Mini-Router statt des einfachen `wrap()` oben: die Links
  // navigieren jetzt in die App (Task 7.2), `context.push` braucht dafuer
  // einen echten GoRouter im Baum. `LegalScreen` bekommt eine gefakte
  // `loadMarkdown`, damit kein echtes Asset geladen werden muss.
  Widget wrapWithRouter() {
    final router = GoRouter(
      initialLocation: '/register',
      routes: [
        GoRoute(
          path: '/register',
          builder: (context, state) =>
              RegisterScreen(pickBirthDate: (context) async => DateTime(2000)),
        ),
        GoRoute(
          path: '/legal/:page',
          builder: (context, state) => LegalScreen(
            page: state.pathParameters['page']!,
            loadMarkdown: (page) async => '# Test',
          ),
        ),
      ],
    );
    return ProviderScope(
      overrides: [
        authRepositoryProvider.overrideWithValue(authRepository),
        profileRepositoryProvider.overrideWithValue(profileRepository),
      ],
      child: MaterialApp.router(routerConfig: router),
    );
  }

  testWidgets('Tap auf AGB-Link oeffnet die AGB-Seite in der App', (
    tester,
  ) async {
    await tester.pumpWidget(wrapWithRouter());

    await tester.tapOnText(find.textRange.ofSubstring('AGB'));
    await tester.pumpAndSettle();

    expect(find.widgetWithText(AppBar, 'AGB'), findsOneWidget);
  });

  testWidgets(
    'Tap auf Datenschutz-Link oeffnet die Datenschutz-Seite in der App',
    (tester) async {
      await tester.pumpWidget(wrapWithRouter());

      await tester.tapOnText(
        find.textRange.ofSubstring('Datenschutzerklärung'),
      );
      await tester.pumpAndSettle();

      expect(
        find.widgetWithText(AppBar, 'Datenschutzerklärung'),
        findsOneWidget,
      );
    },
  );
}
