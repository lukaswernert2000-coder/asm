/// Baut die oeffentliche Storage-URL fuer ein Avatar-Bild. Reine Funktion
/// (Basis-URL als Parameter statt `AppConfig` direkt zu lesen), damit sie
/// ohne `--dart-define` testbar ist. `avatars` ist ein oeffentlicher Bucket
/// (0006_storage.sql), das Format entspricht `storage.from(...).getPublicUrl(...)`.
String? avatarUrl({required String supabaseUrl, required String? path}) {
  if (path == null || path.isEmpty) return null;
  return '$supabaseUrl/storage/v1/object/public/avatars/$path';
}
