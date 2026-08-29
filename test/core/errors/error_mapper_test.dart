import 'package:asm/core/errors/app_exception.dart';
import 'package:asm/core/errors/error_mapper.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() {
  group('mapError - FunctionException', () {
    test('Status 401 wird zu AuthRequiredException', () {
      final error = mapError(const FunctionException(status: 401));
      expect(error, isA<AuthRequiredException>());
    });

    test('anderer Status wird zu UnknownException', () {
      final error = mapError(const FunctionException(status: 500));
      expect(error, isA<UnknownException>());
    });
  });
}
