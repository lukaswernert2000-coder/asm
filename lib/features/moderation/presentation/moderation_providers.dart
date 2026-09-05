import 'package:asm/core/supabase/supabase_provider.dart';
import 'package:asm/features/moderation/data/moderation_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final moderationRepositoryProvider = Provider<ModerationRepository>(
  (ref) => SupabaseModerationRepository(ref.watch(supabaseProvider)),
);

/// IDs der eigenen blockierten Nutzer (Task 7.1) -- fuer den
/// "Blockierte Nutzer"-Screen in den Einstellungen.
final blockedUserIdsProvider = FutureProvider<List<String>>(
  (ref) => ref.watch(moderationRepositoryProvider).blockedUserIds(),
);

/// Ob ICH den angefragten Nutzer blockiert habe -- sperrt das
/// Chat-Eingabefeld clientseitig (Task 7.1), siehe Kommentar auf
/// `isBlockedByMe`.
final FutureProviderFamily<bool, String> isBlockedByMeProvider =
    FutureProvider.family<bool, String>(
      (ref, userId) =>
          ref.watch(moderationRepositoryProvider).isBlockedByMe(userId),
    );
