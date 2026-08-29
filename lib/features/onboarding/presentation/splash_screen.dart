import 'package:asm/core/theme/asm_colors.dart';
import 'package:asm/core/theme/asm_text_styles.dart';
import 'package:flutter/material.dart';

/// Reiner Wartebildschirm ohne eigene Logik -- das Warten auf Session und
/// Kategorien (max. 3 s) sitzt in `AsmApp`, das zwischen diesem Screen und
/// der echten `MaterialApp.router` umschaltet.
class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: AsmColors.bg,
      body: Center(
        // Platzhalter-Wordmark, bis das echte Logo geliefert wird -- siehe
        // DECISIONS.md.
        child: Text('ASM', style: AsmTextStyles.displayL),
      ),
    );
  }
}
