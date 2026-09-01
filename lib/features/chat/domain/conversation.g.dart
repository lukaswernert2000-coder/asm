// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'conversation.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Conversation _$ConversationFromJson(Map<String, dynamic> json) =>
    _Conversation(
      id: json['id'] as String,
      listingId: json['listing_id'] as String,
      buyerId: json['buyer_id'] as String,
      sellerId: json['seller_id'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      lastMessageAt: json['last_message_at'] == null
          ? null
          : DateTime.parse(json['last_message_at'] as String),
      lastMessageBody: json['last_message_body'] as String?,
      lastMessageSenderId: json['last_message_sender_id'] as String?,
    );

Map<String, dynamic> _$ConversationToJson(_Conversation instance) =>
    <String, dynamic>{
      'id': instance.id,
      'listing_id': instance.listingId,
      'buyer_id': instance.buyerId,
      'seller_id': instance.sellerId,
      'created_at': instance.createdAt.toIso8601String(),
      'last_message_at': instance.lastMessageAt?.toIso8601String(),
      'last_message_body': instance.lastMessageBody,
      'last_message_sender_id': instance.lastMessageSenderId,
    };
