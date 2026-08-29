import 'package:asm/core/router/routes.dart';
import 'package:asm/core/widgets/asm_button.dart';
import 'package:asm/core/widgets/asm_empty_state.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

/// Hinweis-Screen fuer Task 2.4: `/create` mit Session, aber unbestaetigter
/// E-Mail. Kein eigener Spec-Eintrag in 01-DESIGN-SYSTEM.md — aus
/// bestehenden Tokens gebaut wie schon `AsmErrorView` in Task 0.5.
class ConfirmEmailRequiredScreen extends StatelessWidget {
  const ConfirmEmailRequiredScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AsmEmptyState(
        icon: LucideIcons.mailWarning,
        title: 'Bitte bestätige zuerst deine E-Mail',
        message:
            'Du hast einen Bestätigungslink per E-Mail erhalten. Bitte '
            'bestätige deine Adresse, bevor du ein Inserat aufgibst.',
        action: AsmButton(
          label: 'Zur Startseite',
          onPressed: () => context.go(AsmRoutes.home),
        ),
      ),
    );
  }
}
