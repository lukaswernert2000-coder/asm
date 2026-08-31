import 'package:asm/core/theme/asm_spacing.dart';
import 'package:asm/core/theme/asm_text_styles.dart';
import 'package:asm/core/utils/formatters.dart';
import 'package:asm/features/listings/domain/listing.dart';
import 'package:flutter/material.dart';

/// Preiszeile mit VB-/Tausch-Badges plus Zustands-Badge. Siehe Task 5.1,
/// Farb-/Radius-Muster wie `ListingCard._conditionBadge()`.
class ListingPriceHeader extends StatelessWidget {
  const ListingPriceHeader({required this.listing, super.key});

  final Listing listing;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      crossAxisAlignment: WrapCrossAlignment.center,
      spacing: AsmSpacing.sm,
      runSpacing: AsmSpacing.xxs,
      children: [
        Text(
          listing.isGiveaway
              ? 'Zu verschenken'
              : Formatters.price(listing.priceCents),
          style: AsmTextStyles.price,
        ),
        if (listing.negotiable) const Text('VB', style: AsmTextStyles.bodyM),
        if (listing.acceptsSwap)
          const Text('Tausch möglich', style: AsmTextStyles.bodyM),
        _ConditionBadge(condition: listing.condition),
      ],
    );
  }
}

class _ConditionBadge extends StatelessWidget {
  const _ConditionBadge({required this.condition});

  final ListingCondition condition;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AsmSpacing.xs,
        vertical: 2,
      ),
      decoration: BoxDecoration(
        color: condition.badgeColor,
        borderRadius: BorderRadius.circular(AsmRadius.sm),
      ),
      child: Text(
        condition.label,
        style: AsmTextStyles.label.copyWith(color: condition.badgeTextColor),
      ),
    );
  }
}
