import 'package:asm/core/router/guards.dart' as guards;
import 'package:asm/core/router/routes.dart';
import 'package:asm/core/widgets/_gallery_screen.dart';
import 'package:asm/core/widgets/asm_empty_state.dart';
import 'package:asm/core/widgets/asm_shell.dart';
import 'package:asm/features/auth/presentation/auth_controller.dart';
import 'package:asm/features/auth/presentation/confirm_email_required_screen.dart';
import 'package:asm/features/auth/presentation/forgot_password_screen.dart';
import 'package:asm/features/auth/presentation/login_screen.dart';
import 'package:asm/features/auth/presentation/register_screen.dart';
import 'package:asm/features/auth/presentation/reset_password_screen.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

/// Klassischer (nicht generierter) Provider — `riverpod_generator` wurde in
/// Task 1.9 bewusst aus den Dependencies entfernt (siehe DECISIONS.md),
/// `build_runner` selbst laeuft seitdem wieder normal fuer freezed. Alle
/// Provider in dieser App bleiben deshalb absichtlich handgeschrieben.
final appRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: AsmRoutes.home,
    redirect: (context, state) => guards.redirect(
      location: state.uri.toString(),
      isLoggedIn: ref.read(isLoggedInProvider),
      emailConfirmed: ref.read(currentUserProvider)?.emailConfirmed ?? false,
    ),
    routes: [
      if (kDebugMode)
        GoRoute(
          path: AsmRoutes.debugGallery,
          builder: (context, state) => const GalleryScreen(),
        ),
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) =>
            AsmShell(navigationShell: navigationShell),
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AsmRoutes.home,
                builder: (context, state) => const _BranchPlaceholder(
                  icon: LucideIcons.house,
                  title: 'Start',
                ),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AsmRoutes.search,
                builder: (context, state) => const _BranchPlaceholder(
                  icon: LucideIcons.search,
                  title: 'Suchen',
                ),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AsmRoutes.chats,
                builder: (context, state) => const _BranchPlaceholder(
                  icon: LucideIcons.messageSquare,
                  title: 'Chats',
                ),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AsmRoutes.profile,
                builder: (context, state) => const _BranchPlaceholder(
                  icon: LucideIcons.user,
                  title: 'Profil',
                ),
              ),
            ],
          ),
        ],
      ),
      GoRoute(
        path: AsmRoutes.create,
        builder: (context, state) => const _CreatePlaceholder(),
      ),
      GoRoute(
        path: AsmRoutes.register,
        builder: (context, state) => const RegisterScreen(),
      ),
      GoRoute(
        path: AsmRoutes.login,
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: AsmRoutes.forgotPassword,
        builder: (context, state) => const ForgotPasswordScreen(),
      ),
      GoRoute(
        path: AsmRoutes.resetPassword,
        builder: (context, state) => const ResetPasswordScreen(),
      ),
      GoRoute(
        path: AsmRoutes.confirmEmail,
        builder: (context, state) => const ConfirmEmailRequiredScreen(),
      ),
    ],
  );
});

class _BranchPlaceholder extends StatelessWidget {
  const _BranchPlaceholder({required this.icon, required this.title});

  final IconData icon;
  final String title;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AsmEmptyState(icon: icon, title: title),
    );
  }
}

class _CreatePlaceholder extends StatelessWidget {
  const _CreatePlaceholder();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: const AsmEmptyState(
        icon: LucideIcons.plus,
        title: 'Inserat erstellen',
      ),
    );
  }
}
