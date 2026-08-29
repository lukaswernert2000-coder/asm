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
}) {
  if (_isProtected(location) && !isLoggedIn) {
    return '${AsmRoutes.login}?from=$location';
  }
  if (location == AsmRoutes.create && isLoggedIn && !emailConfirmed) {
    return AsmRoutes.confirmEmail;
  }
  return null;
}

/// Reine Entscheidungslogik fuers Altersgate auf Kategorien mit
/// `requires_age_18`. Noch an keine Route angebunden: `/category/:slug`
/// existiert erst ab M3 (siehe DECISIONS.md).
bool blocksForAge({required bool requiresAge18, required bool isAdult}) {
  return requiresAge18 && !isAdult;
}
