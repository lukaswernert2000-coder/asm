import 'package:asm/core/config/app_config.dart';
import 'package:asm/core/router/routes.dart';
import 'package:asm/core/theme/asm_colors.dart';
import 'package:asm/core/theme/asm_spacing.dart';
import 'package:asm/core/theme/asm_text_styles.dart';
import 'package:asm/core/utils/formatters.dart';
import 'package:asm/core/widgets/asm_error_view.dart';
import 'package:asm/core/widgets/asm_network_image.dart';
import 'package:asm/core/widgets/asm_skeleton.dart';
import 'package:asm/features/auth/presentation/auth_controller.dart';
import 'package:asm/features/notifications/presentation/push_notification_service.dart';
import 'package:asm/features/profile/domain/avatar_url.dart';
import 'package:asm/features/profile/domain/profile.dart';
import 'package:asm/features/profile/presentation/profile_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(currentProfileProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Profil')),
      body: profileAsync.when(
        loading: () => const Padding(
          padding: EdgeInsets.all(AsmSpacing.md),
          child: AsmSkeleton.detail(),
        ),
        error: (error, stackTrace) => AsmErrorView(
          message: 'Profil konnte nicht geladen werden',
          onRetry: () => ref.invalidate(currentProfileProvider),
        ),
        data: (profile) => profile == null
            ? const AsmErrorView(message: 'Nicht angemeldet', onRetry: _noop)
            : _ProfileContent(profile: profile),
      ),
    );
  }
}

void _noop() {}

class _ProfileContent extends ConsumerWidget {
  const _ProfileContent({required this.profile});

  final Profile profile;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final imageUrl = avatarUrl(
      supabaseUrl: AppConfig.supabaseUrl,
      path: profile.avatarPath,
    );

    return ListView(
      padding: const EdgeInsets.all(AsmSpacing.md),
      children: [
        Center(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(AsmRadius.full),
            child: SizedBox(
              width: 88,
              height: 88,
              child: AsmNetworkImage(path: imageUrl),
            ),
          ),
        ),
        const SizedBox(height: AsmSpacing.md),
        Text(
          profile.displayName ?? profile.username,
          style: AsmTextStyles.titleL,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: AsmSpacing.xxs),
        Text(
          'Mitglied seit ${Formatters.date(profile.createdAt)}',
          style: AsmTextStyles.bodyS.copyWith(color: AsmColors.textSecondary),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: AsmSpacing.xl),
        _MenuRow(
          icon: LucideIcons.pencil,
          label: 'Profil bearbeiten',
          onTap: () => context.push(AsmRoutes.editProfile),
        ),
        _MenuRow(
          icon: LucideIcons.tag,
          label: 'Meine Inserate',
          onTap: () => context.push(AsmRoutes.myListings),
        ),
        _MenuRow(
          icon: LucideIcons.heart,
          label: 'Favoriten',
          onTap: () => context.push(AsmRoutes.favorites),
        ),
        _MenuRow(
          icon: LucideIcons.settings,
          label: 'Einstellungen',
          onTap: () => context.push(AsmRoutes.settings),
        ),
        const SizedBox(height: AsmSpacing.xl),
        Text(
          'Rechtliches',
          style: AsmTextStyles.label.copyWith(color: AsmColors.textTertiary),
        ),
        const SizedBox(height: AsmSpacing.xs),
        const _LegalLink(
          label: 'Nutzungsbedingungen',
          page: 'nutzungsbedingungen',
        ),
        const _LegalLink(label: 'Datenschutzerklärung', page: 'datenschutz'),
        const _LegalLink(label: 'AGB', page: 'agb'),
        const _LegalLink(label: 'Impressum', page: 'impressum'),
        const SizedBox(height: AsmSpacing.xl),
        _MenuRow(
          icon: LucideIcons.logOut,
          label: 'Abmelden',
          color: AsmColors.dangerText,
          onTap: () async {
            // Geraetetoken VOR signOut() abmelden: Supabase leert die
            // Session, bevor es das signedOut-Event feuert, danach wuerde
            // die RLS-Policy von device_tokens das DELETE stumm verwerfen.
            await ref
                .read(pushNotificationServiceProvider)
                .unregisterCurrentToken();
            await ref.read(authRepositoryProvider).signOut();
          },
        ),
        _MenuRow(
          icon: LucideIcons.trash2,
          label: 'Account löschen',
          color: AsmColors.dangerText,
          onTap: () => context.push(AsmRoutes.deleteAccount),
        ),
      ],
    );
  }
}

class _MenuRow extends StatelessWidget {
  const _MenuRow({
    required this.icon,
    required this.label,
    required this.onTap,
    this.color,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final rowColor = color ?? AsmColors.textPrimary;
    return Semantics(
      button: true,
      label: label,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: AsmSpacing.sm),
          child: Row(
            children: [
              Icon(icon, size: 20, color: rowColor),
              const SizedBox(width: AsmSpacing.sm),
              Expanded(
                child: Text(
                  label,
                  style: AsmTextStyles.bodyL.copyWith(color: rowColor),
                ),
              ),
              const Icon(
                LucideIcons.chevronRight,
                size: 20,
                color: AsmColors.textTertiary,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LegalLink extends StatelessWidget {
  const _LegalLink({required this.label, required this.page});

  final String label;
  final String page;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => context.push(AsmRoutes.legal(page)),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: AsmSpacing.xs),
        child: Text(
          label,
          style: AsmTextStyles.bodyM.copyWith(color: AsmColors.brandBright),
        ),
      ),
    );
  }
}
