import 'package:asm/core/theme/asm_colors.dart';
import 'package:asm/core/theme/asm_spacing.dart';
import 'package:asm/core/widgets/asm_button.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

/// Untere Aktionsleiste der Detailseite (Task 5.1): Primäraktion (Nachricht
/// schreiben / Bearbeiten -- der Screen entscheidet Label und Aktion),
/// Favoriten-Herz, Teilen. Lucide hat keine gefuellte Herz-Variante --
/// favorisiert wird stattdessen ueber die Farbe angezeigt.
class ListingBottomBar extends StatelessWidget {
  const ListingBottomBar({
    required this.primaryLabel,
    required this.onPrimaryPressed,
    required this.isFavorited,
    required this.onFavoriteToggle,
    required this.onShare,
    super.key,
  });

  final String primaryLabel;
  final VoidCallback onPrimaryPressed;
  final bool isFavorited;
  final VoidCallback onFavoriteToggle;
  final VoidCallback onShare;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.all(AsmSpacing.md),
        child: Row(
          children: [
            Expanded(
              child: AsmButton(
                label: primaryLabel,
                onPressed: onPrimaryPressed,
              ),
            ),
            const SizedBox(width: AsmSpacing.xs),
            Semantics(
              label: isFavorited
                  ? 'Von Favoriten entfernen'
                  : 'Zu Favoriten hinzufügen',
              button: true,
              child: IconButton(
                onPressed: onFavoriteToggle,
                icon: Icon(
                  LucideIcons.heart,
                  color: isFavorited ? AsmColors.danger : AsmColors.textPrimary,
                ),
              ),
            ),
            Semantics(
              label: 'Inserat teilen',
              button: true,
              child: IconButton(
                onPressed: onShare,
                icon: const Icon(
                  LucideIcons.share2,
                  color: AsmColors.textPrimary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
