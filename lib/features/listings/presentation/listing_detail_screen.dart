import 'dart:async';

import 'package:asm/core/config/app_config.dart';
import 'package:asm/core/router/guards.dart';
import 'package:asm/core/router/routes.dart';
import 'package:asm/core/theme/asm_colors.dart';
import 'package:asm/core/theme/asm_spacing.dart';
import 'package:asm/core/theme/asm_text_styles.dart';
import 'package:asm/core/widgets/asm_error_view.dart';
import 'package:asm/core/widgets/asm_skeleton.dart';
import 'package:asm/features/auth/presentation/auth_controller.dart';
import 'package:asm/features/categories/presentation/category_providers.dart';
import 'package:asm/features/favorites/presentation/favorite_providers.dart';
import 'package:asm/features/listings/domain/listing.dart';
import 'package:asm/features/listings/domain/listing_image_url.dart';
import 'package:asm/features/listings/presentation/listing_providers.dart';
import 'package:asm/features/listings/presentation/viewed_listings_provider.dart';
import 'package:asm/features/listings/presentation/widgets/listing_detail/expandable_description.dart';
import 'package:asm/features/listings/presentation/widgets/listing_detail/listing_attribute_table.dart';
import 'package:asm/features/listings/presentation/widgets/listing_detail/listing_bottom_bar.dart';
import 'package:asm/features/listings/presentation/widgets/listing_detail/listing_fullscreen_gallery.dart';
import 'package:asm/features/listings/presentation/widgets/listing_detail/listing_gallery.dart';
import 'package:asm/features/listings/presentation/widgets/listing_detail/listing_legal_warning_box.dart';
import 'package:asm/features/listings/presentation/widgets/listing_detail/listing_price_header.dart';
import 'package:asm/features/listings/presentation/widgets/listing_detail/seller_card.dart';
import 'package:asm/features/moderation/presentation/widgets/report_dialog.dart';
import 'package:asm/features/profile/presentation/profile_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:share_plus/share_plus.dart';

/// Detailseite eines Inserats (Task 5.1). Ersetzt den `_TitledPlaceholder`
/// unter `/listing/:id` aus Task 3.1.
class ListingDetailScreen extends ConsumerWidget {
  const ListingDetailScreen({required this.listingId, super.key});

  final String listingId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final listingAsync = ref.watch(listingByIdProvider(listingId));

    return listingAsync.when(
      loading: () => Scaffold(
        appBar: AppBar(title: const Text('Inserat')),
        body: const Padding(
          padding: EdgeInsets.all(AsmSpacing.md),
          child: AsmSkeleton.detail(),
        ),
      ),
      error: (error, stackTrace) => Scaffold(
        appBar: AppBar(title: const Text('Inserat')),
        body: AsmErrorView(
          message: 'Inserat konnte nicht geladen werden',
          onRetry: () => ref.invalidate(listingByIdProvider(listingId)),
        ),
      ),
      data: (listing) => _ListingDetailScaffold(listing: listing),
    );
  }
}

class _ListingDetailScaffold extends ConsumerStatefulWidget {
  const _ListingDetailScaffold({required this.listing});

  final Listing listing;

  @override
  ConsumerState<_ListingDetailScaffold> createState() =>
      _ListingDetailScaffoldState();
}

