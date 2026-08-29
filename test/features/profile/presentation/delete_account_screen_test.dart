import 'package:asm/core/errors/app_exception.dart';
import 'package:asm/core/router/app_router.dart';
import 'package:asm/core/router/routes.dart';
import 'package:asm/core/widgets/asm_button.dart';
import 'package:asm/features/auth/data/auth_repository.dart';
import 'package:asm/features/auth/domain/asm_user.dart';
import 'package:asm/features/auth/presentation/auth_controller.dart';
import 'package:asm/features/profile/data/profile_repository.dart';
import 'package:asm/features/profile/domain/profile.dart';
import 'package:asm/features/profile/presentation/delete_account_screen.dart';
import 'package:asm/features/profile/presentation/profile_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockAuthRepository extends Mock implements AuthRepository {}

class MockProfileRepository extends Mock implements ProfileRepository {}

void main() {
  late MockAuthRepository authRepository;
  late MockProfileRepository profileRepository;

  const user = AsmUser(id: 'u1', email: 'a@b.de', emailConfirmed: true);
  final profile = Profile(
    id: 'u1',
    username: 'gear_hunter_42',
    isCommercial: false,
    role: UserRole.user,
    createdAt: DateTime(2026, 1, 15),
    lastSeenAt: DateTime(2026, 8, 29),
  );

  setUp(() {
    authRepository = MockAuthRepository();
    profileRepository = MockProfileRepository();
    when(() => authRepository.authStateChanges())
        .thenAnswer((_) => Stream.value(user));
    when(() => profileRepository.current()).thenAnswer((_) async => profile);
    when(() => authRepository.deleteAccount()).thenAnswer((_) async {});
  });

  // MaterialApp.router statt nur MaterialApp(home:...): der Screen ruft nach
  // erfolgreichem Loeschen `context.go(AsmRoutes.login)` auf, das braucht
  // einen echten GoRouter im Kontext -- gilt auch fuer Tests, die nur den
  // Bestaetigen-Button pruefen, aber am Ende erfolgreich durchlaufen.
  Future<void> pumpScreen(WidgetTester tester) async {
    final container = ProviderContainer(
      overrides: [
        authRepositoryProvider.overrideWithValue(authRepository),
        profileRepositoryProvider.overrideWithValue(profileRepository),
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
    // Erst den Auth-Stream einmal durchlaufen lassen, dann erst navigieren --
    // sonst greift der Guard aus Task 2.4, siehe profile_screen_test.dart.
    await tester.pump();
    router.go(AsmRoutes.deleteAccount);
    await tester.pumpAndSettle();
  }

  testWidgets('zeigt Warntext und den Loeschen-Button', (tester) async {
    await pumpScreen(tester);

    expect(find.text('Account löschen'), findsWidgets);
    expect(find.textContaining('unwiderruflich'), findsOneWidget);
  });

  testWidgets(
    'Bestaetigen bleibt disabled bis der Nutzername exakt eingetippt ist',
    (tester) async {
      await pumpScreen(tester);

      await tester.tap(find.byType(AsmButton));
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField), 'falscher_name');
      await tester.pumpAndSettle();
      await tester.tap(find.text('Endgültig löschen'));
      await tester.pumpAndSettle();

      verifyNever(() => authRepository.deleteAccount());

      await tester.enterText(find.byType(TextField), 'gear_hunter_42');
      await tester.pumpAndSettle();
      await tester.tap(find.text('Endgültig löschen'));
      await tester.pumpAndSettle();

      verify(() => authRepository.deleteAccount()).called(1);
    },
  );

  testWidgets('Abbrechen ruft deleteAccount nicht auf', (tester) async {
    await pumpScreen(tester);

    await tester.tap(find.byType(AsmButton));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Abbrechen'));
    await tester.pumpAndSettle();

    verifyNever(() => authRepository.deleteAccount());
  });

  testWidgets('zeigt eine Fehlermeldung, wenn deleteAccount fehlschlaegt', (
    tester,
  ) async {
    when(
      () => authRepository.deleteAccount(),
    ).thenThrow(const UnknownException());
    await pumpScreen(tester);

    await tester.tap(find.byType(AsmButton));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), 'gear_hunter_42');
    await tester.pumpAndSettle();
    await tester.tap(find.text('Endgültig löschen'));
    await tester.pumpAndSettle();

    expect(find.text('Etwas ist schiefgelaufen.'), findsOneWidget);
    expect(find.byType(DeleteAccountScreen), findsOneWidget);
  });

  testWidgets('erfolgreiches Loeschen navigiert zu /login', (tester) async {
    await pumpScreen(tester);

    await tester.tap(find.byType(AsmButton));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), 'gear_hunter_42');
    await tester.pumpAndSettle();
    await tester.tap(find.text('Endgültig löschen'));
    await tester.pumpAndSettle();

    expect(find.byType(DeleteAccountScreen), findsNothing);
  });
}
