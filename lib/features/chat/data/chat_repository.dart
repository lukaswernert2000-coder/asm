import 'package:asm/core/errors/app_exception.dart';
import 'package:asm/core/errors/error_mapper.dart';
import 'package:asm/features/chat/domain/conversation.dart';
import 'package:asm/features/chat/domain/message.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

abstract interface class ChatRepository {
  Future<List<Conversation>> conversations();
  Stream<List<Message>> messages(String conversationId);
  Future<void> send(String conversationId, String body);
  Future<Conversation> getOrCreateConversation(String listingId);
  Future<void> markRead(String conversationId);
}

/// Liefert rohe Zeilen aus dem Realtime-Stream einer Konversation.
///
/// Eigener Seam statt `_client.from(...).stream(...)` direkt in
/// [SupabaseChatRepository] aufzurufen: `SupabaseStreamBuilder` ist genau wie
/// `PostgrestFilterBuilder` (siehe `listing_repository.dart`) mit mocktail
/// nicht sauber stubbar. Tests injizieren hier stattdessen einen simplen
/// Stream-Controller.
typedef MessageStreamCaller = Stream<List<Map<String, dynamic>>> Function(
  String conversationId,
);

class SupabaseChatRepository implements ChatRepository {
  SupabaseChatRepository(
    this._client, {
    MessageStreamCaller? messageStreamCaller,
  }) : _messageStream =
           messageStreamCaller ?? _defaultMessageStreamCaller(_client);

  final SupabaseClient _client;
  final MessageStreamCaller _messageStream;

  static MessageStreamCaller _defaultMessageStreamCaller(
    SupabaseClient client,
  ) =>
      (conversationId) => client
          .from('messages')
          .stream(primaryKey: ['id'])
          .eq('conversation_id', conversationId)
          .order('created_at');

  @override
  Future<List<Conversation>> conversations() async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) return const [];
    try {
      final rows = await _client
          .from('conversations')
          .select()
          .or('buyer_id.eq.$userId,seller_id.eq.$userId')
          .order('last_message_at', ascending: false);
      return rows.map(Conversation.fromJson).toList();
    } catch (error) {
      throw mapError(error);
    }
  }

  @override
  Stream<List<Message>> messages(String conversationId) {
    return _messageStream(
      conversationId,
    ).map((rows) => rows.map(Message.fromJson).toList());
  }

  @override
  Future<void> send(String conversationId, String body) async {
    final senderId = _client.auth.currentUser?.id;
    if (senderId == null) throw const AuthRequiredException();
    try {
      await _client.from('messages').insert({
        'conversation_id': conversationId,
        'sender_id': senderId,
        'body': body,
      });
    } catch (error) {
      throw mapError(error);
    }
  }

  @override
  Future<Conversation> getOrCreateConversation(String listingId) async {
    final buyerId = _client.auth.currentUser?.id;
    if (buyerId == null) throw const AuthRequiredException();
    try {
      final existing = await _client
          .from('conversations')
          .select()
          .eq('listing_id', listingId)
          .eq('buyer_id', buyerId)
          .maybeSingle();
      if (existing != null) return Conversation.fromJson(existing);

      final listing = await _client
          .from('listings')
          .select('seller_id')
          .eq('id', listingId)
          .single();
      final row = await _client
          .from('conversations')
          .insert({
            'listing_id': listingId,
            'buyer_id': buyerId,
            'seller_id': listing['seller_id'],
          })
          .select()
          .single();
      return Conversation.fromJson(row);
    } catch (error) {
      throw mapError(error);
    }
  }

  @override
  Future<void> markRead(String conversationId) async {
    try {
      await _client
          .from('messages')
          .update({'read_at': DateTime.now().toUtc().toIso8601String()})
          .eq('conversation_id', conversationId)
          .filter('read_at', 'is', null);
    } catch (error) {
      throw mapError(error);
    }
  }
}
