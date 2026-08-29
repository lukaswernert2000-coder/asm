// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'listing.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Listing _$ListingFromJson(Map<String, dynamic> json) => _Listing(
  id: json['id'] as String,
  sellerId: json['seller_id'] as String,
  categoryId: json['category_id'] as String,
  title: json['title'] as String,
  description: json['description'] as String,
  priceCents: (json['price_cents'] as num).toInt(),
  negotiable: json['negotiable'] as bool,
  isGiveaway: json['is_giveaway'] as bool,
  acceptsSwap: json['accepts_swap'] as bool,
  condition: $enumDecode(_$ListingConditionEnumMap, json['condition']),
  status: $enumDecode(_$ListingStatusEnumMap, json['status']),
  hasFMarking: json['has_f_marking'] as bool,
  isModified: json['is_modified'] as bool,
  ships: json['ships'] as bool,
  pickupOnly: json['pickup_only'] as bool,
  postalCode: json['postal_code'] as String,
  city: json['city'] as String,
  lat: (json['lat'] as num).toDouble(),
  lng: (json['lng'] as num).toDouble(),
  viewCount: (json['view_count'] as num).toInt(),
  createdAt: DateTime.parse(json['created_at'] as String),
  updatedAt: DateTime.parse(json['updated_at'] as String),
  manufacturer: json['manufacturer'] as String?,
  model: json['model'] as String?,
  joule: (json['joule'] as num?)?.toDouble(),
  propulsion: $enumDecodeNullable(_$PropulsionTypeEnumMap, json['propulsion']),
  caliber: json['caliber'] as String?,
  publishedAt: json['published_at'] == null
      ? null
      : DateTime.parse(json['published_at'] as String),
  bumpedAt: json['bumped_at'] == null
      ? null
      : DateTime.parse(json['bumped_at'] as String),
  soldAt: json['sold_at'] == null
      ? null
      : DateTime.parse(json['sold_at'] as String),
);

Map<String, dynamic> _$ListingToJson(_Listing instance) => <String, dynamic>{
  'id': instance.id,
  'seller_id': instance.sellerId,
  'category_id': instance.categoryId,
  'title': instance.title,
  'description': instance.description,
  'price_cents': instance.priceCents,
  'negotiable': instance.negotiable,
  'is_giveaway': instance.isGiveaway,
  'accepts_swap': instance.acceptsSwap,
  'condition': _$ListingConditionEnumMap[instance.condition]!,
  'status': _$ListingStatusEnumMap[instance.status]!,
  'has_f_marking': instance.hasFMarking,
  'is_modified': instance.isModified,
  'ships': instance.ships,
  'pickup_only': instance.pickupOnly,
  'postal_code': instance.postalCode,
  'city': instance.city,
  'lat': instance.lat,
  'lng': instance.lng,
  'view_count': instance.viewCount,
  'created_at': instance.createdAt.toIso8601String(),
  'updated_at': instance.updatedAt.toIso8601String(),
  'manufacturer': instance.manufacturer,
  'model': instance.model,
  'joule': instance.joule,
  'propulsion': _$PropulsionTypeEnumMap[instance.propulsion],
  'caliber': instance.caliber,
  'published_at': instance.publishedAt?.toIso8601String(),
  'bumped_at': instance.bumpedAt?.toIso8601String(),
  'sold_at': instance.soldAt?.toIso8601String(),
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

const _$PropulsionTypeEnumMap = {
  PropulsionType.saeg: 'saeg',
  PropulsionType.aep: 'aep',
  PropulsionType.gbb: 'gbb',
  PropulsionType.co2: 'co2',
  PropulsionType.hpa: 'hpa',
  PropulsionType.federdruck: 'federdruck',
  PropulsionType.sonstige: 'sonstige',
};

_ListingDraft _$ListingDraftFromJson(Map<String, dynamic> json) =>
    _ListingDraft(
      categoryId: json['category_id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      priceCents: (json['price_cents'] as num).toInt(),
      condition: $enumDecode(_$ListingConditionEnumMap, json['condition']),
      postalCode: json['postal_code'] as String,
      city: json['city'] as String,
      lat: (json['lat'] as num).toDouble(),
      lng: (json['lng'] as num).toDouble(),
      negotiable: json['negotiable'] as bool? ?? false,
      isGiveaway: json['is_giveaway'] as bool? ?? false,
      acceptsSwap: json['accepts_swap'] as bool? ?? false,
      manufacturer: json['manufacturer'] as String?,
      model: json['model'] as String?,
      joule: (json['joule'] as num?)?.toDouble(),
      propulsion: $enumDecodeNullable(
        _$PropulsionTypeEnumMap,
        json['propulsion'],
      ),
      caliber: json['caliber'] as String?,
      hasFMarking: json['has_f_marking'] as bool? ?? false,
      isModified: json['is_modified'] as bool? ?? false,
      ships: json['ships'] as bool? ?? false,
      pickupOnly: json['pickup_only'] as bool? ?? true,
    );

Map<String, dynamic> _$ListingDraftToJson(_ListingDraft instance) =>
    <String, dynamic>{
      'category_id': instance.categoryId,
      'title': instance.title,
      'description': instance.description,
      'price_cents': instance.priceCents,
      'condition': _$ListingConditionEnumMap[instance.condition]!,
      'postal_code': instance.postalCode,
      'city': instance.city,
      'lat': instance.lat,
      'lng': instance.lng,
      'negotiable': instance.negotiable,
      'is_giveaway': instance.isGiveaway,
      'accepts_swap': instance.acceptsSwap,
      'manufacturer': instance.manufacturer,
      'model': instance.model,
      'joule': instance.joule,
      'propulsion': _$PropulsionTypeEnumMap[instance.propulsion],
      'caliber': instance.caliber,
      'has_f_marking': instance.hasFMarking,
      'is_modified': instance.isModified,
      'ships': instance.ships,
      'pickup_only': instance.pickupOnly,
    };
