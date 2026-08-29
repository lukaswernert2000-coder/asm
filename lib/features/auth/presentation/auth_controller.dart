import 'package:asm/core/supabase/supabase_provider.dart';
import 'package:asm/features/auth/data/auth_repository.dart';
import 'package:asm/features/auth/domain/asm_user.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final authRepositoryProvider = Provider<AuthRepository>(
  (ref) => SupabaseAuthRepository(ref.watch(supabaseProvider)),
);

final authStateProvider = StreamProvider<AsmUser?>((ref) {
  return ref.watch(authRepositoryProvider).authStateChanges();
});

final currentUserProvider = Provider<AsmUser?>((ref) {
  return ref.watch(authStateProvider).valueOrNull;
});

final isLoggedInProvider = Provider<bool>((ref) {
  return ref.watch(currentUserProvider) != null;
});

final isAdultProvider = FutureProvider<bool>((ref) async {
  if (ref.watch(currentUserProvider) == null) return false;
  return ref.watch(supabaseProvider).rpc<bool>('is_adult');
});
