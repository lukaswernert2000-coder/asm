import 'package:asm/core/storage/shared_preferences_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

const searchHistoryPrefsKey = 'search_history';
const searchHistoryMaxEntries = 10;

/// Letzte Suchbegriffe, neuester zuerst. Siehe 02-IMPLEMENTATION-PLAN.md
/// Task 3.3. Gleiches Muster wie `listingViewModeProvider`: ein reiner
/// Lese-Provider plus freie Funktionen, die schreiben und ihn invalidieren.
final Provider<List<String>> searchHistoryProvider = Provider<List<String>>((
  ref,
) {
  return ref
          .watch(sharedPreferencesProvider)
          .getStringList(
            searchHistoryPrefsKey,
          ) ??
      const [];
});

Future<void> addSearchHistoryEntry(WidgetRef ref, String query) async {
  final trimmed = query.trim();
  if (trimmed.isEmpty) return;
  final current = ref.read(searchHistoryProvider);
  final next = [
    trimmed,
    ...current.where((entry) => entry != trimmed),
  ].take(searchHistoryMaxEntries).toList();
  await ref
      .read(sharedPreferencesProvider)
      .setStringList(searchHistoryPrefsKey, next);
  ref.invalidate(searchHistoryProvider);
}

Future<void> removeSearchHistoryEntry(WidgetRef ref, String query) async {
  final current = ref.read(searchHistoryProvider);
  final next = current.where((entry) => entry != query).toList();
  await ref
      .read(sharedPreferencesProvider)
      .setStringList(searchHistoryPrefsKey, next);
  ref.invalidate(searchHistoryProvider);
}
