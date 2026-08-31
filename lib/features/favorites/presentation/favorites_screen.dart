import 'package:asm/core/config/app_config.dart';
import 'package:asm/core/errors/app_exception.dart';
import 'package:asm/core/router/routes.dart';
import 'package:asm/core/theme/asm_colors.dart';
import 'package:asm/core/theme/asm_spacing.dart';
import 'package:asm/core/theme/asm_text_styles.dart';
import 'package:asm/core/utils/formatters.dart';
import 'package:asm/core/widgets/asm_empty_state.dart';
import 'package:asm/core/widgets/asm_error_view.dart';
import 'package:asm/core/widgets/asm_network_image.dart';
import 'package:asm/core/widgets/asm_skeleton.dart';
import 'package:asm/features/favorites/presentation/favorite_providers.dart';
import 'package:asm/features/listings/domain/listing.dart';
import 'package:asm/features/listings/domain/listing_image_url.dart';
import 'package:asm/features/listings/presentation/listing_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:shimmer/shimmer.dart';

/// Favoriten-Screen (Task 5.2): Liste der eigenen Favoriten, Wischen zum
/// Entfernen, "Verkauft"-Badge bei verkauften Favoriten.
class FavoritesScreen extends ConsumerWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final idsAsync = ref.watch(favoriteListingIdsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Favoriten')),
      body: idsAsync.when(
        loading: () => const Padding(
          padding: EdgeInsets.all(AsmSpacing.md),
          child: AsmSkeleton.listingList(),
        ),
        error: (error, stackTrace) => AsmErrorView(
          message: 'Favoriten konnten nicht geladen werden',
          onRetry: () => ref.invalidate(favoriteListingIdsProvider),
        ),
        data: (ids) => ids.isEmpty
            ? const AsmEmptyState(
                icon: LucideIcons.heart,
                title: 'Noch keine Favoriten',
                message:
                    'Tippe auf das Herz bei einem Inserat, um es hier zu '
                    'sammeln.',
              )
            : ListView.separated(
                padding: const EdgeInsets.all(AsmSpacing.md),
                itemCount: ids.length,
                separatorBuilder: (context, index) =>
                    const SizedBox(height: AsmSpacing.sm),
                itemBuilder: (context, index) =>
                    _FavoriteRow(listingId: ids[index]),
              ),
      ),
    );
  }
}

class _FavoriteRow extends ConsumerWidget {
  const _FavoriteRow({required this.listingId});

  final String listingId;

  Future<bool> _confirmRemove(BuildContext context, WidgetRef ref) async {
    try {
      await ref.read(favoriteRepositoryProvider).remove(listingId);
      ref
        ..invalidate(favoriteListingIdsProvider)
        ..invalidate(favoriteProvider(listingId));
      return true;
    } on AppException {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Entfernen fehlgeschlagen.')),
        );
      }
      return false;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final listingAsync = ref.watch(listingByIdProvider(listingId));

    return listingAsync.when(
      // Kein AsmSkeleton.card(): das ist fuer eine Grid-Karte (4:3-Bild +
      // Textzeilen) gebaut und liefe in dieser 96px hohen Zeile ueber.
      loading: () => Shimmer.fromColors(
        baseColor: AsmColors.shimmerBase,
        highlightColor: AsmColors.shimmerHi,
        period: const Duration(milliseconds: 1200),
        child: Container(
          height: 96,
          decoration: BoxDecoration(
            color: AsmColors.shimmerBase,
            borderRadius: BorderRadius.circular(AsmRadius.md),
          ),
        ),
      ),
      error: (error, stackTrace) => const SizedBox.shrink(),
      data: (listing) => Dismissible(
        key: Key('favoriteRow_$listingId'),
        direction: DismissDirection.endToStart,
        confirmDismiss: (direction) => _confirmRemove(context, ref),
        background: Container(
          alignment: Alignment.centerRight,
          padding: const EdgeInsets.symmetric(horizontal: AsmSpacing.md),
          decoration: BoxDecoration(
            color: AsmColors.danger,
            borderRadius: BorderRadius.circular(AsmRadius.md),
          ),
          child: const Icon(LucideIcons.trash2, color: AsmColors.onBrand),
        ),
        child: GestureDetector(
          onTap: () => context.push(AsmRoutes.listing(listing.id)),
          child: _FavoriteRowContent(listing: listing),
        ),
      ),
    );
  }
}

class _FavoriteRowContent extends ConsumerWidget {
  const _FavoriteRowContent({required this.listing});

  final Listing listing;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final imagePathsAsync = ref.watch(listingImagePathsProvider(listing.id));
    final coverPath = imagePathsAsync.valueOrNull?.firstOrNull;
    final imageUrl = listingImageUrl(
      supabaseUrl: AppConfig.supabaseUrl,
      path: coverPath,
    );

    return SizedBox(
      height: 96,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(AsmRadius.md),
            child: SizedBox(
              width: 96,
              height: 96,
              child: AsmNetworkImage(path: imageUrl),
            ),
          ),
          const SizedBox(width: AsmSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  listing.title,
                  style: AsmTextStyles.titleS,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: AsmSpacing.xxs),
                Text(
                  Formatters.price(listing.priceCents),
                  style: AsmTextStyles.priceS,
                ),
                if (listing.status == ListingStatus.sold) ...[
                  const SizedBox(height: AsmSpacing.xxs),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AsmSpacing.xs,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: AsmColors.danger,
                      borderRadius: BorderRadius.circular(AsmRadius.sm),
                    ),
                    child: Text(
                      'Verkauft',
                      style: AsmTextStyles.label.copyWith(
                        color: AsmColors.onBrand,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
