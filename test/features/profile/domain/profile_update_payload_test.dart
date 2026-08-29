import 'package:asm/features/profile/domain/profile_update_payload.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const base = (
    displayName: 'Max',
    bio: 'Hallo',
    postalCode: '76133',
    city: 'Karlsruhe',
    lat: 49.0,
    lng: 8.4,
    isCommercial: false,
    commercialName: '',
    commercialAddressInput: '',
  );

  test('enthaelt die Basisfelder immer', () {
    final payload = buildProfileUpdatePayload(
      displayName: base.displayName,
      bio: base.bio,
      postalCode: base.postalCode,
      city: base.city,
      lat: base.lat,
      lng: base.lng,
      isCommercial: base.isCommercial,
      commercialName: base.commercialName,
      commercialAddressInput: base.commercialAddressInput,
    );

    expect(payload['display_name'], 'Max');
    expect(payload['bio'], 'Hallo');
    expect(payload['postal_code'], '76133');
    expect(payload['city'], 'Karlsruhe');
    expect(payload['lat'], 49.0);
    expect(payload['lng'], 8.4);
    expect(payload['is_commercial'], false);
  });

  test(
    'leerer Anzeigename/Bio wird als null gesendet, nicht als leerer String',
    () {
      final payload = buildProfileUpdatePayload(
        displayName: '',
        bio: '',
        postalCode: base.postalCode,
        city: base.city,
        lat: base.lat,
        lng: base.lng,
        isCommercial: base.isCommercial,
        commercialName: base.commercialName,
        commercialAddressInput: base.commercialAddressInput,
      );

      expect(payload['display_name'], isNull);
      expect(payload['bio'], isNull);
    },
  );

  test(
    'commercial_address fehlt komplett im Payload, wenn der Nutzer sie nicht angefasst hat '
    '(die Spalte ist nie lesbar -- ein gesendetes "" wuerde einen bestehenden Wert loeschen)',
    () {
      final payload = buildProfileUpdatePayload(
        displayName: base.displayName,
        bio: base.bio,
        postalCode: base.postalCode,
        city: base.city,
        lat: base.lat,
        lng: base.lng,
        isCommercial: true,
        commercialName: 'Air Deals GmbH',
        commercialAddressInput: '',
      );

      expect(payload.containsKey('commercial_address'), isFalse);
      expect(payload['commercial_name'], 'Air Deals GmbH');
      expect(payload['is_commercial'], true);
    },
  );

  test('commercial_address wird gesendet, wenn der Nutzer sie in dieser Sitzung eingegeben hat', () {
    final payload = buildProfileUpdatePayload(
      displayName: base.displayName,
      bio: base.bio,
      postalCode: base.postalCode,
      city: base.city,
      lat: base.lat,
      lng: base.lng,
      isCommercial: true,
      commercialName: 'Air Deals GmbH',
      commercialAddressInput: 'Musterstr. 1, 76133 Karlsruhe',
    );

    expect(payload['commercial_address'], 'Musterstr. 1, 76133 Karlsruhe');
  });

  test('commercial_name wird null, wenn gewerblich ausgeschaltet ist', () {
    final payload = buildProfileUpdatePayload(
      displayName: base.displayName,
      bio: base.bio,
      postalCode: base.postalCode,
      city: base.city,
      lat: base.lat,
      lng: base.lng,
      isCommercial: false,
      commercialName: 'Alter Name',
      commercialAddressInput: '',
    );

    expect(payload['commercial_name'], isNull);
  });

  test('avatar_path fehlt im Payload, wenn kein neues Bild gewaehlt wurde', () {
    final payload = buildProfileUpdatePayload(
      displayName: base.displayName,
      bio: base.bio,
      postalCode: base.postalCode,
      city: base.city,
      lat: base.lat,
      lng: base.lng,
      isCommercial: base.isCommercial,
      commercialName: base.commercialName,
      commercialAddressInput: base.commercialAddressInput,
    );

    expect(payload.containsKey('avatar_path'), isFalse);
  });

  test('avatar_path wird gesendet, wenn ein neues Bild hochgeladen wurde', () {
    final payload = buildProfileUpdatePayload(
      displayName: base.displayName,
      bio: base.bio,
      postalCode: base.postalCode,
      city: base.city,
      lat: base.lat,
      lng: base.lng,
      isCommercial: base.isCommercial,
      commercialName: base.commercialName,
      commercialAddressInput: base.commercialAddressInput,
      avatarPath: 'u1/avatar.jpg',
    );

    expect(payload['avatar_path'], 'u1/avatar.jpg');
  });
}
