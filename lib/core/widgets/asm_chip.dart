import 'package:asm/core/theme/asm_colors.dart';
import 'package:asm/core/theme/asm_spacing.dart';
import 'package:asm/core/theme/asm_text_styles.dart';
import 'package:flutter/material.dart';

/// Filter-/Zustands-/Attribut-Chip. Siehe 01-DESIGN-SYSTEM.md Abschnitt 5.3.
class AsmChip extends StatelessWidget {
  const AsmChip({
    required this.label,
    required this.selected,
    this.onTap,
    this.icon,
    super.key,
  });

  final String label;
  final bool selected;
  final VoidCallback? onTap;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final fill = selected
        ? AsmColors.brand.withValues(alpha: 0.22)
        : AsmColors.surfaceRaised;
    final borderColor = selected ? AsmColors.brandBright : AsmColors.border;
    final textColor = selected
        ? AsmColors.brandBright
        : AsmColors.textSecondary;

    return SizedBox(
      height: 34,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AsmRadius.full),
          child: Container(
            decoration: BoxDecoration(
              color: fill,
              borderRadius: BorderRadius.circular(AsmRadius.full),
              border: Border.all(color: borderColor),
            ),
            padding: const EdgeInsets.symmetric(horizontal: AsmSpacing.sm),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (icon != null) ...[
                  Icon(icon, size: 16, color: textColor),
                  const SizedBox(width: AsmSpacing.xxs),
                ],
                Text(
                  label,
                  style: AsmTextStyles.label.copyWith(color: textColor),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
