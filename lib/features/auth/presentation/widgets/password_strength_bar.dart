import 'package:asm/core/theme/asm_colors.dart';
import 'package:asm/core/theme/asm_spacing.dart';
import 'package:asm/core/theme/asm_text_styles.dart';
import 'package:flutter/material.dart';

enum PasswordStrength { empty, weak, medium, strong }

final _digitPattern = RegExp('[0-9]');
final _letterPattern = RegExp('[a-zA-Z]');
final _lowerPattern = RegExp('[a-z]');
final _upperPattern = RegExp('[A-Z]');
final _specialPattern = RegExp('[^a-zA-Z0-9]');

/// Nur eine visuelle Einschaetzung fuers UI, keine Validierung. Die
/// tatsaechliche Passwort-Regel (min. 8 Zeichen, Ziffer + Buchstabe) steht in
/// `lib/core/utils/validators.dart`.
PasswordStrength calculatePasswordStrength(String password) {
  if (password.isEmpty) return PasswordStrength.empty;

  final meetsMinimum =
      password.length >= 8 &&
      _digitPattern.hasMatch(password) &&
      _letterPattern.hasMatch(password);
  if (!meetsMinimum) return PasswordStrength.weak;

  final hasVariety =
      (_lowerPattern.hasMatch(password) && _upperPattern.hasMatch(password)) ||
      _specialPattern.hasMatch(password);
  if (password.length >= 12 && hasVariety) return PasswordStrength.strong;

  return PasswordStrength.medium;
}

class PasswordStrengthBar extends StatelessWidget {
  const PasswordStrengthBar({required this.password, super.key});

  final String password;

  static const _barHeight = 4.0;

  @override
  Widget build(BuildContext context) {
    final strength = calculatePasswordStrength(password);
    if (strength == PasswordStrength.empty) {
      return const SizedBox(height: _barHeight);
    }

    final (int filledSegments, Color color, String label) = switch (strength) {
      PasswordStrength.empty => (0, AsmColors.border, ''),
      PasswordStrength.weak => (1, AsmColors.dangerText, 'Schwach'),
      PasswordStrength.medium => (2, AsmColors.warning, 'Mittel'),
      PasswordStrength.strong => (3, AsmColors.successText, 'Stark'),
    };

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          children: List.generate(3, (i) {
            final filled = i < filledSegments;
            return Expanded(
              child: Padding(
                padding: EdgeInsets.only(
                  right: i < 2 ? AsmSpacing.xxs : 0,
                ),
                child: Container(
                  height: _barHeight,
                  decoration: BoxDecoration(
                    color: filled ? color : AsmColors.border,
                    borderRadius: BorderRadius.circular(AsmRadius.full),
                  ),
                ),
              ),
            );
          }),
        ),
        const SizedBox(height: AsmSpacing.xxs),
        Text(label, style: AsmTextStyles.bodyS.copyWith(color: color)),
      ],
    );
  }
}
