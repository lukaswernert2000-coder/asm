/// Baut das Patch-Objekt fuer `ProfileRepository.update`. `commercialAddressInput`
/// ist, was der Nutzer in *dieser* Bearbeiten-Sitzung eingetippt hat -- die
/// Spalte hat keinen Select-Grant (siehe profile_repository.dart), ein
/// bestehender Wert kann also nie vorausgefuellt werden. Nur bei
/// tatsaechlicher Eingabe im Payload, sonst wuerde ein Speichern ohne
/// Beruehren des Felds den gespeicherten Wert loeschen.
Map<String, dynamic> buildProfileUpdatePayload({
  required String displayName,
  required String bio,
  required String postalCode,
  required String city,
  required double lat,
  required double lng,
  required bool isCommercial,
  required String commercialName,
  required String commercialAddressInput,
  String? avatarPath,
}) {
  final payload = <String, dynamic>{
    'display_name': displayName.isEmpty ? null : displayName,
    'bio': bio.isEmpty ? null : bio,
    'postal_code': postalCode,
    'city': city,
    'lat': lat,
    'lng': lng,
    'is_commercial': isCommercial,
    'commercial_name': isCommercial ? commercialName : null,
  };
  if (commercialAddressInput.isNotEmpty) {
    payload['commercial_address'] = commercialAddressInput;
  }
  if (avatarPath != null) {
    payload['avatar_path'] = avatarPath;
  }
  return payload;
}
