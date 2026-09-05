/// Liest die Konversations-ID aus dem `data`-Payload einer FCM-Nachricht
/// (siehe `supabase/functions/notify-on-message/index.ts` fuer das Format).
String? conversationIdFromPushData(Map<String, dynamic> data) =>
    data['conversationId'] as String?;

/// Ob eine eingehende Push-Nachricht als lokale Systembenachrichtigung
/// unterdrueckt werden soll, weil die betroffene Konversation gerade auf der
/// Chat-Detailseite offen ist (Task 6.3: "Keine Push, wenn der Empfaenger
/// den Chat gerade offen hat").
bool shouldSuppressPushForOpenChat({
  required Map<String, dynamic> data,
  required String? openConversationId,
}) {
  if (openConversationId == null) return false;
  return conversationIdFromPushData(data) == openConversationId;
}
