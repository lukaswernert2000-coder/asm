/// Baut die oeffentliche Storage-URL fuer ein Inserat-Bild. Reine Funktion,
/// analog zu `avatar_url.dart`. `listing-images` ist ein oeffentlicher Bucket
/// (0006_storage.sql), das Format entspricht `storage.from(...).getPublicUrl(...)`.
String? listingImageUrl({required String supabaseUrl, required String? path}) {
  if (path == null || path.isEmpty) return null;
  return '$supabaseUrl/storage/v1/object/public/listing-images/$path';
}
