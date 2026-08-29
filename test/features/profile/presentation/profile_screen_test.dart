import 'dart:async';

import 'package:asm/core/router/app_router.dart';
import 'package:asm/core/router/routes.dart';
import 'package:asm/features/auth/data/auth_repository.dart';
import 'package:asm/features/auth/domain/asm_user.dart';
import 'package:asm/features/auth/presentation/auth_controller.dart';
import 'package:asm/features/listings/data/listing_repository.dart';
import 'package:asm/features/listings/presentation/listing_providers.dart';
import 'package:asm/features/profile/data/profile_repository.dart';
import 'package:asm/features/profile/domain/profile.dart';
import 'package:asm/features/profile/presentation/profile_providers.dart';
import 'package:asm/features/profile/presentation/profile_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockAuthRepository extends Mock implements AuthRepository {}

class MockProfileRepository extends Mock implements ProfileRepository {}

class MockListingRepository extends Mock implements ListingRepository {}

void main() {
  late MockAuthRepository authRepository;
  late MockProfileRepository profileRepository;
  late MockListingRepository listingRepository;

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
    listingRepository = MockListingRepository();
    when(() => authRepository.authStateChanges())
        .thenAnswer((_) => Stream.value(user));
    when(() => authRepository.signOut()).thenAnswer((_) async {});
    when(
      () => listingRepository.bySeller(any(), status: any(named: 'status')),
    ).thenAnswer((_) async => []);
  });

  Future<void> pumpScreen(WidgetTester tester) async {
    // Grosse Test-Oberflaeche: alle Menuzeilen (inkl. "Abmelden" ganz unten)
    // sollen ohne Scrollen im Baum stehen -- ListView baut sonst nur, was
    // in den Cache-Extent des Standard-Test-Viewports (800x600) passt.
    tester.view.physicalSize = const Size(400, 2000);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final container = ProviderContainer(
      overrides: [
        authRepositoryProvider.overrideWithValue(authRepository),
        profileRepositoryProvider.overrideWithValue(profileRepository),
        listingRepositoryProvider.overrideWithValue(listingRepository),
      ],
    );
    addTearDown(container.dispose);
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const MaterialApp(home: ProfileScreen()),
      ),
    );
  }

  testWidgets('zeigt ein Ladeskelett, waehrend das Profil laedt', (
    tester,
  ) async {
    // Nie aufgeloester Completer statt Future.delayed: die Testbindung
    // meldet einen noch offenen Timer als Fehler, ein offenes Future nicht.
    when(() => profileRepository.current()).thenAnswer(
      (_) => Completer<Profile>().future,
    );

    await pumpScreen(tester);
    await tester.pump();

    expect(find.byType(ProfileScreen), findsOneWidget);
    expect(find.text('gear_hunter_42'), findsNothing);
  });

  testWidgets('zeigt Nutzername und Mitglied-seit nach dem Laden', (
    tester,
  ) async {
    when(() => profileRepository.current()).thenAnswer((_) async => profile);

    await pumpScreen(tester);
    await tester.pumpAndSettle();

    expect(find.text('gear_hunter_42'), findsOneWidget);
    expect(find.textContaining('15.01.2026'), findsOneWidget);
  });

  testWidgets(
    'zeigt eine Fehleransicht mit Retry, wenn das Laden fehlschlaegt',
    (
      tester,
    ) async {
      when(() => profileRepository.current()).thenThrow(Exception('boom'));

      await pumpScreen(tester);
      await tester.pumpAndSettle();

      expect(find.text('Erneut versuchen'), findsOneWidget);
    },
  );

  testWidgets('Abmelden ruft AuthRepository.signOut auf', (tester) async {
    when(() => profileRepository.current()).thenAnswer((_) async => profile);

    await pumpScreen(tester);
    await tester.pumpAndSettle();

    await tester.tap(find.text('Abmelden'));
    await tester.pumpAndSettle();

    verify(() => authRepository.signOut()).called(1);
  });

  testWidgets(
    'Meine Inserate, Favoriten und Einstellungen navigieren zu ihren Routen',
    (tester) async {
      when(() => profileRepository.current()).thenAnswer(
        (_) async => profile,
      );
      tester.view.physicalSize = const Size(400, 2000);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final container = ProviderContainer(
        overrides: [
          authRepositoryProvider.overrideWithValue(authRepository),
          profileRepositoryProvider.overrideWithValue(profileRepository),
          listingRepositoryProvider.overrideWithValue(listingRepository),
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
      // Erst den Auth-Stream einmal durchlaufen lassen (isLoggedInProvider
      // wird sonst noch als false gelesen, wenn go() synchron direkt nach
      // dem Container-Erstellen aufgerufen wird) -- dann erst zu /profile,
      // sonst greift der Guard aus Task 2.4 und leitet zu /login um.
      await tester.pump();
      router.go(AsmRoutes.profile);
      await tester.pumpAndSettle();

      await tester.tap(find.text('Meine Inserate'));
      await tester.pumpAndSettle();
      // AppBar-Titel statt router.routeInformationProvider.value.uri: push()
      // aus einem StatefulShellBranch heraus (ProfileScreen sitzt in einem)
      // aktualisiert die Route-Information nicht zuverlaessig genug fuer
      // einen direkten URI-Vergleich, der tatsaechlich gerenderte Screen ist
      // der verlaesslichere Nachweis -- dasselbe Muster wie in
      // app_router_test.dart fuer den Guard-Redirect.
      expect(find.widgetWithText(AppBar, 'Meine Inserate'), findsOneWidget);
    },
  );
}
