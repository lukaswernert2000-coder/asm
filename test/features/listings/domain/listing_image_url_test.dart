import 'package:asm/features/listings/domain/listing_image_url.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('baut die oeffentliche Storage-URL aus Basis-URL und Pfad', () {
    final url = listingImageUrl(
      supabaseUrl: 'https://xyz.supabase.co',
      path: 'u1/l1/photo_a.jpg',
    );

    expect(
      url,
      'https://xyz.supabase.co/storage/v1/object/public/listing-images/u1/l1/photo_a.jpg',
    );
  });

  test('liefert null fuer einen leeren Pfad', () {
    expect(
      listingImageUrl(supabaseUrl: 'https://xyz.supabase.co', path: null),
      isNull,
    );
    expect(
      listingImageUrl(supabaseUrl: 'https://xyz.supabase.co', path: ''),
      isNull,
    );
  });
}
