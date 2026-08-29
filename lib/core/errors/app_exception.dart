sealed class AppException implements Exception {
  const AppException(this.message);
  final String message;
}

final class NetworkException extends AppException {
  const NetworkException()
    : super('Keine Verbindung. Bitte prüfe dein Netzwerk.');
}

final class AuthRequiredException extends AppException {
  const AuthRequiredException() : super('Dafür musst du angemeldet sein.');
}

final class AgeRestrictedException extends AppException {
  const AgeRestrictedException()
    : super('Dieser Bereich ist erst ab 18 Jahren zugänglich.');
}

final class NotFoundException extends AppException {
  const NotFoundException() : super('Das Inserat existiert nicht mehr.');
}

final class ValidationException extends AppException {
  const ValidationException(super.message);
}

final class UnknownException extends AppException {
  const UnknownException([super.message = 'Etwas ist schiefgelaufen.']);
}
