import 'package:asm/core/supabase/supabase_provider.dart';
import 'package:asm/features/moderation/data/moderation_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final moderationRepositoryProvider = Provider<ModerationRepository>(
  (ref) => SupabaseModerationRepository(ref.watch(supabaseProvider)),
);
