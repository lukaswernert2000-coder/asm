import 'package:asm/core/supabase/supabase_provider.dart';
import 'package:asm/features/chat/data/chat_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final chatRepositoryProvider = Provider<ChatRepository>(
  (ref) => SupabaseChatRepository(ref.watch(supabaseProvider)),
);
