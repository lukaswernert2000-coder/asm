import 'dart:io';

import 'package:asm/core/errors/app_exception.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Uebersetzt rohe Supabase-/Netzwerk-Exceptions in [AppException]s. Kein
/// rohes Supabase-Exception-Objekt darf je die UI erreichen.
AppException mapError(Object error) {
  return switch (error) {
    PostgrestException() => _mapPostgrestException(error),
    AuthException() => _mapAuthException(error),
    StorageException() => _mapStorageException(error),
    SocketException() => const NetworkException(),
    AppException() => error,
    _ => const UnknownException(),
  };
}

AppException _mapPostgrestException(PostgrestException error) {
  return switch (error.code) {
    'PGRST116' => const NotFoundException(),
    '42501' || 'PGRST301' => const AuthRequiredException(),
    '23514' || '23505' => ValidationException(error.message),
    _ => const UnknownException(),
  };
}

AppException _mapAuthException(AuthException error) {
  if (error.statusCode == '401' || error.code == 'session_not_found') {
    return const AuthRequiredException();
  }
  return ValidationException(error.message);
}

AppException _mapStorageException(StorageException error) {
  return switch (error.statusCode) {
    '404' => const NotFoundException(),
    '401' || '403' => const AuthRequiredException(),
    _ => const UnknownException(),
  };
}
