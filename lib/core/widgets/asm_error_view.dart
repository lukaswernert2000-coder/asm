import 'package:asm/core/widgets/asm_button.dart';
import 'package:asm/core/widgets/asm_empty_state.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

/// Fehlerzustand mit Retry. Kein eigener Abschnitt-5-Eintrag — als duenner
/// Wrapper um `AsmEmptyState` umgesetzt (G14: jede Netzwerkoperation hat
/// einen Fehler-Zustand mit Retry).
class AsmErrorView extends StatelessWidget {
  const AsmErrorView({
    required this.message,
    required this.onRetry,
    super.key,
  });

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return AsmEmptyState(
      icon: LucideIcons.wifiOff,
      title: message,
      action: AsmButton(
        label: 'Erneut versuchen',
        variant: AsmButtonVariant.secondary,
        onPressed: onRetry,
      ),
    );
  }
}
