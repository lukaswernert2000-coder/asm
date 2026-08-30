import 'package:asm/core/router/routes.dart';

const List<String> _protectedRoutes = [
  AsmRoutes.create,
  AsmRoutes.chats,
  AsmRoutes.favorites,
  AsmRoutes.myListings,
  AsmRoutes.profile,
  AsmRoutes.settings,
];

bool _isProtected(String location) {
  return _protectedRoutes.any(
    (route) => location == route || location.startsWith('$route/'),
  );
}

String? redirect({
  required String location,
  required bool isLoggedIn,
  required bool emailConfirmed,
  bool hasSeenOnboarding = true,
}) {
  if (location == AsmRoutes.home && !hasSeenOnboarding) {
    return AsmRoutes.onboarding;
  }
  if (_isProtected(location) && !isLoggedIn) {
    return '${AsmRoutes.login}?from=$location';
  }
  if (location == AsmRoutes.create && isLoggedIn && !emailConfirmed) {
    return AsmRoutes.confirmEmail;
  }
  return null;
}

/// Reine Entscheidungslogik fuers Altersgate auf der Kauf-/Kontaktieren-Aktion
/// (Task 5.1 "Nachricht schreiben"). Inserate und Kategorien selbst sind fuer
/// alle sichtbar -- das Gate sperrt nur diese Aktion. Noch an keinen Button
/// angebunden: Task 5.1 existiert erst ab M5 (siehe DECISIONS.md).
bool blocksForAge({required bool requiresAge18, required bool isAdult}) {
  return requiresAge18 && !isAdult;
}
