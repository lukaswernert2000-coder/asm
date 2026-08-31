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
import 'package:asm/features/categories/presentation/category_overview_screen.dart';
import 'package:asm/features/categories/presentation/category_screen.dart';
import 'package:asm/features/favorites/presentation/favorites_screen.dart';
import 'package:asm/features/listings/presentation/create_listing_screen.dart';
import 'package:asm/features/listings/presentation/edit_listing_screen.dart';
import 'package:asm/features/listings/presentation/listing_detail_screen.dart';
import 'package:asm/features/listings/presentation/my_listings_screen.dart';
import 'package:asm/features/onboarding/presentation/onboarding_providers.dart';
import 'package:asm/features/onboarding/presentation/onboarding_screen.dart';
import 'package:asm/features/onboarding/presentation/welcome_screen.dart';
import 'package:asm/features/profile/presentation/delete_account_screen.dart';
import 'package:asm/features/profile/presentation/edit_profile_screen.dart';
import 'package:asm/features/profile/presentation/profile_screen.dart';
import 'package:asm/features/profile/presentation/public_profile_screen.dart';
import 'package:asm/features/search/presentation/search_screen.dart';
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
      hasSeenOnboarding: ref.read(hasSeenOnboardingProvider),
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
                builder: (context, state) => const CategoryOverviewScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AsmRoutes.search,
                builder: (context, state) => const SearchScreen(),
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
                builder: (context, state) => const ProfileScreen(),
              ),
            ],
          ),
        ],
      ),
      GoRoute(
        path: AsmRoutes.create,
        builder: (context, state) => const CreateListingScreen(),
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
      GoRoute(
        path: AsmRoutes.editProfile,
        builder: (context, state) => const EditProfileScreen(),
      ),
      GoRoute(
        path: AsmRoutes.deleteAccount,
        builder: (context, state) => const DeleteAccountScreen(),
      ),
      GoRoute(
        path: AsmRoutes.myListings,
        builder: (context, state) => const MyListingsScreen(),
      ),
      GoRoute(
        path: '/user/:id',
        builder: (context, state) =>
            PublicProfileScreen(userId: state.pathParameters['id']!),
      ),
      GoRoute(
        path: '/category/:slug',
        builder: (context, state) =>
            CategoryScreen(slug: state.pathParameters['slug']!),
      ),
      GoRoute(
        path: '/listing/:id',
        builder: (context, state) =>
            ListingDetailScreen(listingId: state.pathParameters['id']!),
      ),
      GoRoute(
        path: '/listing/:id/edit',
        builder: (context, state) =>
            EditListingScreen(listingId: state.pathParameters['id']!),
      ),
      GoRoute(
        path: AsmRoutes.favorites,
        builder: (context, state) => const FavoritesScreen(),
      ),
      GoRoute(
        path: AsmRoutes.settings,
        builder: (context, state) => const _TitledPlaceholder(
          icon: LucideIcons.settings,
          title: 'Einstellungen',
        ),
      ),
      GoRoute(
        path: AsmRoutes.onboarding,
        builder: (context, state) => const OnboardingScreen(),
      ),
      GoRoute(
        path: AsmRoutes.welcome,
        builder: (context, state) => const WelcomeScreen(),
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

/// Fuer Routen, die per `push` (mit Zurueck-Pfeil) statt als Branch erreicht
/// werden -- anders als [_BranchPlaceholder] mit eigener `AppBar`.
class _TitledPlaceholder extends StatelessWidget {
  const _TitledPlaceholder({required this.icon, required this.title});

  final IconData icon;
  final String title;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: AsmEmptyState(icon: icon, title: title),
    );
  }
}
