import 'package:asm/core/router/routes.dart';
import 'package:asm/core/theme/asm_colors.dart';
import 'package:asm/core/theme/asm_spacing.dart';
import 'package:asm/core/theme/asm_text_styles.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

/// Einstellungen (Task 7.1) -- ersetzt den `_TitledPlaceholder` aus
/// Task 2.5. Bisher nur ein Eintrag; weitere Einstellungen sind nicht Teil
/// des Plans und wurden deshalb nicht vorgezogen.
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Einstellungen')),
      body: ListView(
        padding: const EdgeInsets.all(AsmSpacing.md),
        children: [
          _SettingsRow(
            icon: LucideIcons.userX,
            label: 'Blockierte Nutzer',
            onTap: () => context.push(AsmRoutes.blockedUsers),
          ),
        ],
      ),
    );
  }
}

class _SettingsRow extends StatelessWidget {
  const _SettingsRow({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: label,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: AsmSpacing.sm),
          child: Row(
            children: [
              Icon(icon, size: 20, color: AsmColors.textPrimary),
              const SizedBox(width: AsmSpacing.sm),
              Expanded(
                child: Text(label, style: AsmTextStyles.bodyL),
              ),
              const Icon(
                LucideIcons.chevronRight,
                size: 20,
                color: AsmColors.textTertiary,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
