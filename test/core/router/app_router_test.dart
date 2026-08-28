import 'package:asm/core/router/routes.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('Detailroute enthaelt die Inserats-ID', () {
    expect(AsmRoutes.listing('abc-123'), '/listing/abc-123');
  });

  test('Kategorieroute nutzt den Slug', () {
    expect(AsmRoutes.category('langwaffen-saeg'), '/category/langwaffen-saeg');
  });
}
