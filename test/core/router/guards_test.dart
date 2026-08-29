import 'package:asm/core/router/guards.dart';
import 'package:asm/core/router/routes.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('redirect', () {
    test('leitet /create ohne Session zu /login mit from-Parameter um', () {
      final result = redirect(
        location: '/create',
        isLoggedIn: false,
        emailConfirmed: false,
      );

      expect(result, '/login?from=/create');
    });

    test('leitet /chats ohne Session zu /login mit from-Parameter um', () {
      final result = redirect(
        location: '/chats',
        isLoggedIn: false,
        emailConfirmed: false,
      );

      expect(result, '/login?from=/chats');
    });

    test('laesst /search ohne Session unangetastet (kein Gate fuers Gast-Browsing)', () {
      final result = redirect(
        location: '/search',
        isLoggedIn: false,
        emailConfirmed: false,
      );

      expect(result, isNull);
    });

    test('laesst /login selbst unangetastet, auch ohne Session', () {
      final result = redirect(
        location: '/login',
        isLoggedIn: false,
        emailConfirmed: false,
      );

      expect(result, isNull);
    });

    test('leitet /create bei unbestaetigter E-Mail zum Hinweis um', () {
      final result = redirect(
        location: '/create',
        isLoggedIn: true,
        emailConfirmed: false,
      );

      expect(result, AsmRoutes.confirmEmail);
    });

    test('laesst /create bei bestaetigter E-Mail unangetastet', () {
      final result = redirect(
        location: '/create',
        isLoggedIn: true,
        emailConfirmed: true,
      );

      expect(result, isNull);
    });

    test('leitet /settings ohne Session zu /login mit from-Parameter um', () {
      final result = redirect(
        location: AsmRoutes.settings,
        isLoggedIn: false,
        emailConfirmed: false,
      );

      expect(result, '/login?from=${AsmRoutes.settings}');
    });

    test(
      'leitet /profile/edit ohne Session zu /login um (Sub-Pfad von /profile)',
      () {
        final result = redirect(
          location: AsmRoutes.editProfile,
          isLoggedIn: false,
          emailConfirmed: false,
        );

        expect(result, '/login?from=${AsmRoutes.editProfile}');
      },
    );

    test('laesst /user/:id (Fremdprofil) ohne Session unangetastet — Browsing ist Gast erlaubt', () {
      final result = redirect(
        location: AsmRoutes.publicProfile('abc-123'),
        isLoggedIn: false,
        emailConfirmed: false,
      );

      expect(result, isNull);
    });
  });

  group('blocksForAge', () {
    test('sperrt eine 18+-Kategorie fuer Nicht-Erwachsene', () {
      expect(blocksForAge(requiresAge18: true, isAdult: false), isTrue);
    });

    test('sperrt eine 18+-Kategorie nicht fuer Erwachsene', () {
      expect(blocksForAge(requiresAge18: true, isAdult: true), isFalse);
    });

    test('sperrt eine Kategorie ohne Altersgrenze nie', () {
      expect(blocksForAge(requiresAge18: false, isAdult: false), isFalse);
    });
  });
}
