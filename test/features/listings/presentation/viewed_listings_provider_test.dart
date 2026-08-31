import 'package:asm/features/listings/presentation/viewed_listings_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('markViewed liefert true beim ersten Aufruf fuer eine ID', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);
    final notifier = container.read(viewedListingsProvider.notifier);

    expect(notifier.markViewed('l1'), isTrue);
  });

  test('markViewed liefert false bei einem zweiten Aufruf fuer dieselbe ID', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);
    final notifier = container.read(viewedListingsProvider.notifier)
      ..markViewed('l1');

    expect(notifier.markViewed('l1'), isFalse);
  });

  test('markViewed liefert true fuer eine andere ID', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);
    final notifier = container.read(viewedListingsProvider.notifier)
      ..markViewed('l1');

    expect(notifier.markViewed('l2'), isTrue);
  });
}
