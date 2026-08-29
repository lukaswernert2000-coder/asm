// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'profile.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Profile _$ProfileFromJson(Map<String, dynamic> json) => _Profile(
  id: json['id'] as String,
  username: json['username'] as String,
  isCommercial: json['is_commercial'] as bool,
  role: $enumDecode(_$UserRoleEnumMap, json['role']),
  createdAt: DateTime.parse(json['created_at'] as String),
  lastSeenAt: DateTime.parse(json['last_seen_at'] as String),
  displayName: json['display_name'] as String?,
  avatarPath: json['avatar_path'] as String?,
  bio: json['bio'] as String?,
  postalCode: json['postal_code'] as String?,
  city: json['city'] as String?,
  commercialName: json['commercial_name'] as String?,
);

Map<String, dynamic> _$ProfileToJson(_Profile instance) => <String, dynamic>{
  'id': instance.id,
  'username': instance.username,
  'is_commercial': instance.isCommercial,
  'role': _$UserRoleEnumMap[instance.role]!,
  'created_at': instance.createdAt.toIso8601String(),
  'last_seen_at': instance.lastSeenAt.toIso8601String(),
  'display_name': instance.displayName,
  'avatar_path': instance.avatarPath,
  'bio': instance.bio,
  'postal_code': instance.postalCode,
  'city': instance.city,
  'commercial_name': instance.commercialName,
};

const _$UserRoleEnumMap = {
  UserRole.user: 'user',
  UserRole.moderator: 'moderator',
};
