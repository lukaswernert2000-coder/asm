import 'package:asm/core/storage/shared_preferences_provider.dart';
import 'package:asm/core/supabase/supabase_provider.dart';
import 'package:asm/features/notifications/data/device_token_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final deviceTokenRepositoryProvider = Provider<DeviceTokenRepository>(
  (ref) => SupabaseDeviceTokenRepository(ref.watch(supabaseProvider)),
);

/// Welche Konversation gerade auf der Chat-Detailseite offen ist (Task 6.3).
/// `ChatDetailScreen` setzt/loescht das ueber App-Vordergrund/Hintergrund
/// hinweg -- genutzt, um eine eingehende Push-Nachricht fuer genau diese
/// Konversation zu unterdruecken, siehe `push_message.dart`.
class OpenConversationNotifier extends Notifier<String?> {
  @override
  String? build() => null;

  String? get open => state;

  set open(String conversationId) => state = conversationId;

  void clear() => state = null;
}

final NotifierProvider<OpenConversationNotifier, String?>
openConversationIdProvider =
    NotifierProvider<OpenConversationNotifier, String?>(
      OpenConversationNotifier.new,
    );

const hasRequestedNotificationPermissionPrefsKey =
    'has_requested_notification_permission';

/// Ob die Push-Berechtigung schon einmal angefragt wurde -- die Anfrage soll
/// **kontextbezogen** nur beim allerersten gesendeten Chat, nicht bei jeder
/// weiteren Nachricht ausgeloest werden (Task 6.3).
final Provider<bool> hasRequestedNotificationPermissionProvider =
    Provider<bool>((ref) {
      return ref
              .watch(sharedPreferencesProvider)
              .getBool(hasRequestedNotificationPermissionPrefsKey) ??
          false;
    });

Future<void> markNotificationPermissionRequested(WidgetRef ref) async {
  await ref
      .read(sharedPreferencesProvider)
      .setBool(hasRequestedNotificationPermissionPrefsKey, true);
  ref.invalidate(hasRequestedNotificationPermissionProvider);
}
