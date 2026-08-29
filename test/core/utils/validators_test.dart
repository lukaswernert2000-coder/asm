import 'package:asm/core/utils/validators.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('validateUsername', () {
    test('akzeptiert einen gueltigen Nutzernamen', () {
      expect(validateUsername('gear_hunter_42'), isNull);
    });

    test('lehnt zu kurze Namen ab', () {
      expect(validateUsername('ab'), isNotNull);
    });

    test('lehnt zu lange Namen ab', () {
      expect(validateUsername('a' * 25), isNotNull);
    });

    test('lehnt Sonderzeichen ab', () {
      expect(validateUsername('gear-hunter'), isNotNull);
    });

    test('lehnt leeren Wert ab', () {
      expect(validateUsername(''), isNotNull);
      expect(validateUsername(null), isNotNull);
    });
  });

  group('validateEmail', () {
    test('akzeptiert eine gueltige E-Mail', () {
      expect(validateEmail('nutzer@example.de'), isNull);
    });

    test('lehnt eine E-Mail ohne @ ab', () {
      expect(
        validateEmail('nutzer.example.de'),
        'Bitte gib eine gültige E-Mail-Adresse ein',
      );
    });

    test('lehnt eine E-Mail ohne Domain-Punkt ab', () {
      expect(validateEmail('nutzer@example'), isNotNull);
    });

    test('lehnt leeren Wert ab', () {
      expect(validateEmail(''), isNotNull);
      expect(validateEmail(null), isNotNull);
    });
  });

  group('validatePassword', () {
    test('akzeptiert 8 Zeichen mit Zahl und Buchstabe', () {
      expect(validatePassword('gear1234'), isNull);
    });

    test('lehnt weniger als 8 Zeichen ab', () {
      expect(
        validatePassword('gear12'),
        'Mindestens 8 Zeichen mit Zahl und Buchstabe',
      );
    });

    test('lehnt ein Passwort ohne Ziffer ab', () {
      expect(validatePassword('geargeargear'), isNotNull);
    });

    test('lehnt ein Passwort ohne Buchstaben ab', () {
      expect(validatePassword('12345678'), isNotNull);
    });
  });

  group('validateBirthDate', () {
    final now = DateTime(2026, 8, 29);

    test('akzeptiert genau 14 Jahre alt', () {
      expect(validateBirthDate(DateTime(2012, 8, 29), now: now), isNull);
    });

    test('lehnt 13 Jahre und 364 Tage ab (Geburtstag morgen)', () {
      expect(
        validateBirthDate(DateTime(2012, 8, 30), now: now),
        'Die Nutzung ist erst ab 14 Jahren erlaubt',
      );
    });

    test('lehnt ein Datum in der Zukunft ab', () {
      expect(
        validateBirthDate(DateTime(2027), now: now),
        isNotNull,
      );
    });

    test('lehnt null ab', () {
      expect(validateBirthDate(null, now: now), isNotNull);
    });
  });

  group('validateConsent', () {
    test('akzeptiert, wenn beide Haken gesetzt sind', () {
      expect(validateConsent(agb: true, datenschutz: true), isNull);
    });

    test('lehnt ab, wenn AGB fehlt', () {
      expect(
        validateConsent(agb: false, datenschutz: true),
        'Bitte bestätige AGB und Datenschutz',
      );
    });

    test('lehnt ab, wenn Datenschutz fehlt', () {
      expect(validateConsent(agb: true, datenschutz: false), isNotNull);
    });
  });
}
