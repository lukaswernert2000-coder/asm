import 'dart:convert';

import 'package:asm/core/storage/shared_preferences_provider.dart';
import 'package:asm/features/listings/domain/create_listing_draft.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

const createListingDraftPrefsKey = 'create_listing_draft';

/// Lokaler Entwurf des Erstellen-Flows (Task 4.2), nach jedem Schritt
/// persistiert -- ein App-Absturz darf keine Arbeit vernichten. Gleiches
/// Muster wie `searchHistoryProvider`: ein reiner Lese-Provider plus eine
/// freie Funktion, die schreibt und ihn invalidiert.
final createListingDraftProvider = Provider<CreateListingDraft>((ref) {
  final json = ref
      .watch(sharedPreferencesProvider)
      .getString(createListingDraftPrefsKey);
  if (json == null) return const CreateListingDraft();
  return CreateListingDraft.fromJson(
    jsonDecode(json) as Map<String, dynamic>,
  );
});

Future<void> updateCreateListingDraft(
  WidgetRef ref,
  CreateListingDraft Function(CreateListingDraft current) update,
) async {
  final next = update(ref.read(createListingDraftProvider));
  await ref
      .read(sharedPreferencesProvider)
      .setString(createListingDraftPrefsKey, jsonEncode(next.toJson()));
  ref.invalidate(createListingDraftProvider);
}

/// Nach erfolgreichem Veroeffentlichen oder auf Nutzerwunsch verwerfen.
Future<void> clearCreateListingDraft(WidgetRef ref) async {
  await ref.read(sharedPreferencesProvider).remove(createListingDraftPrefsKey);
  ref.invalidate(createListingDraftProvider);
}
