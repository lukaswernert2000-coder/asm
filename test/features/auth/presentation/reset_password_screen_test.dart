import 'package:asm/core/errors/app_exception.dart';
import 'package:asm/core/router/routes.dart';
import 'package:asm/core/widgets/asm_button.dart';
import 'package:asm/core/widgets/asm_text_field.dart';
import 'package:asm/features/auth/data/auth_repository.dart';
import 'package:asm/features/auth/presentation/auth_controller.dart';
import 'package:asm/features/auth/presentation/reset_password_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mocktail/mocktail.dart';

class MockAuthRepository extends Mock implements AuthRepository {}

Finder _passwordField() => find.descendant(
  of: find.widgetWithText(AsmTextField, 'Neues Passwort'),
  matching: find.byType(TextField),
);

Finder submitButton() => find.widgetWithText(AsmButton, 'Passwort speichern');

void main() {
  late MockAuthRepository repository;

  Widget wrap() => ProviderScope(
    overrides: [authRepositoryProvider.overrideWithValue(repository)],
    child: MaterialApp.router(
      routerConfig: GoRouter(
        initialLocation: AsmRoutes.resetPassword,
        routes: [
          GoRoute(
            path: AsmRoutes.resetPassword,
            builder: (context, state) => const ResetPasswordScreen(),
          ),
          GoRoute(
            path: AsmRoutes.home,
            builder: (context, state) =>
                const Scaffold(body: Text('Start-Screen')),
          ),
        ],
      ),
    ),
  );

  setUp(() {
    repository = MockAuthRepository();
  });

  testWidgets('Absenden ist deaktiviert, solange das Passwort ungueltig ist', (
    tester,
  ) async {
    await tester.pumpWidget(wrap());
    expect(tester.widget<AsmButton>(submitButton()).onPressed, isNull);

    await tester.enterText(_passwordField(), 'zukurz');
    await tester.pump();
    expect(tester.widget<AsmButton>(submitButton()).onPressed, isNull);

    await tester.enterText(_passwordField(), 'gueltig123');
    await tester.pump();
    expect(tester.widget<AsmButton>(submitButton()).onPressed, isNotNull);
  });

  testWidgets(
    'ruft updatePassword auf und leitet danach auf / weiter',
    (tester) async {
      when(() => repository.updatePassword(any())).thenAnswer((_) async {});

      await tester.pumpWidget(wrap());
      await tester.enterText(_passwordField(), 'gueltig123');
      await tester.pump();

      await tester.tap(submitButton());
      await tester.pumpAndSettle();

      verify(() => repository.updatePassword('gueltig123')).called(1);
      expect(find.text('Start-Screen'), findsOneWidget);
    },
  );

  testWidgets('zeigt eine Fehlermeldung, wenn updatePassword fehlschlaegt', (
    tester,
  ) async {
    when(
      () => repository.updatePassword(any()),
    ).thenThrow(const NetworkException());

    await tester.pumpWidget(wrap());
    await tester.enterText(_passwordField(), 'gueltig123');
    await tester.pump();

    await tester.tap(submitButton());
    await tester.pumpAndSettle();

    expect(find.text(const NetworkException().message), findsOneWidget);
    expect(find.text('Start-Screen'), findsNothing);
  });
}
