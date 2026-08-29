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
import 'package:lucide_icons_flutter/lucide_icons.dart';

/// Nur Lesen und Anzeigen -- Bearbeiten, Hochschieben, Status- und
/// Loeschaktionen sind Task 4.3 ("Bearbeiten und Statuswechsel", inkl. der
/// vier Tabs Aktiv/Reserviert/Verkauft/Entwuerfe). Diese Vorschau zeigt nur
/// die aktiven Inserate, weil `bySeller` dafuer schon bereitsteht.
class MyListingsScreen extends ConsumerWidget {
  const MyListingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userId = ref.watch(currentUserProvider)?.id;
    final listingsAsync = userId == null
        ? const AsyncValue<List<Listing>>.data([])
        : ref.watch(activeListingsBySellerProvider(userId));

    return Scaffold(
      appBar: AppBar(title: const Text('Meine Inserate')),
      body: listingsAsync.when(
        loading: () => const Padding(
          padding: EdgeInsets.all(AsmSpacing.md),
          child: AsmSkeleton.listingList(),
        ),
        error: (error, stackTrace) => AsmErrorView(
          message: 'Inserate konnten nicht geladen werden',
          onRetry: () => userId == null
              ? null
              : ref.invalidate(activeListingsBySellerProvider(userId)),
        ),
        data: (listings) => listings.isEmpty
            ? const Center(child: Text('Noch keine Inserate'))
            : ListView.separated(
                padding: const EdgeInsets.all(AsmSpacing.md),
                itemCount: listings.length,
                separatorBuilder: (_, _) =>
                    const SizedBox(height: AsmSpacing.sm),
                itemBuilder: (context, index) =>
                    _ListingRow(listing: listings[index]),
              ),
      ),
    );
  }
}

class _ListingRow extends StatelessWidget {
  const _ListingRow({required this.listing});

  final Listing listing;

  @override
  Widget build(BuildContext context) {
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
        ],
      ),
    );
  }
}
