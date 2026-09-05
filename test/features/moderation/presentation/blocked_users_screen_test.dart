import 'package:asm/core/router/app_router.dart';
import 'package:asm/core/router/routes.dart';
import 'package:asm/core/storage/shared_preferences_provider.dart';
import 'package:asm/features/auth/data/auth_repository.dart';
import 'package:asm/features/auth/domain/asm_user.dart';
import 'package:asm/features/auth/presentation/auth_controller.dart';
import 'package:asm/features/moderation/data/moderation_repository.dart';
import 'package:asm/features/moderation/presentation/moderation_providers.dart';
import 'package:asm/features/profile/data/profile_repository.dart';
import 'package:asm/features/profile/domain/profile.dart';
import 'package:asm/features/profile/presentation/profile_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mocktail/mocktail.dart';

import '../../../helpers/fake_shared_preferences.dart';

class MockAuthRepository extends Mock implements AuthRepository {}

class MockModerationRepository extends Mock implements ModerationRepository {}

class MockProfileRepository extends Mock implements ProfileRepository {}

void main() {
  late MockAuthRepository authRepository;
  late MockModerationRepository moderationRepository;
  late MockProfileRepository profileRepository;

  const me = AsmUser(id: 'me', email: 'a@b.de', emailConfirmed: true);
  final blockedProfile = Profile(
    id: 'u1',
    username: 'blockiert123',
    isCommercial: false,
    role: UserRole.user,
    createdAt: DateTime(2026, 2),
    lastSeenAt: DateTime(2026, 8, 29),
  );

  setUp(() {
    authRepository = MockAuthRepository();
    moderationRepository = MockModerationRepository();
    profileRepository = MockProfileRepository();
    when(() => authRepository.authStateChanges()).thenAnswer(
      (_) => Stream.value(me),
    );
  });

  // Zweistufig async: `blockedUserIdsProvider` muss erst aufloesen, bevor
  // jede Zeile ihr eigenes `profileByIdProvider` ueberhaupt anfragt -- ein
  // einzelner kurzer Pump reicht dafuer nicht.
  Future<void> pumpBriefly(WidgetTester tester) async {
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));
    await tester.pump(const Duration(milliseconds: 50));
  }

  Future<GoRouter> pumpScreen(WidgetTester tester) async {
    final container = ProviderContainer(
      overrides: [
        authRepositoryProvider.overrideWithValue(authRepository),
        moderationRepositoryProvider.overrideWithValue(moderationRepository),
        profileRepositoryProvider.overrideWithValue(profileRepository),
        sharedPreferencesProvider.overrideWithValue(
          await fakeSharedPreferences(),
        ),
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
    router.go(AsmRoutes.blockedUsers);
    await pumpBriefly(tester);
    return router;
  }

  testWidgets('zeigt einen leeren Zustand ohne blockierte Nutzer', (
    tester,
  ) async {
    when(() => moderationRepository.blockedUserIds()).thenAnswer(
      (_) async => [],
    );

    await pumpScreen(tester);

    expect(find.text('Keine blockierten Nutzer'), findsOneWidget);
  });

  testWidgets('zeigt eine Zeile pro blockiertem Nutzer', (tester) async {
    when(() => moderationRepository.blockedUserIds()).thenAnswer(
      (_) async => ['u1'],
    );
    when(() => profileRepository.byId('u1')).thenAnswer(
      (_) async => blockedProfile,
    );

    await pumpScreen(tester);

    expect(find.text('blockiert123'), findsOneWidget);
    expect(find.text('Entsperren'), findsOneWidget);
  });

  testWidgets(
    'Tap auf Entsperren ruft unblockUser auf und entfernt die Zeile',
    (
      tester,
    ) async {
      when(() => moderationRepository.blockedUserIds()).thenAnswer(
        (_) async => ['u1'],
      );
      when(() => profileRepository.byId('u1')).thenAnswer(
        (_) async => blockedProfile,
      );
      when(() => moderationRepository.unblockUser('u1')).thenAnswer(
        (_) async {},
      );

      await pumpScreen(tester);
      expect(find.text('blockiert123'), findsOneWidget);

      when(() => moderationRepository.blockedUserIds()).thenAnswer(
        (_) async => [],
      );
      await tester.tap(find.text('Entsperren'));
      await pumpBriefly(tester);

      verify(() => moderationRepository.unblockUser('u1')).called(1);
      expect(find.text('blockiert123'), findsNothing);
    },
  );
}
