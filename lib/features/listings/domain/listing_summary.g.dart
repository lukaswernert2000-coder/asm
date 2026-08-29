// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'listing_summary.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_ListingSummary _$ListingSummaryFromJson(Map<String, dynamic> json) =>
    _ListingSummary(
      id: json['id'] as String,
      title: json['title'] as String,
      priceCents: (json['price_cents'] as num).toInt(),
      negotiable: json['negotiable'] as bool,
      condition: $enumDecode(_$ListingConditionEnumMap, json['condition']),
      status: $enumDecode(_$ListingStatusEnumMap, json['status']),
      city: json['city'] as String,
      postalCode: json['postal_code'] as String,
      hasFMarking: json['has_f_marking'] as bool,
      ships: json['ships'] as bool,
      bumpedAt: DateTime.parse(json['bumped_at'] as String),
      sellerId: json['seller_id'] as String,
      categorySlug: json['category_slug'] as String,
      joule: (json['joule'] as num?)?.toDouble(),
      coverPath: json['cover_path'] as String?,
      distanceKm: (json['distance_km'] as num?)?.toDouble(),
    );

Map<String, dynamic> _$ListingSummaryToJson(_ListingSummary instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'price_cents': instance.priceCents,
      'negotiable': instance.negotiable,
      'condition': _$ListingConditionEnumMap[instance.condition]!,
      'status': _$ListingStatusEnumMap[instance.status]!,
      'city': instance.city,
      'postal_code': instance.postalCode,
      'has_f_marking': instance.hasFMarking,
      'ships': instance.ships,
      'bumped_at': instance.bumpedAt.toIso8601String(),
      'seller_id': instance.sellerId,
      'category_slug': instance.categorySlug,
      'joule': instance.joule,
      'cover_path': instance.coverPath,
      'distance_km': instance.distanceKm,
    };

const _$ListingConditionEnumMap = {
  ListingCondition.neu: 'neu',
  ListingCondition.neuwertig: 'neuwertig',
  ListingCondition.gebraucht: 'gebraucht',
  ListingCondition.leichteDefekte: 'leichte_defekte',
  ListingCondition.defekt: 'defekt',
  ListingCondition.bastelobjekt: 'bastelobjekt',
};

const _$ListingStatusEnumMap = {
  ListingStatus.draft: 'draft',
  ListingStatus.active: 'active',
  ListingStatus.reserved: 'reserved',
  ListingStatus.sold: 'sold',
  ListingStatus.archived: 'archived',
  ListingStatus.blocked: 'blocked',
};
