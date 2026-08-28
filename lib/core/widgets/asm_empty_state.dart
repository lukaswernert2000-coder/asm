import 'package:asm/core/theme/asm_colors.dart';
import 'package:asm/core/theme/asm_spacing.dart';
import 'package:asm/core/theme/asm_text_styles.dart';
import 'package:flutter/material.dart';

/// Leerer/Fehler-Zustand mit Icon, Titel, optionaler Beschreibung und Aktion.
/// Siehe 01-DESIGN-SYSTEM.md Abschnitt 5.7.
class AsmEmptyState extends StatelessWidget {
  const AsmEmptyState({
    required this.icon,
    required this.title,
    this.message,
    this.action,
    super.key,
  });

  final IconData icon;
  final String title;
  final String? message;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 320),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 48, color: AsmColors.textTertiary),
            const SizedBox(height: AsmSpacing.md),
            Text(
              title,
              style: AsmTextStyles.titleM,
              textAlign: TextAlign.center,
            ),
            if (message != null) ...[
              const SizedBox(height: AsmSpacing.xs),
              Text(
                message!,
                style: AsmTextStyles.bodyM.copyWith(
                  color: AsmColors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
            ],
            if (action != null) ...[
              const SizedBox(height: AsmSpacing.lg),
              action!,
            ],
          ],
        ),
      ),
    );
  }
}
