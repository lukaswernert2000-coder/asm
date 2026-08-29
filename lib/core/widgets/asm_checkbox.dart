import 'package:asm/core/theme/asm_colors.dart';
import 'package:asm/core/theme/asm_spacing.dart';
import 'package:asm/core/theme/asm_text_styles.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

/// Pflicht-Ankreuzfeld mit beliebigem Label (z. B. Text mit eingebetteten
/// Links). Nur die Box selbst toggelt bei Tap, damit Links im Label ihren
/// eigenen Tap-Handler ohne Interferenz behalten. Siehe 01-DESIGN-SYSTEM.md
/// Abschnitt 5 (Farb-/Abstands-Tokens), Komponente selbst dort nicht
/// spezifiziert.
class AsmCheckbox extends StatelessWidget {
  const AsmCheckbox({
    required this.value,
    required this.onChanged,
    required this.label,
    this.errorText,
    super.key,
  });

  final bool value;
  final ValueChanged<bool> onChanged;
  final Widget label;
  final String? errorText;

  static const _boxSize = 22.0;

  @override
  Widget build(BuildContext context) {
    final hasError = errorText != null;
    final borderColor = hasError
        ? AsmColors.dangerText
        : (value ? AsmColors.brandBright : AsmColors.border);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Semantics(
              label: 'Ankreuzfeld',
              checked: value,
              child: GestureDetector(
                onTap: () => onChanged(!value),
                child: SizedBox(
                  width: AsmSpacing.huge,
                  height: AsmSpacing.huge,
                  child: Center(
                    child: Container(
                      width: _boxSize,
                      height: _boxSize,
                      decoration: BoxDecoration(
                        color: value ? AsmColors.brandBright : AsmColors.surface,
                        borderRadius: BorderRadius.circular(AsmRadius.sm),
                        border: Border.all(
                          color: borderColor,
                          width: hasError ? 1.5 : 1,
                        ),
                      ),
                      child: value
                          ? const Icon(
                              LucideIcons.check,
                              size: 16,
                              color: AsmColors.onBrand,
                            )
                          : null,
                    ),
                  ),
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(top: AsmSpacing.md),
                child: DefaultTextStyle.merge(
                  style: AsmTextStyles.bodyM,
                  child: label,
                ),
              ),
            ),
          ],
        ),
        if (hasError) ...[
          const SizedBox(height: AsmSpacing.xxs),
          Padding(
            padding: const EdgeInsets.only(left: AsmSpacing.huge),
            child: Text(
              errorText!,
              style: AsmTextStyles.bodyS.copyWith(color: AsmColors.dangerText),
            ),
          ),
        ],
      ],
    );
  }
}
