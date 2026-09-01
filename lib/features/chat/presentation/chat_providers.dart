import 'dart:convert';

import 'package:asm/core/errors/app_exception.dart';
import 'package:asm/core/storage/shared_preferences_provider.dart';
import 'package:asm/core/supabase/supabase_provider.dart';
import 'package:asm/features/auth/presentation/auth_controller.dart';
import 'package:asm/features/chat/data/chat_repository.dart';
import 'package:asm/features/chat/domain/conversation.dart';
import 'package:asm/features/chat/domain/message.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final chatRepositoryProvider = Provider<ChatRepository>(
  (ref) => SupabaseChatRepository(ref.watch(supabaseProvider)),
);

/// Alle Konversationen der eingeloggten Person, neueste zuerst -- fuer die
/// Chatliste (Task 6.2). Bewusst ein Realtime-`StreamProvider`, kein
/// `FutureProvider` mit manuellem `ref.invalidate()`: Ein neu angelegtes
/// `getOrCreateConversation()` bzw. eine per `send()` aktualisierte
/// `last_message_at` kamen bei einer bereits aufgebauten, aber gerade nicht
/// sichtbaren Chatliste (Tab im Hintergrund der `StatefulShellRoute`) beim
/// Live-Testen von Task 6.2 nicht zuverlaessig durch ein Invalidieren an --
/// nur ein kompletter Neustart der App zeigte danach den korrekten Stand.
/// Ein Realtime-Stream (wie `conversationMessagesProvider`, das im selben
/// Test immer zuverlaessig aktualisierte) umgeht das Problem, statt es zu
/// verstehen -- siehe DECISIONS.md.
final conversationsProvider = StreamProvider<List<Conversation>>(
  (ref) => ref.watch(chatRepositoryProvider).conversations(),
);

final FutureProviderFamily<Conversation, String> conversationByIdProvider =
    FutureProvider.family<Conversation, String>(
      (ref, id) => ref.watch(chatRepositoryProvider).byId(id),
    );

/// Realtime-Nachrichtenstrom einer Konversation -- von der Chatliste (letzte
/// Nachricht + Ungelesen-Punkt) und der Chat-Detailseite (Bubble-Liste)
/// gemeinsam genutzt. Derselbe `StreamProvider`-Schluessel haelt beide
/// Verbraucher an ein- und demselben Supabase-Realtime-Kanal, statt ihn
/// doppelt zu oeffnen.
final StreamProviderFamily<List<Message>, String> conversationMessagesProvider =
    StreamProvider.family<List<Message>, String>(
      (ref, conversationId) =>
          ref.watch(chatRepositoryProvider).messages(conversationId),
    );

/// Wer der eingeloggten Person in [conversation] gegenuebersteht.
String otherUserId(Conversation conversation, String currentUserId) =>
    conversation.buyerId == currentUserId
    ? conversation.sellerId
    : conversation.buyerId;

/// Ob [messages] aus Sicht von [currentUserId] ungelesene Nachrichten
/// enthaelt -- eine fremde Nachricht ohne `readAt`.
bool hasUnread(List<Message> messages, String currentUserId) => messages.any(
  (m) => m.senderId != currentUserId && m.readAt == null,
);

/// Ob irgendeine sichtbare Konversation ungelesene Nachrichten hat -- fuer
/// den Ungelesen-Punkt in der BottomNav (Task 6.2). Nutzt bewusst
/// [visibleConversationsProvider] statt der rohen Liste: ein per
/// "Chat löschen" ausgeblendeter Chat mit einer zum Loeschzeitpunkt schon
/// ungelesenen Nachricht soll den Punkt nicht mehr triggern. Haengt an
/// denselben [conversationMessagesProvider]-Streams, die die Chatliste
/// ohnehin offen haelt, sobald sie sichtbar ist oder war (Riverpod cached
/// pro Schluessel).
final Provider<bool> hasUnreadConversationsProvider = Provider<bool>((ref) {
  final currentUserId = ref.watch(currentUserProvider)?.id;
  if (currentUserId == null) return false;
  final conversations =
      ref.watch(visibleConversationsProvider).valueOrNull ?? [];
  for (final conversation in conversations) {
    final messages =
        ref.watch(conversationMessagesProvider(conversation.id)).valueOrNull ??
        [];
    if (hasUnread(messages, currentUserId)) return true;
  }
  return false;
});

/// Eine getippte, aber noch nicht bestaetigte Nachricht -- rein lokaler
/// UI-Zustand fuer optimistisches Senden (Task 6.2), nie persistiert.
class PendingMessage {
  PendingMessage({required this.localId, required this.body}) : failed = false;

