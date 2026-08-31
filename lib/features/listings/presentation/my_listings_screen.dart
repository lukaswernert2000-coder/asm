import 'dart:async';

import 'package:asm/core/router/routes.dart';
import 'package:asm/core/theme/asm_colors.dart';
import 'package:asm/core/theme/asm_spacing.dart';
import 'package:asm/core/theme/asm_text_styles.dart';
import 'package:asm/core/utils/formatters.dart';
import 'package:asm/core/widgets/asm_error_view.dart';
import 'package:asm/core/widgets/asm_network_image.dart';
import 'package:asm/core/widgets/asm_skeleton.dart';
import 'package:asm/features/auth/presentation/auth_controller.dart';
import 'package:asm/features/listings/domain/listing.dart';
import 'package:asm/features/listings/presentation/listing_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

const List<ListingStatus> _tabStatuses = [
  ListingStatus.active,
  ListingStatus.reserved,
  ListingStatus.sold,
  ListingStatus.draft,
];
const _tabLabels = ['Aktiv', 'Reserviert', 'Verkauft', 'Entwürfe'];
const _tabEmptyTexts = [
  'Noch keine aktiven Inserate',
  'Keine reservierten Inserate',
  'Keine verkauften Inserate',
  'Keine Entwürfe',
];

void _noop() {}

/// "Meine Inserate" (Task 4.3): vier Tabs nach Status, pro Inserat ein
/// Aktionsmenue (Bearbeiten, Hochschieben, Status- und Loeschaktionen).
class MyListingsScreen extends ConsumerWidget {
  const MyListingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userId = ref.watch(currentUserProvider)?.id;

    return DefaultTabController(
      length: _tabStatuses.length,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Meine Inserate'),
          bottom: TabBar(
            labelColor: AsmColors.textPrimary,
            unselectedLabelColor: AsmColors.textSecondary,
            indicatorColor: AsmColors.brandBright,
            labelStyle: AsmTextStyles.label,
            unselectedLabelStyle: AsmTextStyles.label,
            tabs: [for (final label in _tabLabels) Tab(text: label)],
          ),
        ),
        body: userId == null
            ? const AsmErrorView(message: 'Nicht angemeldet', onRetry: _noop)
            : TabBarView(
                children: [
                  for (var i = 0; i < _tabStatuses.length; i++)
                    _ListingsTab(
                      sellerId: userId,
                      status: _tabStatuses[i],
                      emptyText: _tabEmptyTexts[i],
                    ),
                ],
              ),
      ),
    );
  }
}

class _ListingsTab extends ConsumerWidget {
  const _ListingsTab({
    required this.sellerId,
    required this.status,
    required this.emptyText,
  });

  final String sellerId;
  final ListingStatus status;
  final String emptyText;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final args = (sellerId: sellerId, status: status);
    final listingsAsync = ref.watch(listingsBySellerStatusProvider(args));

    return listingsAsync.when(
      loading: () => const Padding(
        padding: EdgeInsets.all(AsmSpacing.md),
        child: AsmSkeleton.listingList(),
      ),
      error: (error, stackTrace) => AsmErrorView(
        message: 'Inserate konnten nicht geladen werden',
        onRetry: () => ref.invalidate(listingsBySellerStatusProvider(args)),
      ),
      data: (listings) => listings.isEmpty
          ? Center(child: Text(emptyText))
          : ListView.separated(
              padding: const EdgeInsets.all(AsmSpacing.md),
              itemCount: listings.length,
              separatorBuilder: (_, _) => const SizedBox(height: AsmSpacing.sm),
              itemBuilder: (context, index) =>
                  _ListingRow(listing: listings[index]),
            ),
    );
  }
}

class _ListingRow extends ConsumerWidget {
  const _ListingRow({required this.listing});

