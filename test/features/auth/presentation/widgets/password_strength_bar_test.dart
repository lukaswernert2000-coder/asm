import 'package:asm/core/theme/asm_colors.dart';
import 'package:asm/features/auth/presentation/widgets/password_strength_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('calculatePasswordStrength', () {
    test('leer ist PasswordStrength.empty', () {
      expect(calculatePasswordStrength(''), PasswordStrength.empty);
    });

    test('unter 8 Zeichen ist weak', () {
      expect(calculatePasswordStrength('abc123'), PasswordStrength.weak);
    });

    test('nur Buchstaben ist weak (fehlt Ziffer)', () {
      expect(
        calculatePasswordStrength('nurbuchstaben'),
        PasswordStrength.weak,
      );
    });

    test('8+ Zeichen mit Ziffer und Buchstabe ist medium', () {
      expect(calculatePasswordStrength('gear1234'), PasswordStrength.medium);
    });

    test('12+ Zeichen mit Groß-/Kleinschreibung ist strong', () {
      expect(
        calculatePasswordStrength('GearHunter1234'),
        PasswordStrength.strong,
      );
    });

    test('12+ Zeichen mit Sonderzeichen ist strong', () {
      expect(
        calculatePasswordStrength('geargeargear!1'),
        PasswordStrength.strong,
      );
    });

    test('12+ Zeichen aber nur Kleinbuchstaben und Ziffern bleibt medium', () {
      expect(
        calculatePasswordStrength('geargeargear1'),
        PasswordStrength.medium,
      );
    });
  });

  Widget wrap(Widget child) => MaterialApp(
    home: Scaffold(body: Center(child: child)),
  );

  testWidgets('zeigt nichts bei leerem Passwort', (tester) async {
    await tester.pumpWidget(wrap(const PasswordStrengthBar(password: '')));

    expect(find.byType(PasswordStrengthBar), findsOneWidget);
    expect(find.text('Schwach'), findsNothing);
    expect(find.text('Mittel'), findsNothing);
    expect(find.text('Stark'), findsNothing);
  });

  testWidgets('zeigt "Schwach" in dangerText bei weak', (tester) async {
    await tester.pumpWidget(
      wrap(const PasswordStrengthBar(password: 'abc123')),
    );

    final label = tester.widget<Text>(find.text('Schwach'));
    expect(label.style?.color, AsmColors.dangerText);
  });

  testWidgets('zeigt "Mittel" in warning bei medium', (tester) async {
    await tester.pumpWidget(
      wrap(const PasswordStrengthBar(password: 'gear1234')),
    );

    final label = tester.widget<Text>(find.text('Mittel'));
    expect(label.style?.color, AsmColors.warning);
  });

  testWidgets('zeigt "Stark" in successText bei strong', (tester) async {
    await tester.pumpWidget(
      wrap(const PasswordStrengthBar(password: 'GearHunter1234')),
    );

    final label = tester.widget<Text>(find.text('Stark'));
    expect(label.style?.color, AsmColors.successText);
  });
}
