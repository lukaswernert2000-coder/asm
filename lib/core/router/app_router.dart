import 'package:asm/core/router/routes.dart';
import 'package:asm/core/widgets/_gallery_screen.dart';
import 'package:asm/core/widgets/asm_empty_state.dart';
import 'package:asm/core/widgets/asm_shell.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

/// Klassischer (nicht generierter) Provider — `build_runner` ist derzeit
/// kaputt, siehe DECISIONS.md ("build_runner durch analyzer_plugin
/// blockiert"). Sobald das behoben ist, kann das auf `@riverpod` umgestellt
/// werden.
final appRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: kDebugMode ? _galleryPath : AsmRoutes.home,
    routes: [
      if (kDebugMode)
        GoRoute(
          path: _galleryPath,
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
    ],
  );
});

const _galleryPath = '/_gallery';

class _BranchPlaceholder extends StatelessWidget {
  const _BranchPlaceholder({required this.icon, required this.title});

  final IconData icon;
  final String title;

  @override
  Widget build(BuildContext context) {
    return Scaffold(body: AsmEmptyState(icon: icon, title: title));
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
