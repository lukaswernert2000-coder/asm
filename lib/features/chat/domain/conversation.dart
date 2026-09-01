import 'package:freezed_annotation/freezed_annotation.dart';

part 'conversation.freezed.dart';
part 'conversation.g.dart';

@freezed
abstract class Conversation with _$Conversation {
  const factory Conversation({
    required String id,
    required String listingId,
    required String buyerId,
    required String sellerId,
    required DateTime createdAt,
    DateTime? lastMessageAt,
    String? lastMessageBody,
    String? lastMessageSenderId,
  }) = _Conversation;

  factory Conversation.fromJson(Map<String, dynamic> json) =>
      _$ConversationFromJson(json);
}
