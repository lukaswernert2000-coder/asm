import 'package:asm/core/config/app_config.dart';
import 'package:asm/core/router/routes.dart';
import 'package:asm/core/theme/asm_colors.dart';
import 'package:asm/core/theme/asm_spacing.dart';
import 'package:asm/core/theme/asm_text_styles.dart';
import 'package:asm/core/utils/formatters.dart';
import 'package:asm/core/widgets/asm_button.dart';
import 'package:asm/core/widgets/asm_error_view.dart';
import 'package:asm/core/widgets/asm_network_image.dart';
import 'package:asm/core/widgets/asm_skeleton.dart';
import 'package:asm/features/listings/presentation/listing_providers.dart';
import 'package:asm/features/moderation/presentation/widgets/report_dialog.dart';
import 'package:asm/features/profile/domain/avatar_url.dart';
import 'package:asm/features/profile/domain/profile.dart';
import 'package:asm/features/profile/presentation/profile_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shimmer/shimmer.dart';

class PublicProfileScreen extends ConsumerWidget {
  const PublicProfileScreen({required this.userId, super.key});

  final String userId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(profileByIdProvider(userId));

    return Scaffold(
      appBar: AppBar(title: const Text('Profil')),
      body: profileAsync.when(
        loading: () => const Padding(
          padding: EdgeInsets.all(AsmSpacing.md),
          child: AsmSkeleton.detail(),
        ),
        error: (error, stackTrace) => AsmErrorView(
          message: 'Profil konnte nicht geladen werden',
          onRetry: () => ref.invalidate(profileByIdProvider(userId)),
        ),
        data: (profile) => _PublicProfileContent(profile: profile),
      ),
    );
  }
}

class _PublicProfileContent extends ConsumerWidget {
  const _PublicProfileContent({required this.profile});

  final Profile profile;

  Future<void> _report(BuildContext context, WidgetRef ref) =>
      showReportUserFlow(
        context,
        ref,
        userId: profile.id,
        username: profile.username,
        loginRedirectPath: AsmRoutes.publicProfile(profile.id),
      );

  Future<void> _block(BuildContext context, WidgetRef ref) => showBlockUserFlow(
    context,
    ref,
    userId: profile.id,
    username: profile.username,
    loginRedirectPath: AsmRoutes.publicProfile(profile.id),
  );

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
        if (profile.isCommercial) ...[
          const SizedBox(height: AsmSpacing.xs),
          Text(
            profile.commercialName ?? 'Gewerblicher Verkäufer',
            style: AsmTextStyles.bodyS.copyWith(color: AsmColors.warning),
            textAlign: TextAlign.center,
          ),
        ],
        const SizedBox(height: AsmSpacing.xl),
        // Nebeneinander in einer Row reicht die Breite fuer "Blockieren"
        // bei AsmButtons fixem Innenabstand (AsmSpacing.lg) auf schmalen
        // Geraeten nicht (RenderFlex-Overflow) -- deshalb untereinander.
        Column(
          children: [
            AsmButton(
              label: 'Melden',
              variant: AsmButtonVariant.secondary,
              onPressed: () => _report(context, ref),
            ),
            const SizedBox(height: AsmSpacing.sm),
            AsmButton(
              label: 'Blockieren',
              variant: AsmButtonVariant.danger,
              onPressed: () => _block(context, ref),
            ),
          ],
        ),
        const SizedBox(height: AsmSpacing.xl),
        Consumer(
          builder: (context, ref, _) {
            final listingsAsync = ref.watch(
              activeListingsBySellerProvider(profile.id),
            );
            return listingsAsync.when(
              // Kein AsmSkeleton.listingGrid(): das ist intern ein GridView
              // und wuerde als direktes Kind dieser aeusseren ListView zwei
              // Scrollables verschachteln. Fuer eine reine "X aktive
              // Inserate"-Zeile reicht ein Platzhalter in Textzeilen-Groesse.
              loading: () => const _TextLineSkeleton(),
              error: (error, stackTrace) => const SizedBox.shrink(),
              data: (listings) => listings.isEmpty
                  ? const SizedBox.shrink()
                  : Text(
                      '${listings.length} aktive Inserate',
                      style: AsmTextStyles.titleS,
                    ),
            );
          },
        ),
      ],
    );
  }
}

class _TextLineSkeleton extends StatelessWidget {
  const _TextLineSkeleton();

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: AsmColors.shimmerBase,
      highlightColor: AsmColors.shimmerHi,
      period: const Duration(milliseconds: 1200),
      child: Container(
        width: 140,
        height: 18,
        decoration: BoxDecoration(
          color: AsmColors.shimmerBase,
          borderRadius: BorderRadius.circular(AsmRadius.sm),
        ),
      ),
    );
  }
}