  PendingMessage._({
    required this.localId,
    required this.body,
    required this.failed,
  });

  final String localId;
  final String body;
  final bool failed;

  PendingMessage copyWith({bool? failed}) => PendingMessage._(
    localId: localId,
    body: body,
    failed: failed ?? this.failed,
  );
}

/// Haelt Nachrichten, die gerade gesendet werden oder fehlgeschlagen sind,
/// bis der echte Realtime-Stream sie bestaetigt (dann werden sie entfernt).
/// Kein `AsyncNotifier`: der Zustand ist rein lokal, keine Netzwerkantwort
/// wird direkt gespiegelt (anders als `FavoriteNotifier`).
class PendingMessagesNotifier
    extends FamilyNotifier<List<PendingMessage>, String> {
  @override
  List<PendingMessage> build(String arg) => [];

  Future<void> send(String body) async {
    final pending = PendingMessage(
      localId: DateTime.now().microsecondsSinceEpoch.toString(),
      body: body,
    );
    state = [...state, pending];
    await _attempt(pending);
  }

  Future<void> retry(String localId) async {
    final pending = state.where((m) => m.localId == localId).firstOrNull;
    if (pending == null) return;
    state = [
      for (final m in state)
        if (m.localId == localId) m.copyWith(failed: false) else m,
    ];
    await _attempt(pending);
  }

  Future<void> _attempt(PendingMessage pending) async {
    try {
      await ref.read(chatRepositoryProvider).send(arg, pending.body);
      state = state.where((m) => m.localId != pending.localId).toList();
    } on AppException {
      state = [
        for (final m in state)
          if (m.localId == pending.localId) m.copyWith(failed: true) else m,
      ];
    }
  }
}

final NotifierProviderFamily<
  PendingMessagesNotifier,
  List<PendingMessage>,
  String
>
pendingMessagesProvider =
    NotifierProvider.family<
      PendingMessagesNotifier,
      List<PendingMessage>,
      String
    >(
      PendingMessagesNotifier.new,
    );

const hiddenConversationsPrefsKey = 'hidden_conversation_ids';

/// "Chat löschen" (Task 6.2) ist ein rein lokales Ausblenden, kein
/// echtes Loeschen: `conversations`/`messages` haben in `0005_chat.sql`
/// bewusst keine Delete-Policy (ein Loeschen wuerde der Gegenseite ihren
/// Chatverlauf mit wegnehmen, RLS erlaubt das nicht). Merkt sich stattdessen
/// den Zeitpunkt des Loeschens pro Konversation -- taucht die Konversation
/// danach durch eine neue Nachricht wieder auf, erscheint sie automatisch
/// wieder in der Liste (siehe `visibleConversationsProvider`), statt fuer
/// immer zu verschwinden.
class HiddenConversationsNotifier extends Notifier<Map<String, DateTime>> {
  @override
  Map<String, DateTime> build() {
    final raw = ref
        .watch(sharedPreferencesProvider)
        .getString(hiddenConversationsPrefsKey);
    if (raw == null) return {};
    final decoded = jsonDecode(raw) as Map<String, dynamic>;
    return decoded.map(
      (key, value) => MapEntry(key, DateTime.parse(value as String)),
    );
  }

  Future<void> hide(String conversationId) async {
    final next = {...state, conversationId: DateTime.now().toUtc()};
    state = next;
    await ref
        .read(sharedPreferencesProvider)
        .setString(
          hiddenConversationsPrefsKey,
          jsonEncode(
            next.map((key, value) => MapEntry(key, value.toIso8601String())),
          ),
        );
  }
}

final NotifierProvider<HiddenConversationsNotifier, Map<String, DateTime>>
hiddenConversationIdsProvider =
    NotifierProvider<HiddenConversationsNotifier, Map<String, DateTime>>(
      HiddenConversationsNotifier.new,
    );

/// [conversationsProvider], abzueglich per "Chat löschen" ausgeblendeter
/// Konversationen ohne neuere Aktivitaet seitdem -- fuer die Chatliste.
final Provider<AsyncValue<List<Conversation>>> visibleConversationsProvider =
    Provider<AsyncValue<List<Conversation>>>((ref) {
      final hidden = ref.watch(hiddenConversationIdsProvider);
      return ref
          .watch(conversationsProvider)
          .whenData(
            (conversations) => conversations.where((c) {
              final hiddenAt = hidden[c.id];
              if (hiddenAt == null) return true;
              final lastActivity = c.lastMessageAt ?? c.createdAt;
              return lastActivity.isAfter(hiddenAt);
            }).toList(),
          );
    });
