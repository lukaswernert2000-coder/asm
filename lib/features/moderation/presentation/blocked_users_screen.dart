import 'package:asm/core/config/app_config.dart';
import 'package:asm/core/errors/app_exception.dart';
import 'package:asm/core/theme/asm_spacing.dart';
import 'package:asm/core/theme/asm_text_styles.dart';
import 'package:asm/core/widgets/asm_empty_state.dart';
import 'package:asm/core/widgets/asm_error_view.dart';
import 'package:asm/core/widgets/asm_network_image.dart';
import 'package:asm/features/moderation/presentation/moderation_providers.dart';
import 'package:asm/features/profile/domain/avatar_url.dart';
import 'package:asm/features/profile/presentation/profile_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

/// Liste blockierter Nutzer, entsperrbar (Task 7.1), erreichbar aus den
/// Einstellungen. Gleiches Grundmuster wie FavoritesScreen (Task 5.2):
/// ID-Liste vom Repository, pro Zeile per `profileByIdProvider` aufgeloest.
class BlockedUsersScreen extends ConsumerWidget {
  const BlockedUsersScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final idsAsync = ref.watch(blockedUserIdsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Blockierte Nutzer')),
      body: idsAsync.when(
        loading: () => const SizedBox.shrink(),
        error: (error, stackTrace) => AsmErrorView(
          message: 'Liste konnte nicht geladen werden',
          onRetry: () => ref.invalidate(blockedUserIdsProvider),
        ),
        data: (ids) => ids.isEmpty
            ? const AsmEmptyState(
                icon: LucideIcons.userX,
                title: 'Keine blockierten Nutzer',
                message:
                    'Blockierte Nutzer erscheinen hier und lassen '
                    'sich wieder entsperren.',
              )
            : ListView.separated(
                padding: const EdgeInsets.all(AsmSpacing.md),
                itemCount: ids.length,
                separatorBuilder: (context, index) =>
                    const SizedBox(height: AsmSpacing.sm),
                itemBuilder: (context, index) =>
                    _BlockedUserRow(userId: ids[index]),
              ),
      ),
    );
  }
}

class _BlockedUserRow extends ConsumerWidget {
  const _BlockedUserRow({required this.userId});

  final String userId;

  Future<void> _unblock(BuildContext context, WidgetRef ref) async {
    try {
      await ref.read(moderationRepositoryProvider).unblockUser(userId);
      // Auch das Chat-Eingabefeld dieses Nutzers soll sofort wieder
      // freigeschaltet sein, ohne dass die Chat-Detailseite dafuer neu
      // geoeffnet werden muss.
      ref
        ..invalidate(blockedUserIdsProvider)
        ..invalidate(isBlockedByMeProvider(userId));
    } on AppException {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Entsperren fehlgeschlagen.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(profileByIdProvider(userId));

    return profileAsync.when(
      loading: () => const SizedBox.shrink(),
      error: (error, stackTrace) => const SizedBox.shrink(),
      data: (profile) {
        final imageUrl = avatarUrl(
          supabaseUrl: AppConfig.supabaseUrl,
          path: profile.avatarPath,
        );
        return Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(AsmRadius.full),
              child: SizedBox(
                width: 44,
                height: 44,
                child: AsmNetworkImage(path: imageUrl),
              ),
            ),
            const SizedBox(width: AsmSpacing.sm),
            Expanded(
              child: Text(
                profile.displayName ?? profile.username,
                style: AsmTextStyles.titleS,
              ),
            ),
            TextButton(
              onPressed: () => _unblock(context, ref),
              child: const Text('Entsperren'),
            ),
          ],
        );
      },
    );
  }
}
