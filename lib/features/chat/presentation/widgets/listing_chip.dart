import 'package:asm/core/theme/asm_colors.dart';
import 'package:asm/core/theme/asm_spacing.dart';
import 'package:asm/core/theme/asm_text_styles.dart';
import 'package:asm/core/utils/formatters.dart';
import 'package:asm/core/widgets/asm_network_image.dart';
import 'package:asm/features/listings/domain/listing.dart';
import 'package:flutter/material.dart';

/// Miniatur-Karte des Inserats, oben in der Chat-Detailseite (Task 6.2).
/// Siehe 01-DESIGN-SYSTEM.md Abschnitt 5.6. Gleiches Muster wie `SellerCard`.
class ListingChip extends StatelessWidget {
  const ListingChip({
    required this.listing,
    required this.imageUrl,
    required this.onTap,
    super.key,
  });

  final Listing listing;
  final String? imageUrl;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AsmRadius.lg),
        child: Container(
          padding: const EdgeInsets.all(AsmSpacing.sm),
          decoration: BoxDecoration(
            color: AsmColors.surface,
            border: Border.all(color: AsmColors.border),
            borderRadius: BorderRadius.circular(AsmRadius.lg),
          ),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(AsmRadius.md),
                child: SizedBox(
                  width: 48,
                  height: 48,
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
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      Formatters.price(listing.priceCents),
                      style: AsmTextStyles.bodyS.copyWith(
                        color: AsmColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
