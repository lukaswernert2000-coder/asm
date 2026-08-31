import 'package:asm/core/theme/asm_colors.dart';
import 'package:asm/core/theme/asm_spacing.dart';
import 'package:asm/core/theme/asm_text_styles.dart';
import 'package:asm/features/listings/domain/listing.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

/// Attributtabelle der Detailseite -- nur Zeilen, die tatsaechlich befuellt
/// sind (Task 5.1). Leer, wenn kein Attribut am Inserat gesetzt ist.
class ListingAttributeTable extends StatelessWidget {
  const ListingAttributeTable({required this.listing, super.key});

  final Listing listing;

  static final _jouleFormat = NumberFormat.decimalPattern('de_DE')
    ..minimumFractionDigits = 2
    ..maximumFractionDigits = 2;

  @override
  Widget build(BuildContext context) {
    final rows = <(String, String)>[
      if ((listing.manufacturer ?? '').isNotEmpty)
        ('Hersteller', listing.manufacturer!),
      if ((listing.model ?? '').isNotEmpty) ('Modell', listing.model!),
      if (listing.joule != null)
        ('Joule', '${_jouleFormat.format(listing.joule)} J'),
      if (listing.propulsion != null)
        ('Antriebsart', listing.propulsion!.label),
      if ((listing.caliber ?? '').isNotEmpty) ('Kaliber', listing.caliber!),
      if (listing.hasFMarking) ('F-Kennzeichen', 'Ja'),
      if (listing.isModified) ('Umgebaut', 'Ja'),
    ];

    if (rows.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final (label, value) in rows)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: AsmSpacing.xxs),
            child: Row(
              children: [
                SizedBox(
                  width: 120,
                  child: Text(
                    label,
                    style: AsmTextStyles.bodyM.copyWith(
                      color: AsmColors.textSecondary,
                    ),
                  ),
                ),
                Expanded(child: Text(value, style: AsmTextStyles.bodyM)),
              ],
            ),
          ),
      ],
    );
  }
}
