import 'dart:convert';

import 'package:asm/core/storage/shared_preferences_provider.dart';
import 'package:asm/features/listings/domain/create_listing_draft.dart';
import 'package:asm/features/listings/presentation/create_listing_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shared_preferences_platform_interface/in_memory_shared_preferences_async.dart';
import 'package:shared_preferences_platform_interface/shared_preferences_async_platform_interface.dart';

void main() {
  group('createListingDraftProvider', () {
    test(
      'faellt ohne gespeicherten Wert auf einen leeren Entwurf zurueck',
      () async {
        SharedPreferencesAsyncPlatform.instance =
            InMemorySharedPreferencesAsync.withData({});
        final prefs = await SharedPreferencesWithCache.create(
          cacheOptions: const SharedPreferencesWithCacheOptions(
            allowList: {createListingDraftPrefsKey},
          ),
        );
        final container = ProviderContainer(
          overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
        );
        addTearDown(container.dispose);

        expect(
          container.read(createListingDraftProvider),
          const CreateListingDraft(),
        );
      },
    );

    test('liest einen gespeicherten Entwurf aus JSON', () async {
      const stored = CreateListingDraft(
        step: 2,
        categoryId: 'c1',
        title: 'Titel',
      );
      SharedPreferencesAsyncPlatform.instance =
          InMemorySharedPreferencesAsync.withData({
            createListingDraftPrefsKey: jsonEncode(stored.toJson()),
          });
      final prefs = await SharedPreferencesWithCache.create(
        cacheOptions: const SharedPreferencesWithCacheOptions(
          allowList: {createListingDraftPrefsKey},
        ),
      );
      final container = ProviderContainer(
        overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
      );
      addTearDown(container.dispose);

      expect(container.read(createListingDraftProvider), stored);
    });

    // updateCreateListingDraft()/clearCreateListingDraft() nehmen ein
    // WidgetRef (gleiches Muster wie addSearchHistoryEntry) -- ueber die
    // echten Schritt-Screens getestet, nicht isoliert mit einem
    // konstruierten Ref.
  });
}
