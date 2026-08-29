import 'package:asm/core/router/app_router.dart';
import 'package:asm/core/router/routes.dart';
import 'package:asm/core/storage/shared_preferences_provider.dart';
import 'package:asm/features/onboarding/presentation/onboarding_providers.dart';
import 'package:asm/features/onboarding/presentation/onboarding_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../helpers/fake_shared_preferences.dart';

void main() {
  testWidgets('zeigt die erste Seite mit Titel und Ueberspringen', (
    tester,
  ) async {
    final prefs = await fakeSharedPreferences(hasSeenOnboarding: false);
    final container = ProviderContainer(
      overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
    );
    addTearDown(container.dispose);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const MaterialApp(home: OnboardingScreen()),
      ),
    );

    expect(find.text('Gear finden, das wirklich passt.'), findsOneWidget);
    expect(find.text('Überspringen'), findsOneWidget);
    expect(find.text('Fertig'), findsNothing);
  });

  testWidgets('letzte Seite zeigt Fertig statt Ueberspringen', (
    tester,
  ) async {
    final prefs = await fakeSharedPreferences(hasSeenOnboarding: false);
    final container = ProviderContainer(
      overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
    );
    addTearDown(container.dispose);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const MaterialApp(home: OnboardingScreen()),
      ),
    );

    await tester.drag(find.byType(PageView), const Offset(-800, 0));
    await tester.pumpAndSettle();
    await tester.drag(find.byType(PageView), const Offset(-800, 0));
    await tester.pumpAndSettle();

    expect(find.text('Direkt verhandeln.'), findsOneWidget);
    expect(find.text('Fertig'), findsOneWidget);
    expect(find.text('Überspringen'), findsNothing);
  });

  testWidgets(
    'Ueberspringen setzt das Flag und navigiert zum Willkommen-Screen',
    (tester) async {
      final prefs = await fakeSharedPreferences(hasSeenOnboarding: false);
      final container = ProviderContainer(
        overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
      );
      addTearDown(container.dispose);
      final router = container.read(appRouterProvider);

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: MaterialApp.router(routerConfig: router),
        ),
      );
      router.go(AsmRoutes.onboarding);
      await tester.pumpAndSettle();

      await tester.tap(find.text('Überspringen'));
      await tester.pumpAndSettle();

      expect(prefs.getBool(hasSeenOnboardingPrefsKey), isTrue);
      expect(find.byType(OnboardingScreen), findsNothing);
      expect(find.text('Konto erstellen'), findsOneWidget);
    },
  );
}
