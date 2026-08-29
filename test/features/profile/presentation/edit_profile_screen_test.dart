import 'dart:typed_data';

import 'package:asm/core/widgets/asm_checkbox.dart';
import 'package:asm/core/widgets/asm_text_field.dart';
import 'package:asm/features/auth/data/auth_repository.dart';
import 'package:asm/features/auth/domain/asm_user.dart';
import 'package:asm/features/auth/presentation/auth_controller.dart';
import 'package:asm/features/profile/data/profile_repository.dart';
import 'package:asm/features/profile/domain/profile.dart';
import 'package:asm/features/profile/presentation/edit_profile_screen.dart';
import 'package:asm/features/profile/presentation/profile_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockAuthRepository extends Mock implements AuthRepository {}

class MockProfileRepository extends Mock implements ProfileRepository {}

// AsmCheckbox toggelt bewusst nur ueber die Box selbst, nicht ueber das
// Label (siehe asm_checkbox.dart) -- ein Tap auf den Labeltext waere ein
// no-op. Gleiches Finder-Muster wie in register_screen_test.dart.
final Finder _commercialToggle = find.descendant(
  of: find.byType(AsmCheckbox),
  matching: find.byType(GestureDetector),
);

// Ersetzt PlzLookup.resolve in Tests: das laedt echt assets/data/plz.json
// per rootBundle, was innerhalb von testWidgets an der FakeAsync-Zone der
// Testbindung haengen bleibt (siehe edit_profile_screen.dart).
Future<({String city, double lat, double lng})?> _fakeResolvePlz(
  String plz,
) async {
  const known = {'76133': (city: 'Karlsruhe', lat: 49.0093, lng: 8.3858)};
  return known[plz];
}

// AsmTextField zeigt sein Label als eigenen Text ueber dem Feld, nicht als
// Decoration des inneren TextField -- find.widgetWithText(TextField, label)
// faende deshalb nichts. Gleiches Finder-Muster wie in register_screen_test.dart.
Finder _fieldFor(String label) => find.descendant(
  of: find.widgetWithText(AsmTextField, label),
  matching: find.byType(TextField),
);

void main() {
  late MockAuthRepository authRepository;
  late MockProfileRepository profileRepository;

  const user = AsmUser(id: 'u1', email: 'a@b.de', emailConfirmed: true);
  final profile = Profile(
    id: 'u1',
    username: 'gear_hunter_42',
    isCommercial: false,
    role: UserRole.user,
    createdAt: DateTime(2026),
    lastSeenAt: DateTime(2026, 8, 29),
    displayName: 'Max',
    bio: 'Sammle G36-Teile',
    postalCode: '76133',
    city: 'Karlsruhe',
  );

  setUp(() {
    authRepository = MockAuthRepository();
    profileRepository = MockProfileRepository();
    when(() => authRepository.authStateChanges())
        .thenAnswer((_) => Stream.value(user));
    when(() => profileRepository.current()).thenAnswer((_) async => profile);
    when(
      () => profileRepository.update(any(), any()),
    ).thenAnswer((_) async {});
  });

  Future<void> pumpScreen(
    WidgetTester tester, {
    Future<Uint8List?> Function()? pickAvatar,
  }) async {
    tester.view.physicalSize = const Size(400, 2400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final container = ProviderContainer(
      overrides: [
        authRepositoryProvider.overrideWithValue(authRepository),
        profileRepositoryProvider.overrideWithValue(profileRepository),
      ],
    );
    addTearDown(container.dispose);
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp(
          home: EditProfileScreen(
            pickAvatar: pickAvatar ?? () async => null,
            resolvePlz: _fakeResolvePlz,
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('fuellt Anzeigename, Bio und PLZ mit den aktuellen Werten vor', (
    tester,
  ) async {
    await pumpScreen(tester);

    expect(find.text('Max'), findsOneWidget);
    expect(find.text('Sammle G36-Teile'), findsOneWidget);
    expect(find.text('76133'), findsOneWidget);
    expect(find.text('Karlsruhe'), findsOneWidget);
  });

  testWidgets(
    'gewerblich-Schalter zeigt Firmenname- und Adressfeld erst nach dem Einschalten',
    (tester) async {
      await pumpScreen(tester);

      expect(find.widgetWithText(AsmTextField, 'Firmenname'), findsNothing);

      await tester.tap(_commercialToggle);
      await tester.pumpAndSettle();

      expect(find.widgetWithText(AsmTextField, 'Firmenname'), findsOneWidget);
      expect(find.textContaining('nicht öffentlich angezeigt'), findsOneWidget);
    },
  );

  testWidgets(
    'Speichern ohne Firmenname bei eingeschaltetem Schalter zeigt einen Fehler',
    (
      tester,
    ) async {
      await pumpScreen(tester);
      await tester.tap(_commercialToggle);
      await tester.pumpAndSettle();

      await tester.tap(find.text('Speichern'));
      await tester.pumpAndSettle();

      expect(find.text('Pflichtfeld für gewerbliche Verkäufer'), findsWidgets);
      verifyNever(() => profileRepository.update(any(), any()));
    },
  );

  testWidgets(
    'Speichern ruft update mit den bearbeiteten Werten auf und geht zurueck',
    (
      tester,
    ) async {
      await pumpScreen(tester);

      await tester.enterText(_fieldFor('Anzeigename'), 'Maximilian');
      await tester.tap(find.text('Speichern'));
      await tester.pumpAndSettle();

      final captured =
          verify(
                () => profileRepository.update('u1', captureAny()),
              ).captured.single
              as Map<String, dynamic>;
      expect(captured['display_name'], 'Maximilian');
      expect(captured['postal_code'], '76133');
      expect(captured['city'], 'Karlsruhe');
      expect(captured.containsKey('commercial_address'), isFalse);
    },
  );

  testWidgets(
    'neues Avatar-Bild wird hochgeladen und der Pfad mitgespeichert',
    (
      tester,
    ) async {
      // Echte, minimale 1x1-PNG-Bytes -- Image.memory() im Screen versucht sie
      // sofort zu dekodieren; Fantasie-Bytes wuerden einen echten (wenn auch
      // asynchronen) Dekodierfehler auf dem Image-Stream ausloesen.
      final bytes = Uint8List.fromList([
        137,
        80,
        78,
        71,
        13,
        10,
        26,
        10,
        0,
        0,
        0,
        13,
        73,
        72,
        68,
        82,
        0,
        0,
        0,
        1,
        0,
        0,
        0,
        1,
        8,
        6,
        0,
        0,
        0,
        31,
        21,
        196,
        137,
        0,
        0,
        0,
        10,
        73,
        68,
        65,
        84,
        120,
        156,
        99,
        0,
        1,
        0,
        0,
        5,
        0,
        1,
        13,
        10,
        45,
        180,
        0,
        0,
        0,
        0,
        73,
        69,
        78,
        68,
        174,
        66,
        96,
        130,
      ]);
      when(
        () => profileRepository.uploadAvatar('u1', bytes),
      ).thenAnswer((_) async => 'u1/avatar.jpg');

      await pumpScreen(tester, pickAvatar: () async => bytes);

      await tester.tap(find.text('Bild ändern'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Speichern'));
      await tester.pumpAndSettle();

      verify(() => profileRepository.uploadAvatar('u1', bytes)).called(1);
      final captured =
          verify(
                () => profileRepository.update('u1', captureAny()),
              ).captured.single
              as Map<String, dynamic>;
      expect(captured['avatar_path'], 'u1/avatar.jpg');
    },
  );
}
