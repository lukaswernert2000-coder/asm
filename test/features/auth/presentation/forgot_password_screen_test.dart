import 'package:asm/core/errors/app_exception.dart';
import 'package:asm/core/widgets/asm_button.dart';
import 'package:asm/core/widgets/asm_text_field.dart';
import 'package:asm/features/auth/data/auth_repository.dart';
import 'package:asm/features/auth/presentation/auth_controller.dart';
import 'package:asm/features/auth/presentation/forgot_password_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockAuthRepository extends Mock implements AuthRepository {}

Finder _emailField() => find.descendant(
  of: find.widgetWithText(AsmTextField, 'E-Mail'),
  matching: find.byType(TextField),
);

Finder submitButton() => find.widgetWithText(AsmButton, 'Link anfordern');

void main() {
  late MockAuthRepository repository;

  Widget wrap() => ProviderScope(
    overrides: [authRepositoryProvider.overrideWithValue(repository)],
    child: const MaterialApp(home: ForgotPasswordScreen()),
  );

  setUp(() {
    repository = MockAuthRepository();
  });

  testWidgets('Absenden ist deaktiviert, solange die E-Mail ungueltig ist', (
    tester,
  ) async {
    await tester.pumpWidget(wrap());
    expect(tester.widget<AsmButton>(submitButton()).onPressed, isNull);

    await tester.enterText(_emailField(), 'keine-email');
    await tester.pump();
    expect(tester.widget<AsmButton>(submitButton()).onPressed, isNull);

    await tester.enterText(_emailField(), 'nutzer@example.de');
    await tester.pump();
    expect(tester.widget<AsmButton>(submitButton()).onPressed, isNotNull);
  });

  testWidgets(
    'ruft resetPassword auf und zeigt eine enumerationssichere Bestaetigung',
    (tester) async {
      when(
        () => repository.resetPassword(any()),
      ).thenAnswer((_) async {});

      await tester.pumpWidget(wrap());
      await tester.enterText(_emailField(), 'nutzer@example.de');
      await tester.pump();

      await tester.tap(submitButton());
      await tester.pumpAndSettle();

      verify(() => repository.resetPassword('nutzer@example.de')).called(1);
      expect(
        find.textContaining('Falls ein Konto mit dieser E-Mail'),
        findsOneWidget,
      );
    },
  );

  testWidgets('zeigt eine Fehlermeldung, wenn resetPassword fehlschlaegt', (
    tester,
  ) async {
    when(
      () => repository.resetPassword(any()),
    ).thenThrow(const NetworkException());

    await tester.pumpWidget(wrap());
    await tester.enterText(_emailField(), 'nutzer@example.de');
    await tester.pump();

    await tester.tap(submitButton());
    await tester.pumpAndSettle();

    expect(find.text(const NetworkException().message), findsOneWidget);
  });
}
