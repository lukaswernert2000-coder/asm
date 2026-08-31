import 'package:asm/core/config/app_config.dart';
import 'package:asm/core/theme/asm_colors.dart';
import 'package:asm/core/theme/asm_spacing.dart';
import 'package:asm/core/theme/asm_text_styles.dart';
import 'package:asm/core/utils/formatters.dart';
import 'package:asm/core/widgets/asm_network_image.dart';
import 'package:asm/features/profile/domain/avatar_url.dart';
import 'package:asm/features/profile/domain/profile.dart';
import 'package:flutter/material.dart';

/// Kompakte Verkaeufer-Karte auf der Detailseite (Task 5.1) -- Avatar, Name,
/// Mitglied seit, aktive Inserate, Gewerblich-Badge. Anders als
/// `PublicProfileScreen`s volle Ansicht: tappbar zum ganzen Profil statt
/// dessen Inhalt zu wiederholen.
class SellerCard extends StatelessWidget {
  const SellerCard({
    required this.seller,
    required this.activeListingsCount,
    required this.onTap,
    super.key,
  });

  final Profile seller;
  final int activeListingsCount;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final imageUrl = avatarUrl(
      supabaseUrl: AppConfig.supabaseUrl,
      path: seller.avatarPath,
    );

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
                borderRadius: BorderRadius.circular(AsmRadius.full),
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
                      seller.displayName ?? seller.username,
                      style: AsmTextStyles.titleS,
                    ),
                    Text(
                      'Mitglied seit ${Formatters.date(seller.createdAt)}',
                      style: AsmTextStyles.bodyS.copyWith(
                        color: AsmColors.textSecondary,
                      ),
                    ),
                    if (seller.isCommercial)
                      Text(
                        seller.commercialName ?? 'Gewerblicher Verkäufer',
                        style: AsmTextStyles.bodyS.copyWith(
                          color: AsmColors.warning,
                        ),
                      ),
                    if (activeListingsCount > 0)
                      Text(
                        '$activeListingsCount aktive Inserate',
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
