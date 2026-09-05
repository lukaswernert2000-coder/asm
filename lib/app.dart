import 'dart:async';

import 'package:asm/core/router/app_router.dart';
import 'package:asm/core/router/routes.dart';
import 'package:asm/core/theme/asm_theme.dart';
import 'package:asm/features/auth/presentation/auth_controller.dart';
import 'package:asm/features/categories/presentation/category_providers.dart';
import 'package:asm/features/notifications/presentation/push_notification_service.dart';
import 'package:asm/features/onboarding/presentation/splash_screen.dart';
import 'package:asm/l10n/generated/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart' show AuthChangeEvent;

class AsmApp extends ConsumerStatefulWidget {
  const AsmApp({super.key});

  @override
  ConsumerState<AsmApp> createState() => _AsmAppState();
}

class _AsmAppState extends ConsumerState<AsmApp> {
  bool _splashTimedOut = false;
  late final Timer _splashTimer;

  @override
  void initState() {
    super.initState();
    // Sicherheitsnetz aus Task 2.7: Splash haelt normalerweise nur so lange,
    // bis Session und Kategorien geladen sind, aber nie laenger als das hier.
    _splashTimer = Timer(const Duration(seconds: 3), () {
      if (mounted) setState(() => _splashTimedOut = true);
    });
    // Vordergrund-Handler, Tap-Navigation, Token-Refresh -- einmalig beim
    // Start, unabhaengig vom Login-Status (Task 6.3).
    unawaited(ref.read(pushNotificationServiceProvider).initialize());
  }

  @override
  void dispose() {
    _splashTimer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final router = ref.watch(appRouterProvider);

    // Deckt sowohl den asm://auth-callback-Deep-Link als auch einen normalen
    // Login auf dem Login-Screen ab -- beide feuern GoTrueClient.signedIn.
    // passwordRecovery kommt nur vom asm://reset-password-Deep-Link.
    ref.listen(authEventProvider, (previous, next) {
      switch (next.valueOrNull) {
        case AuthChangeEvent.passwordRecovery:
          router.go(AsmRoutes.resetPassword);
        case AuthChangeEvent.signedIn:
          // Falls ein Auth-Guard (guards.dart) vorher zu /login?from=<ziel>
          // umgeleitet hat, dorthin zurueck -- sonst wie bisher zum Start.
          final from =
              router.routeInformationProvider.value.uri.queryParameters['from'];
          router.go(from ?? AsmRoutes.home);
          // Token erneut registrieren, falls die Berechtigung schon in einer
          // frueheren Session erteilt wurde -- ohne erneut zu fragen
          // (Task 6.3). Das eigentliche Abmelden des Tokens laeuft nicht
          // reaktiv auf signedOut, sondern in profile_screen.dart VOR dem
          // signOut()-Aufruf, siehe dortiger Kommentar.
          unawaited(ref.read(pushNotificationServiceProvider).onSignedIn());
        case AuthChangeEvent.initialSession:
        case AuthChangeEvent.signedOut:
        case AuthChangeEvent.tokenRefreshed:
        case AuthChangeEvent.userUpdated:
        case AuthChangeEvent.mfaChallengeVerified:
        // Deprecated event, aber Teil des Enums -- fuer einen exhaustiven
        // Switch ohne `default` (no_default_cases) trotzdem aufgefuehrt.
        // ignore: deprecated_member_use
        case AuthChangeEvent.userDeleted:
        case null:
          break;
      }
    });

    final sessionSettled = !ref.watch(authStateProvider).isLoading;
    final categoriesSettled = !ref.watch(rootCategoriesProvider).isLoading;
    final ready = _splashTimedOut || (sessionSettled && categoriesSettled);

    if (!ready) {
      return const MaterialApp(
        debugShowCheckedModeBanner: false,
        home: SplashScreen(),
      );
    }

    return MaterialApp.router(
      title: 'ASM',
      debugShowCheckedModeBanner: false,
      theme: AsmTheme.dark,
      darkTheme: AsmTheme.dark,
      themeMode: ThemeMode.dark,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: const [Locale('de')],
      locale: const Locale('de'),
      routerConfig: router,
    );
  }
}
