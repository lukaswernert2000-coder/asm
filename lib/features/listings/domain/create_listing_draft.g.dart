// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'create_listing_draft.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_DraftImage _$DraftImageFromJson(Map<String, dynamic> json) => _DraftImage(
  localPath: json['local_path'] as String,
  kind: $enumDecode(_$ImageKindEnumMap, json['kind']),
  uploadedPath: json['uploaded_path'] as String?,
);

Map<String, dynamic> _$DraftImageToJson(_DraftImage instance) =>
    <String, dynamic>{
      'local_path': instance.localPath,
      'kind': _$ImageKindEnumMap[instance.kind]!,
      'uploaded_path': instance.uploadedPath,
    };

const _$ImageKindEnumMap = {
  ImageKind.photo: 'photo',
  ImageKind.fMarking: 'fMarking',
  ImageKind.ownershipProof: 'ownershipProof',
};

_CreateListingDraft _$CreateListingDraftFromJson(
  Map<String, dynamic> json,
) => _CreateListingDraft(
  step: (json['step'] as num?)?.toInt() ?? 0,
  categoryId: json['category_id'] as String?,
  images:
      (json['images'] as List<dynamic>?)
          ?.map((e) => DraftImage.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
  title: json['title'] as String?,
  description: json['description'] as String?,
  condition: $enumDecodeNullable(_$ListingConditionEnumMap, json['condition']),
  manufacturer: json['manufacturer'] as String?,
  model: json['model'] as String?,
  joule: (json['joule'] as num?)?.toDouble(),
  propulsion: $enumDecodeNullable(_$PropulsionTypeEnumMap, json['propulsion']),
  caliber: json['caliber'] as String?,
  isModified: json['is_modified'] as bool? ?? false,
  priceCents: (json['price_cents'] as num?)?.toInt(),
  negotiable: json['negotiable'] as bool? ?? false,
  isGiveaway: json['is_giveaway'] as bool? ?? false,
  acceptsSwap: json['accepts_swap'] as bool? ?? false,
  ships: json['ships'] as bool? ?? false,
  pickupOnly: json['pickup_only'] as bool? ?? true,
  postalCode: json['postal_code'] as String?,
  city: json['city'] as String?,
  lat: (json['lat'] as num?)?.toDouble(),
  lng: (json['lng'] as num?)?.toDouble(),
);

Map<String, dynamic> _$CreateListingDraftToJson(_CreateListingDraft instance) =>
    <String, dynamic>{
      'step': instance.step,
      'category_id': instance.categoryId,
      'images': instance.images.map((e) => e.toJson()).toList(),
      'title': instance.title,
      'description': instance.description,
      'condition': _$ListingConditionEnumMap[instance.condition],
      'manufacturer': instance.manufacturer,
      'model': instance.model,
      'joule': instance.joule,
      'propulsion': _$PropulsionTypeEnumMap[instance.propulsion],
      'caliber': instance.caliber,
      'is_modified': instance.isModified,
      'price_cents': instance.priceCents,
      'negotiable': instance.negotiable,
      'is_giveaway': instance.isGiveaway,
      'accepts_swap': instance.acceptsSwap,
      'ships': instance.ships,
      'pickup_only': instance.pickupOnly,
      'postal_code': instance.postalCode,
      'city': instance.city,
      'lat': instance.lat,
      'lng': instance.lng,
    };

const _$ListingConditionEnumMap = {
  ListingCondition.neu: 'neu',
  ListingCondition.neuwertig: 'neuwertig',
  ListingCondition.gebraucht: 'gebraucht',
  ListingCondition.leichteDefekte: 'leichte_defekte',
  ListingCondition.defekt: 'defekt',
  ListingCondition.bastelobjekt: 'bastelobjekt',
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
