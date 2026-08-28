import 'package:asm/core/theme/asm_colors.dart';
import 'package:asm/core/theme/asm_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AsmTheme.dark', () {
    final theme = AsmTheme.dark;

    test('nutzt den Tactical-Olive Hintergrund', () {
      expect(theme.scaffoldBackgroundColor, AsmColors.bg);
    });

    test('ist ein Dark-Theme', () {
      expect(theme.brightness, Brightness.dark);
      expect(theme.colorScheme.brightness, Brightness.dark);
    });

    test('nutzt brandBright als Primaerfarbe', () {
      expect(theme.colorScheme.primary, AsmColors.brandBright);
      expect(theme.colorScheme.onPrimary, AsmColors.onBrand);
    });

    test('nutzt Inter als Standardschrift', () {
      expect(theme.textTheme.bodyMedium?.fontFamily, 'Inter');
    });

    test('AppBar ist flach und ohne Tint', () {
      expect(theme.appBarTheme.elevation, 0);
      expect(theme.appBarTheme.scrolledUnderElevation, 0);
    });
  });
}
