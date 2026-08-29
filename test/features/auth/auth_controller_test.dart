import 'dart:async';

import 'package:asm/features/auth/data/auth_repository.dart';
import 'package:asm/features/auth/domain/asm_user.dart';
import 'package:asm/features/auth/presentation/auth_controller.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockAuthRepository extends Mock implements AuthRepository {}

void main() {
  late MockAuthRepository repository;
  late StreamController<AsmUser?> authChanges;
  late ProviderContainer container;

  setUp(() {
    repository = MockAuthRepository();
    authChanges = StreamController<AsmUser?>.broadcast();
    when(
      () => repository.authStateChanges(),
    ).thenAnswer((_) => authChanges.stream);
    container = ProviderContainer(
      overrides: [authRepositoryProvider.overrideWithValue(repository)],
    );
    addTearDown(container.dispose);
    addTearDown(authChanges.close);
  });

  test('authStateProvider liefert null ohne Session', () async {
    final sub = container.listen(authStateProvider, (_, _) {});

    authChanges.add(null);
    await Future<void>.delayed(Duration.zero);

    expect(sub.read().valueOrNull, isNull);
  });

  test('authStateProvider liefert AsmUser mit Session', () async {
    const user = AsmUser(id: 'u1', email: 'a@b.de', emailConfirmed: true);
    final sub = container.listen(authStateProvider, (_, _) {});

    authChanges.add(user);
    await Future<void>.delayed(Duration.zero);

    expect(sub.read().valueOrNull, user);
  });

  test('nach signOut ist der State wieder null', () async {
    const user = AsmUser(id: 'u1', email: 'a@b.de', emailConfirmed: true);
    final sub = container.listen(authStateProvider, (_, _) {});

    authChanges.add(user);
    await Future<void>.delayed(Duration.zero);
    expect(sub.read().valueOrNull, user);

    authChanges.add(null);
    await Future<void>.delayed(Duration.zero);

    expect(sub.read().valueOrNull, isNull);
  });
}
