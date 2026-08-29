import 'package:asm/core/router/app_router.dart';
import 'package:asm/core/router/routes.dart';
import 'package:asm/features/auth/data/auth_repository.dart';
import 'package:asm/features/auth/domain/asm_user.dart';
import 'package:asm/features/auth/presentation/auth_controller.dart';
import 'package:asm/features/listings/data/listing_repository.dart';
import 'package:asm/features/listings/presentation/listing_providers.dart';
import 'package:asm/features/moderation/data/moderation_repository.dart';
import 'package:asm/features/moderation/domain/report_reason.dart';
import 'package:asm/features/moderation/presentation/moderation_providers.dart';
import 'package:asm/features/profile/data/profile_repository.dart';
import 'package:asm/features/profile/domain/profile.dart';
import 'package:asm/features/profile/presentation/profile_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mocktail/mocktail.dart';

class MockAuthRepository extends Mock implements AuthRepository {}

class MockProfileRepository extends Mock implements ProfileRepository {}

class MockListingRepository extends Mock implements ListingRepository {}

class MockModerationRepository extends Mock implements ModerationRepository {}

void main() {
  setUpAll(() {
    registerFallbackValue(ReportReason.sonstiges);
  });

  late MockAuthRepository authRepository;
  late MockProfileRepository profileRepository;
  late MockListingRepository listingRepository;
  late MockModerationRepository moderationRepository;

  const guest = AsmUser(id: 'me', email: 'a@b.de', emailConfirmed: true);
  final theirProfile = Profile(
    id: 'them',
    username: 'trader99',
    isCommercial: false,
    role: UserRole.user,
    createdAt: DateTime(2026, 2),
    lastSeenAt: DateTime(2026, 8, 29),
  );

  setUp(() {
    authRepository = MockAuthRepository();
    profileRepository = MockProfileRepository();
    listingRepository = MockListingRepository();
    moderationRepository = MockModerationRepository();
    when(() => profileRepository.byId('them')).thenAnswer(
      (_) async => theirProfile,
    );
    when(
      () => listingRepository.bySeller('them', status: any(named: 'status')),
    ).thenAnswer((_) async => []);
    when(
      () => moderationRepository.reportUser(
        any(),
        any(),
        details: any(named: 'details'),
      ),
    ).thenAnswer((_) async {});
    when(
      () => moderationRepository.blockUser(any()),
    ).thenAnswer((_) async {});
  });

  // Kein pumpAndSettle: die aktiven Inserate laden ueber AsmSkeleton, dessen
  // Shimmer-Endlosanimation nie zur Ruhe kommt (gleiches Problem wie beim
  // Widget-Katalog in Task 0.6, siehe DECISIONS.md) -- stattdessen gezielt
  // pumpen, bis die gemockten Futures aufgeloest sind.
  Future<void> pumpBriefly(WidgetTester tester) async {
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));
  }

  Future<GoRouter> pumpScreen(
    WidgetTester tester, {
    required bool loggedIn,
  }) async {
    when(() => authRepository.authStateChanges()).thenAnswer(
      (_) => Stream.value(loggedIn ? guest : null),
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
        moderationRepositoryProvider.overrideWithValue(moderationRepository),
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
    await tester.pump();
    router.go(AsmRoutes.publicProfile('them'));
    await pumpBriefly(tester);
    return router;
  }

  testWidgets('zeigt Nutzername und Mitglied-seit des Fremdprofils', (
    tester,
  ) async {
    await pumpScreen(tester, loggedIn: true);

    expect(find.text('trader99'), findsOneWidget);
    expect(find.textContaining('01.02.2026'), findsOneWidget);
  });

  testWidgets(
    'Melden zeigt den Grund-Dialog, Absenden meldet mit dem gewaehlten Grund',
    (tester) async {
      await pumpScreen(tester, loggedIn: true);

      await tester.tap(find.text('Melden'));
      await pumpBriefly(tester);
      await tester.tap(find.text('Spam'));
      await pumpBriefly(tester);
      await tester.tap(find.text('Melden bestätigen'));
      await pumpBriefly(tester);

      verify(
        () => moderationRepository.reportUser(
          'them',
          ReportReason.spam,
          details: any(named: 'details'),
        ),
      ).called(1);
    },
  );

  testWidgets('Blockieren fragt nach Bestaetigung, dann wird blockiert', (
    tester,
  ) async {
    await pumpScreen(tester, loggedIn: true);

    await tester.tap(find.text('Blockieren'));
    await pumpBriefly(tester);
    await tester.tap(find.text('Blockieren bestätigen'));
    await pumpBriefly(tester);

    verify(() => moderationRepository.blockUser('them')).called(1);
  });

  testWidgets('Gast-Tap auf Melden leitet zu /login um, statt zu melden', (
    tester,
  ) async {
    final router = await pumpScreen(tester, loggedIn: false);

    await tester.tap(find.text('Melden'));
    await pumpBriefly(tester);

    expect(
      router.routeInformationProvider.value.uri.toString(),
      '/login?from=${AsmRoutes.publicProfile('them')}',
    );
    verifyNever(
      () => moderationRepository.reportUser(
        any(),
        any(),
        details: any(named: 'details'),
      ),
    );
  });
}
