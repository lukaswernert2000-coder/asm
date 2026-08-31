import 'package:asm/core/theme/asm_colors.dart';
import 'package:asm/core/theme/asm_spacing.dart';
import 'package:asm/core/theme/asm_text_styles.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

/// Waffenrechtlicher Hinweis fuer Inserate ueber 0,5 Joule, siehe
/// 00-SPEC.md Abschnitt 7.1 ("Transport nur in verschlossenem Behaeltnis |
/// Hinweis auf der Inserat-Detailseite bei ueber 0,5 J") und Task 5.1.
/// Zeigt nichts, wenn [joule] fehlt oder nicht ueber 0,5 liegt.
class ListingLegalWarningBox extends StatelessWidget {
  const ListingLegalWarningBox({required this.joule, super.key});

  final double? joule;

  @override
  Widget build(BuildContext context) {
    if (joule == null || joule! <= 0.5) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(AsmSpacing.sm),
      decoration: BoxDecoration(
        color: AsmColors.warning.withValues(alpha: 0.12),
        border: Border.all(color: AsmColors.warning),
        borderRadius: BorderRadius.circular(AsmRadius.md),
      ),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            LucideIcons.triangleAlert,
            size: 18,
            color: AsmColors.warningText,
          ),
          SizedBox(width: AsmSpacing.xs),
          Expanded(
            child: Text(
              'Abgabe nur an Personen ab 18. Transport nur im '
              'verschlossenen Behältnis (§42a WaffG).',
              style: AsmTextStyles.bodyS,
            ),
          ),
        ],
      ),
    );
  }
}
