import 'package:asm/core/utils/formatters.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('price formatiert deutsch mit Euro-Zeichen', () {
    expect(Formatters.price(125000), '1.250,00 €');
    expect(Formatters.price(0), '0,00 €');
  });

  test('distance rundet sinnvoll', () {
    expect(Formatters.distance(0.4), '<1 km');
    expect(Formatters.distance(12.34), '12 km');
    expect(Formatters.distance(148.9), '149 km');
  });

  test('relativeTime nutzt deutsche Kurzformen', () {
    final now = DateTime(2026, 8, 28, 12);
    expect(
      Formatters.relativeTime(
        now.subtract(const Duration(minutes: 5)),
        now: now,
      ),
      'vor 5 Min.',
    );
    expect(
      Formatters.relativeTime(now.subtract(const Duration(hours: 3)), now: now),
      'vor 3 Std.',
    );
    expect(
      Formatters.relativeTime(now.subtract(const Duration(days: 2)), now: now),
      'vor 2 Tagen',
    );
  });

  test('date formatiert als TT.MM.JJJJ mit fuehrenden Nullen', () {
    expect(Formatters.date(DateTime(2012, 3, 7)), '07.03.2012');
    expect(Formatters.date(DateTime(2026, 12, 25)), '25.12.2026');
  });
}
