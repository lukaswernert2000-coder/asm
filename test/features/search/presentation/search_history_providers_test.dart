import 'package:asm/core/storage/shared_preferences_provider.dart';
import 'package:asm/features/search/presentation/search_history_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../helpers/fake_shared_preferences.dart';

void main() {
  group('searchHistoryProvider', () {
    test(
      'faellt ohne gespeicherten Wert auf eine leere Liste zurueck',
      () async {
        final container = ProviderContainer(
          overrides: [
            sharedPreferencesProvider.overrideWithValue(
              await fakeSharedPreferences(),
            ),
          ],
        );
        addTearDown(container.dispose);

        expect(container.read(searchHistoryProvider), isEmpty);
      },
    );

    test(
      'liest eine gespeicherte Liste in gespeicherter Reihenfolge',
      () async {
        final container = ProviderContainer(
          overrides: [
            sharedPreferencesProvider.overrideWithValue(
              await fakeSharedPreferences(
                searchHistory: ['pistole', 'aeg', 'weste'],
              ),
            ),
          ],
        );
        addTearDown(container.dispose);

        expect(container.read(searchHistoryProvider), [
          'pistole',
          'aeg',
          'weste',
        ]);
      },
    );

    // addSearchHistoryEntry()/removeSearchHistoryEntry() nehmen ein WidgetRef
    // (gleiches Muster wie setListingViewMode/markOnboardingSeen) -- ueber
    // die echte SearchScreen-UI getestet, nicht isoliert mit einem
    // konstruierten Ref.
  });
}