class _ListingDetailScaffoldState
    extends ConsumerState<_ListingDetailScaffold> {
  @override
  void initState() {
    super.initState();
    // markViewed() mutiert einen Provider -- waehrend des ersten Builds
    // (initState laeuft darin) verbietet Riverpod das direkt, siehe
    // https://riverpod.dev "Tried to modify a provider while the widget
    // tree was building". Deshalb auf den Mikrotask nach dem Build verschoben.
    unawaited(
      Future.microtask(() {
        if (!mounted) return;
        final isNewView = ref
            .read(viewedListingsProvider.notifier)
            .markViewed(widget.listing.id);
        if (isNewView) {
          unawaited(
            ref
                .read(listingRepositoryProvider)
                .incrementView(widget.listing.id),
          );
        }
      }),
    );
  }

  Future<void> _onPrimaryPressed(Listing listing, bool isOwnListing) async {
    if (isOwnListing) {
      unawaited(context.push(AsmRoutes.editListing(listing.id)));
      return;
    }
    if (!ref.read(isLoggedInProvider)) {
      context.go('${AsmRoutes.login}?from=${AsmRoutes.listing(listing.id)}');
      return;
    }
    final category = await ref.read(
      categoryByIdProvider(listing.categoryId).future,
    );
    final isAdult = await ref.read(isAdultProvider.future);
    if (!mounted) return;
    if (blocksForAge(
      requiresAge18: category?.requiresAge18 ?? false,
      isAdult: isAdult,
    )) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Diese Kategorie ist erst ab 18 Jahren freigegeben.'),
        ),
      );
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Chat kommt mit einem späteren Update.')),
    );
  }

  Future<void> _onFavoriteToggle(Listing listing) async {
    if (!ref.read(isLoggedInProvider)) {
      context.go('${AsmRoutes.login}?from=${AsmRoutes.listing(listing.id)}');
      return;
    }
    await ref.read(favoriteProvider(listing.id).notifier).toggle();
  }

  void _openGallery(List<String> imageUrls, int index) {
    Navigator.of(context).push<void>(
      MaterialPageRoute<void>(
        builder: (_) => ListingFullscreenGallery(
          imageUrls: imageUrls,
          initialIndex: index,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final listing = widget.listing;
    final currentUserId = ref.watch(currentUserProvider)?.id;
    final isOwnListing = currentUserId == listing.sellerId;
    final imagePathsAsync = ref.watch(listingImagePathsProvider(listing.id));
    final imageUrls = (imagePathsAsync.valueOrNull ?? const <String>[])
        .map(
          (path) => listingImageUrl(
            supabaseUrl: AppConfig.supabaseUrl,
            path: path,
          )!,
        )
        .toList();
    final sellerAsync = ref.watch(profileByIdProvider(listing.sellerId));
    final activeListingsAsync = ref.watch(
      activeListingsBySellerProvider(listing.sellerId),
    );
    final isFavoritedAsync = ref.watch(favoriteProvider(listing.id));
    final isFavorited = isFavoritedAsync.valueOrNull ?? false;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Inserat'),
        actions: [
          if (!isOwnListing)
            PopupMenuButton<VoidCallback>(
              icon: const Icon(LucideIcons.moreVertical),
              onSelected: (action) => action(),
              itemBuilder: (context) => [
                PopupMenuItem(
                  value: () => showReportUserFlow(
                    context,
                    ref,
                    userId: listing.sellerId,
                    username: sellerAsync.valueOrNull?.username ?? '',
                    loginRedirectPath: AsmRoutes.listing(listing.id),
                  ),
                  child: const Text('Melden'),
                ),
                PopupMenuItem(
                  value: () => showBlockUserFlow(
                    context,
                    ref,
                    userId: listing.sellerId,
                    username: sellerAsync.valueOrNull?.username ?? '',
                    loginRedirectPath: AsmRoutes.listing(listing.id),
                  ),
                  child: const Text('Verkäufer blockieren'),
                ),
              ],
            ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(AsmSpacing.md),
        children: [
          Hero(
            tag: 'listing-image-${listing.id}',
            child: ClipRRect(
              borderRadius: BorderRadius.circular(AsmRadius.lg),
              child: ListingGallery(
                imageUrls: imageUrls,
                onImageTap: (index) => _openGallery(imageUrls, index),
              ),
            ),
          ),
          const SizedBox(height: AsmSpacing.md),
          Text(listing.title, style: AsmTextStyles.titleL),
          const SizedBox(height: AsmSpacing.xs),
          ListingPriceHeader(listing: listing),
          const SizedBox(height: AsmSpacing.lg),
          ListingAttributeTable(listing: listing),
          ListingLegalWarningBox(joule: listing.joule),
          const SizedBox(height: AsmSpacing.lg),
          const Text('Beschreibung', style: AsmTextStyles.titleS),
          const SizedBox(height: AsmSpacing.xs),
          ExpandableDescription(text: listing.description),
          const SizedBox(height: AsmSpacing.lg),
          sellerAsync.maybeWhen(
            data: (seller) => SellerCard(
              seller: seller,
              activeListingsCount: activeListingsAsync.valueOrNull?.length ?? 0,
              onTap: () => context.push(AsmRoutes.publicProfile(seller.id)),
            ),
            orElse: SizedBox.shrink,
          ),
          const SizedBox(height: AsmSpacing.lg),
          _LocationSection(listing: listing),
          const SizedBox(height: AsmSpacing.huge),
        ],
      ),
      bottomNavigationBar: ListingBottomBar(
        primaryLabel: isOwnListing ? 'Bearbeiten' : 'Nachricht schreiben',
        onPrimaryPressed: () => _onPrimaryPressed(listing, isOwnListing),
        isFavorited: isFavorited,
        onFavoriteToggle: () => _onFavoriteToggle(listing),
        onShare: () => SharePlus.instance.share(
          ShareParams(
            text:
                'Schau dir dieses Inserat auf ASM an: '
                'https://asm-app.de/listing/${listing.id}',
          ),
        ),
      ),
    );
  }
}

class _LocationSection extends StatelessWidget {
  const _LocationSection({required this.listing});

  final Listing listing;

  String get _shippingLabel {
    if (listing.ships && listing.pickupOnly) return 'Versand oder Abholung';
    if (listing.ships) return 'Versand möglich';
    return 'Nur Abholung';
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(
              LucideIcons.mapPin,
              size: 16,
              color: AsmColors.textSecondary,
            ),
            const SizedBox(width: AsmSpacing.xxs),
            Text(
              '${listing.postalCode} ${listing.city}',
              style: AsmTextStyles.bodyM,
            ),
          ],
        ),
        const SizedBox(height: AsmSpacing.xxs),
        Row(
          children: [
            const Icon(
              LucideIcons.truck,
              size: 16,
              color: AsmColors.textSecondary,
            ),
            const SizedBox(width: AsmSpacing.xxs),
            Text(_shippingLabel, style: AsmTextStyles.bodyM),
          ],
        ),
      ],
    );
  }
}
