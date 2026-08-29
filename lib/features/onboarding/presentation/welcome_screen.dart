import 'package:asm/core/router/routes.dart';
import 'package:asm/core/theme/asm_colors.dart';
import 'package:asm/core/theme/asm_spacing.dart';
import 'package:asm/core/theme/asm_text_styles.dart';
import 'package:asm/core/widgets/asm_button.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AsmColors.bg,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AsmSpacing.lg),
          child: Column(
            children: [
              const Spacer(flex: 3),
              // Platzhalter-Wordmark, bis das echte Logo geliefert wird --
              // siehe DECISIONS.md.
              const Text(
                'ASM',
                style: AsmTextStyles.displayL,
                textAlign: TextAlign.center,
              ),
              const Spacer(flex: 2),
              AsmButton(
                label: 'Konto erstellen',
                onPressed: () => context.go(AsmRoutes.register),
              ),
              const SizedBox(height: AsmSpacing.sm),
              AsmButton(
                label: 'Anmelden',
                variant: AsmButtonVariant.secondary,
                onPressed: () => context.go(AsmRoutes.login),
              ),
              const SizedBox(height: AsmSpacing.sm),
              AsmButton(
                label: 'Erstmal umsehen',
                variant: AsmButtonVariant.ghost,
                onPressed: () => context.go(AsmRoutes.home),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