  final Listing listing;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SizedBox(
      height: 96,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(AsmRadius.md),
            child: const SizedBox(
              width: 96,
              height: 96,
              child: AsmNetworkImage(path: null),
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
                const SizedBox(height: AsmSpacing.xxs),
                Row(
                  children: [
                    const Icon(
                      LucideIcons.eye,
                      size: 14,
                      color: AsmColors.textTertiary,
                    ),
                    const SizedBox(width: AsmSpacing.xxs),
                    Text(
                      '${listing.viewCount}',
                      style: AsmTextStyles.bodyS.copyWith(
                        color: AsmColors.textTertiary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          IconButton(
            key: Key('listingActions_${listing.id}'),
            icon: const Icon(LucideIcons.ellipsisVertical),
            tooltip: 'Aktionen für ${listing.title}',
            onPressed: () => _showActions(context, ref, listing),
          ),
        ],
      ),
    );
  }
}

Future<void> _showActions(
  BuildContext rowContext,
  WidgetRef ref,
  Listing listing,
) async {
  final showBump =
      listing.status == ListingStatus.active ||
      listing.status == ListingStatus.reserved;
  final canBump = showBump && listing.canBump();
  final daysLeft =
      bumpCooldown.inDays -
      DateTime.now().difference(listing.lastBumpReference).inDays;

  await showModalBottomSheet<void>(
    context: rowContext,
    builder: (sheetContext) => SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(LucideIcons.pencil),
            title: const Text('Bearbeiten'),
            onTap: () {
              Navigator.of(sheetContext).pop();
              unawaited(rowContext.push(AsmRoutes.editListing(listing.id)));
            },
          ),
          if (showBump)
            ListTile(
              leading: const Icon(LucideIcons.arrowUpCircle),
              title: const Text('Hochschieben'),
              subtitle: canBump ? null : Text('Noch $daysLeft Tage'),
              onTap: canBump
                  ? () async {
                      Navigator.of(sheetContext).pop();
                      await ref
                          .read(listingRepositoryProvider)
                          .bump(listing.id);
                      refreshSellerListings(
                        ref,
                        sellerId: listing.sellerId,
                        listingId: listing.id,
                      );
                    }
                  : null,
            ),
          if (listing.status == ListingStatus.active)
            ListTile(
              leading: const Icon(LucideIcons.clock),
              title: const Text('Als reserviert markieren'),
              onTap: () async {
                Navigator.of(sheetContext).pop();
                await ref
                    .read(listingRepositoryProvider)
                    .setStatus(listing.id, ListingStatus.reserved);
                refreshSellerListings(
                  ref,
                  sellerId: listing.sellerId,
                  listingId: listing.id,
                );
              },
            ),
          if (listing.status == ListingStatus.reserved)
            ListTile(
              leading: const Icon(LucideIcons.rotateCcw),
              title: const Text('Als aktiv markieren'),
              onTap: () async {
                Navigator.of(sheetContext).pop();
                await ref
                    .read(listingRepositoryProvider)
                    .setStatus(listing.id, ListingStatus.active);
                refreshSellerListings(
                  ref,
                  sellerId: listing.sellerId,
                  listingId: listing.id,
                );
              },
            ),
          if (listing.status == ListingStatus.active ||
              listing.status == ListingStatus.reserved)
            ListTile(
              leading: const Icon(LucideIcons.checkCheck),
              title: const Text('Als verkauft markieren'),
              onTap: () async {
                Navigator.of(sheetContext).pop();
                await ref
                    .read(listingRepositoryProvider)
                    .setStatus(listing.id, ListingStatus.sold);
                refreshSellerListings(
                  ref,
                  sellerId: listing.sellerId,
                  listingId: listing.id,
                );
              },
            ),
          ListTile(
            leading: const Icon(LucideIcons.trash2),
            title: const Text('Löschen'),
            onTap: () async {
              Navigator.of(sheetContext).pop();
              await _confirmAndDelete(rowContext, ref, listing);
            },
          ),
        ],
      ),
    ),
  );
}

Future<void> _confirmAndDelete(
  BuildContext context,
  WidgetRef ref,
  Listing listing,
) async {
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Inserat löschen?'),
      content: const Text(
        'Das Inserat und alle zugehörigen Fotos werden endgültig gelöscht. '
        'Das kann nicht rückgängig gemacht werden.',
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: const Text('Abbrechen'),
        ),
        TextButton(
          onPressed: () => Navigator.of(context).pop(true),
          child: const Text('Löschen'),
        ),
      ],
    ),
  );
  if (confirmed != true) return;

  await ref.read(imageServiceProvider).deleteAll(listingId: listing.id);
  await ref.read(listingRepositoryProvider).delete(listing.id);
  refreshSellerListings(
    ref,
    sellerId: listing.sellerId,
    listingId: listing.id,
  );
}
