import 'dart:async';

import 'package:asm/app.dart';
import 'package:asm/core/router/app_router.dart';
import 'package:asm/core/router/routes.dart';
import 'package:asm/features/auth/data/auth_repository.dart';
import 'package:asm/features/auth/presentation/auth_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:supabase_flutter/supabase_flutter.dart' show AuthChangeEvent;

class MockAuthRepository extends Mock implements AuthRepository {}

void main() {
  late MockAuthRepository repository;
  late StreamController<AuthChangeEvent> eventController;
  late ProviderContainer container;

  setUp(() {
    repository = MockAuthRepository();
    eventController = StreamController<AuthChangeEvent>.broadcast();
    when(() => repository.authEvents()).thenAnswer((_) => eventController.stream);
    when(
      () => repository.authStateChanges(),
    ).thenAnswer((_) => const Stream.empty());
    container = ProviderContainer(
      overrides: [authRepositoryProvider.overrideWithValue(repository)],
    );
    addTearDown(container.dispose);
    addTearDown(eventController.close);
  });

  Future<void> pumpApp(WidgetTester tester) async {
    await tester.pumpWidget(
      UncontrolledProviderScope(container: container, child: const AsmApp()),
    );
  }

  testWidgets('navigiert zu / bei AuthChangeEvent.signedIn', (tester) async {
    await pumpApp(tester);
    container.read(appRouterProvider).go(AsmRoutes.register);
    await tester.pumpAndSettle();
    expect(find.widgetWithText(AppBar, 'Registrieren'), findsOneWidget);

    eventController.add(AuthChangeEvent.signedIn);
    await tester.pumpAndSettle();

    expect(find.widgetWithText(AppBar, 'Registrieren'), findsNothing);
  });

  testWidgets(
    'navigiert zu /reset-password bei AuthChangeEvent.passwordRecovery',
    (tester) async {
      await pumpApp(tester);

      eventController.add(AuthChangeEvent.passwordRecovery);
      await tester.pumpAndSettle();

      expect(find.widgetWithText(AppBar, 'Neues Passwort'), findsOneWidget);
    },
  );

  testWidgets('andere Events loesen kein Redirect aus', (tester) async {
    await pumpApp(tester);
    container.read(appRouterProvider).go(AsmRoutes.register);
    await tester.pumpAndSettle();

    eventController.add(AuthChangeEvent.tokenRefreshed);
    await tester.pumpAndSettle();

    expect(find.widgetWithText(AppBar, 'Registrieren'), findsOneWidget);
  });
}
