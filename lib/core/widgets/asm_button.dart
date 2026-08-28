import 'package:asm/core/theme/asm_colors.dart';
import 'package:asm/core/theme/asm_spacing.dart';
import 'package:asm/core/theme/asm_text_styles.dart';
import 'package:flutter/material.dart';

enum AsmButtonVariant { primary, secondary, ghost, danger }

/// Primär-Aktionselement der App. Siehe 01-DESIGN-SYSTEM.md Abschnitt 5.1.
class AsmButton extends StatelessWidget {
  const AsmButton({
    required this.label,
    this.onPressed,
    this.variant = AsmButtonVariant.primary,
    this.isLoading = false,
    this.icon,
    super.key,
  });

  final String label;
  final VoidCallback? onPressed;
  final AsmButtonVariant variant;
  final bool isLoading;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final disabled = onPressed == null;
    // 5.1 nennt fuer ghost 44dp, G15 verlangt ueberall mind. 48dp Tap-Ziel.
    // Globale Regel gewinnt (keine dokumentierte Ausnahme fuer ghost).
    final height = variant == AsmButtonVariant.ghost ? 48.0 : 52.0;

    final (
      Color? fill,
      Color labelColor,
      Color? borderColor,
    ) = switch (variant) {
      AsmButtonVariant.primary => (
        AsmColors.brandBright,
        AsmColors.onBrand,
        null,
      ),
      AsmButtonVariant.secondary => (
        AsmColors.surfaceRaised,
        AsmColors.textPrimary,
        AsmColors.border,
      ),
      AsmButtonVariant.ghost => (null, AsmColors.brandBright, null),
      AsmButtonVariant.danger => (
        null,
        AsmColors.dangerText,
        AsmColors.dangerText,
      ),
    };

    final pressedFill = switch (variant) {
      AsmButtonVariant.primary => AsmColors.brandDim,
      AsmButtonVariant.secondary => AsmColors.surface,
      AsmButtonVariant.ghost || AsmButtonVariant.danger => null,
    };

    return SizedBox(
      width: double.infinity,
      height: height,
      child: Opacity(
        opacity: disabled ? 0.38 : 1.0,
        child: Material(
          color: Colors.transparent,
          child: Container(
            decoration: BoxDecoration(
              color: fill,
              borderRadius: BorderRadius.circular(AsmRadius.md),
              border: borderColor != null
                  ? Border.all(color: borderColor)
                  : null,
            ),
            clipBehavior: Clip.antiAlias,
            child: InkWell(
              onTap: (disabled || isLoading) ? null : onPressed,
              highlightColor: pressedFill,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: AsmSpacing.lg),
                child: Center(
                  child: isLoading
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation(
                              AsmColors.onBrand,
                            ),
                          ),
                        )
                      : Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (icon != null) ...[
                              Icon(icon, color: labelColor),
                              const SizedBox(width: AsmSpacing.xs),
                            ],
                            Text(
                              label,
                              style: AsmTextStyles.titleS.copyWith(
                                color: labelColor,
                              ),
                            ),
                          ],
                        ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
