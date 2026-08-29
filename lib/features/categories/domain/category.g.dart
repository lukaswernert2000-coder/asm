// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'category.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Category _$CategoryFromJson(Map<String, dynamic> json) => _Category(
  id: json['id'] as String,
  slug: json['slug'] as String,
  name: json['name'] as String,
  sortOrder: (json['sort_order'] as num).toInt(),
  requiresAge18: json['requires_age_18'] as bool,
  requiresFMarking: json['requires_f_marking'] as bool,
  requiresJoule: json['requires_joule'] as bool,
  requiresPropulsion: json['requires_propulsion'] as bool,
  isActive: json['is_active'] as bool,
  parentId: json['parent_id'] as String?,
  icon: json['icon'] as String?,
);

Map<String, dynamic> _$CategoryToJson(_Category instance) => <String, dynamic>{
  'id': instance.id,
  'slug': instance.slug,
  'name': instance.name,
  'sort_order': instance.sortOrder,
  'requires_age_18': instance.requiresAge18,
  'requires_f_marking': instance.requiresFMarking,
  'requires_joule': instance.requiresJoule,
  'requires_propulsion': instance.requiresPropulsion,
  'is_active': instance.isActive,
  'parent_id': instance.parentId,
  'icon': instance.icon,
};
