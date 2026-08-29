import 'package:asm/core/supabase/supabase_provider.dart';
import 'package:asm/features/auth/presentation/auth_controller.dart';
import 'package:asm/features/profile/data/profile_repository.dart';
import 'package:asm/features/profile/domain/profile.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final profileRepositoryProvider = Provider<ProfileRepository>(
  (ref) => SupabaseProfileRepository(ref.watch(supabaseProvider)),
);

/// Null ohne Session. Beobachtet `authStateProvider`, damit nach einem
/// Nutzerwechsel (abmelden, als jemand anderes anmelden) neu geladen wird --
/// `current()` liest sonst weiter den zuerst geladenen Nutzer, weil
/// `SupabaseClient.auth.currentUser` selbst kein Riverpod-Zustand ist. Nach
/// dem Speichern im Bearbeiten-Screen muss der Aufrufer den Provider explizit
/// per `ref.invalidate` neu anstossen, ein Auth-Event allein reicht dafuer
/// nicht.
final currentProfileProvider = FutureProvider<Profile?>((ref) {
  ref.watch(authStateProvider);
  return ref.watch(profileRepositoryProvider).current();
});

final FutureProviderFamily<Profile, String> profileByIdProvider =
    FutureProvider.family<Profile, String>(
      (ref, id) => ref.watch(profileRepositoryProvider).byId(id),
    );
