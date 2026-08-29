import 'package:asm/core/router/app_router.dart';
import 'package:asm/core/router/routes.dart';
import 'package:asm/core/theme/asm_theme.dart';
import 'package:asm/features/auth/presentation/auth_controller.dart';
import 'package:asm/l10n/generated/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart' show AuthChangeEvent;

class AsmApp extends ConsumerWidget {
  const AsmApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
