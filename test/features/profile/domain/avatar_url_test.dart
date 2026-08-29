import 'package:asm/features/profile/domain/avatar_url.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('baut die oeffentliche Storage-URL aus Basis-URL und Pfad', () {
    final url = avatarUrl(
      supabaseUrl: 'https://xyz.supabase.co',
      path: 'u1/avatar.jpg',
    );

    expect(
      url,
      'https://xyz.supabase.co/storage/v1/object/public/avatars/u1/avatar.jpg',
    );
  });

  test('liefert null fuer einen leeren Pfad', () {
    expect(
      avatarUrl(supabaseUrl: 'https://xyz.supabase.co', path: null),
      isNull,
    );
    expect(avatarUrl(supabaseUrl: 'https://xyz.supabase.co', path: ''), isNull);
  });
}
