import 'package:asm/core/theme/asm_colors.dart';
import 'package:asm/core/theme/asm_spacing.dart';
import 'package:asm/core/theme/asm_text_styles.dart';
import 'package:asm/core/utils/formatters.dart';
import 'package:asm/core/widgets/asm_network_image.dart';
import 'package:asm/features/listings/domain/listing.dart';
import 'package:asm/features/listings/domain/listing_summary.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

enum _CardLayout { grid, list }

/// Feed-Karte fuer ein Inserat. Siehe 01-DESIGN-SYSTEM.md Abschnitt 5.4.
class ListingCard extends StatelessWidget {
  const ListingCard.grid({
    required this.summary,
    required this.onTap,
    this.onFavoriteToggle,
    super.key,
  }) : _layout = _CardLayout.grid;

  const ListingCard.list({
    required this.summary,
    required this.onTap,
    this.onFavoriteToggle,
    super.key,
  }) : _layout = _CardLayout.list;

  final ListingSummary summary;
  final VoidCallback onTap;
  final VoidCallback? onFavoriteToggle;
  final _CardLayout _layout;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AsmRadius.lg),
        child: Container(
          decoration: BoxDecoration(
            color: AsmColors.surface,
            border: Border.all(color: AsmColors.border),
            borderRadius: BorderRadius.circular(AsmRadius.lg),
          ),
          padding: const EdgeInsets.all(AsmSpacing.sm),
          child: _layout == _CardLayout.grid ? _gridBody() : _listBody(),
        ),
      ),
    );
  }

  Widget _gridBody() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        AspectRatio(aspectRatio: 4 / 3, child: _imageArea()),
        const SizedBox(height: AsmSpacing.xs),
        ..._textLines(),
      ],
    );
  }

  Widget _listBody() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(width: 112, height: 112, child: _imageArea()),
        const SizedBox(width: AsmSpacing.sm),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: _textLines(),
          ),
        ),
      ],
    );
  }

  Widget _imageArea() {
    return Hero(
      tag: 'listing-image-${summary.id}',
      child: Stack(
        fit: StackFit.expand,
        children: [
          AsmNetworkImage(
            path: summary.coverPath,
            radius: BorderRadius.circular(AsmRadius.md),
          ),
          if (summary.status == ListingStatus.reserved ||
              summary.status == ListingStatus.sold)
            Positioned.fill(child: _statusOverlay()),
          Positioned(top: 6, right: 6, child: _favoriteButton()),
          Positioned(bottom: 6, left: 6, child: _conditionBadge()),
          if (summary.hasFMarking)
            const Positioned(bottom: 6, right: 6, child: _FMarkingBadge()),
        ],
      ),
    );
  }

  Widget _statusOverlay() {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AsmColors.scrim,
        borderRadius: BorderRadius.circular(AsmRadius.md),
      ),
      child: Center(
        child: Text(
          summary.status == ListingStatus.sold ? 'VERKAUFT' : 'RESERVIERT',
          style: AsmTextStyles.displayM,
        ),
      ),
    );
  }

  Widget _favoriteButton() {
    return Semantics(
      label: 'Zu Favoriten hinzufügen',
      button: true,
      child: GestureDetector(
        onTap: onFavoriteToggle,
        child: Container(
          width: 40,
          height: 40,
          alignment: Alignment.center,
          decoration: const BoxDecoration(
            color: AsmColors.scrim,
            shape: BoxShape.circle,
          ),
          child: const Icon(
            LucideIcons.heart,
            size: 18,
            color: AsmColors.textPrimary,
          ),
        ),
      ),
    );
  }

  Widget _conditionBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AsmSpacing.xs,
        vertical: 2,
      ),
      decoration: BoxDecoration(
        color: _conditionColor(summary.condition),
        borderRadius: BorderRadius.circular(AsmRadius.sm),
      ),
      child: Text(
        summary.condition.label,
        style: AsmTextStyles.label.copyWith(
          color: _conditionTextColor(summary.condition),
        ),
      ),
    );
  }

  List<Widget> _textLines() {
    return [
      Text(
        summary.title,
        style: AsmTextStyles.titleS,
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
      ),
      const SizedBox(height: AsmSpacing.xxs),
      Row(
        children: [
          Expanded(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Flexible(
                  child: Text(
                    Formatters.price(summary.priceCents),
                    style: AsmTextStyles.priceS,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (summary.negotiable) ...[
                  const SizedBox(width: AsmSpacing.xxs),
                  const Text('VB', style: AsmTextStyles.bodyS),
                ],
              ],
            ),
          ),
          if (summary.ships)
            Semantics(
              label: 'Versand möglich',
              child: const Icon(
                LucideIcons.truck,
                size: 14,
                color: AsmColors.textSecondary,
              ),
            ),
        ],
      ),
      const SizedBox(height: AsmSpacing.xxs),
      Text(
        _locationLine(),
        style: AsmTextStyles.bodyS,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
    ];
  }

  String _locationLine() {
    final parts = <String>['${summary.postalCode} ${summary.city}'];
    if (summary.distanceKm != null) {
      parts.add(Formatters.distance(summary.distanceKm!));
    }
    parts.add(Formatters.relativeTime(summary.bumpedAt));
    return parts.join(' · ');
  }
}

Color _conditionColor(ListingCondition condition) => switch (condition) {
  ListingCondition.neu || ListingCondition.neuwertig => AsmColors.success,
  ListingCondition.gebraucht => AsmColors.surfaceRaised,
  ListingCondition.leichteDefekte => AsmColors.warning,
  ListingCondition.defekt || ListingCondition.bastelobjekt => AsmColors.danger,
};

Color _conditionTextColor(ListingCondition condition) =>
    condition == ListingCondition.gebraucht
    ? AsmColors.textSecondary
    : AsmColors.onBrand;

/// F-im-Fuenfeck-Marker, siehe 01-DESIGN-SYSTEM.md Abschnitt 6.
class _FMarkingBadge extends StatelessWidget {
  const _FMarkingBadge();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 20,
      height: 20,
      child: SvgPicture.asset(
        'assets/icons/f-marking.svg',
        colorFilter: const ColorFilter.mode(
          AsmColors.warning,
          BlendMode.srcIn,
        ),
      ),
    );
  }
}
