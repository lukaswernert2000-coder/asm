import 'package:asm/core/router/app_router.dart';
import 'package:asm/core/router/routes.dart';
import 'package:asm/core/storage/shared_preferences_provider.dart';
import 'package:asm/features/auth/data/auth_repository.dart';
import 'package:asm/features/auth/domain/asm_user.dart';
import 'package:asm/features/auth/presentation/auth_controller.dart';
import 'package:asm/features/moderation/data/moderation_repository.dart';
import 'package:asm/features/moderation/presentation/blocked_users_screen.dart';
import 'package:asm/features/moderation/presentation/moderation_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mocktail/mocktail.dart';

import '../../../helpers/fake_shared_preferences.dart';

class MockAuthRepository extends Mock implements AuthRepository {}

class MockModerationRepository extends Mock implements ModerationRepository {}

void main() {
  late MockAuthRepository authRepository;
  late MockModerationRepository moderationRepository;

  const me = AsmUser(id: 'me', email: 'a@b.de', emailConfirmed: true);

  setUp(() {
    authRepository = MockAuthRepository();
    moderationRepository = MockModerationRepository();
    when(() => authRepository.authStateChanges()).thenAnswer(
      (_) => Stream.value(me),
    );
    when(() => moderationRepository.blockedUserIds()).thenAnswer(
      (_) async => [],
    );
  });

  Future<void> pumpBriefly(WidgetTester tester) async {
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));
  }

  Future<GoRouter> pumpScreen(WidgetTester tester) async {
    final container = ProviderContainer(
      overrides: [
        authRepositoryProvider.overrideWithValue(authRepository),
        moderationRepositoryProvider.overrideWithValue(moderationRepository),
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
    router.go(AsmRoutes.settings);
    await pumpBriefly(tester);
    return router;
  }

  testWidgets('zeigt die Zeile "Blockierte Nutzer"', (tester) async {
    await pumpScreen(tester);

    expect(find.text('Blockierte Nutzer'), findsOneWidget);
  });

  testWidgets('Tap auf "Blockierte Nutzer" navigiert zum Blockiert-Screen', (
    tester,
  ) async {
    await pumpScreen(tester);

    await tester.tap(find.text('Blockierte Nutzer'));
    await pumpBriefly(tester);

    expect(find.byType(BlockedUsersScreen), findsOneWidget);
  });
}
