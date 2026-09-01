// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'message.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Message _$MessageFromJson(Map<String, dynamic> json) => _Message(
  id: json['id'] as String,
  conversationId: json['conversation_id'] as String,
  senderId: json['sender_id'] as String,
  createdAt: DateTime.parse(json['created_at'] as String),
  body: json['body'] as String?,
  imagePath: json['image_path'] as String?,
  readAt: json['read_at'] == null
      ? null
      : DateTime.parse(json['read_at'] as String),
);

Map<String, dynamic> _$MessageToJson(_Message instance) => <String, dynamic>{
  'id': instance.id,
  'conversation_id': instance.conversationId,
  'sender_id': instance.senderId,
  'created_at': instance.createdAt.toIso8601String(),
  'body': instance.body,
  'image_path': instance.imagePath,
  'read_at': instance.readAt?.toIso8601String(),
};
