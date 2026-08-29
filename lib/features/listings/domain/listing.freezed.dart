// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'listing.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$Listing {

 String get id; String get sellerId; String get categoryId; String get title; String get description; int get priceCents; bool get negotiable; bool get isGiveaway; bool get acceptsSwap; ListingCondition get condition; ListingStatus get status; bool get hasFMarking; bool get isModified; bool get ships; bool get pickupOnly; String get postalCode; String get city; double get lat; double get lng; int get viewCount; DateTime get createdAt; DateTime get updatedAt; String? get manufacturer; String? get model; double? get joule; PropulsionType? get propulsion; String? get caliber; DateTime? get publishedAt; DateTime? get bumpedAt; DateTime? get soldAt;
/// Create a copy of Listing
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ListingCopyWith<Listing> get copyWith => _$ListingCopyWithImpl<Listing>(this as Listing, _$identity);

  /// Serializes this Listing to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Listing&&(identical(other.id, id) || other.id == id)&&(identical(other.sellerId, sellerId) || other.sellerId == sellerId)&&(identical(other.categoryId, categoryId) || other.categoryId == categoryId)&&(identical(other.title, title) || other.title == title)&&(identical(other.description, description) || other.description == description)&&(identical(other.priceCents, priceCents) || other.priceCents == priceCents)&&(identical(other.negotiable, negotiable) || other.negotiable == negotiable)&&(identical(other.isGiveaway, isGiveaway) || other.isGiveaway == isGiveaway)&&(identical(other.acceptsSwap, acceptsSwap) || other.acceptsSwap == acceptsSwap)&&(identical(other.condition, condition) || other.condition == condition)&&(identical(other.status, status) || other.status == status)&&(identical(other.hasFMarking, hasFMarking) || other.hasFMarking == hasFMarking)&&(identical(other.isModified, isModified) || other.isModified == isModified)&&(identical(other.ships, ships) || other.ships == ships)&&(identical(other.pickupOnly, pickupOnly) || other.pickupOnly == pickupOnly)&&(identical(other.postalCode, postalCode) || other.postalCode == postalCode)&&(identical(other.city, city) || other.city == city)&&(identical(other.lat, lat) || other.lat == lat)&&(identical(other.lng, lng) || other.lng == lng)&&(identical(other.viewCount, viewCount) || other.viewCount == viewCount)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.manufacturer, manufacturer) || other.manufacturer == manufacturer)&&(identical(other.model, model) || other.model == model)&&(identical(other.joule, joule) || other.joule == joule)&&(identical(other.propulsion, propulsion) || other.propulsion == propulsion)&&(identical(other.caliber, caliber) || other.caliber == caliber)&&(identical(other.publishedAt, publishedAt) || other.publishedAt == publishedAt)&&(identical(other.bumpedAt, bumpedAt) || other.bumpedAt == bumpedAt)&&(identical(other.soldAt, soldAt) || other.soldAt == soldAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hashAll([runtimeType,id,sellerId,categoryId,title,description,priceCents,negotiable,isGiveaway,acceptsSwap,condition,status,hasFMarking,isModified,ships,pickupOnly,postalCode,city,lat,lng,viewCount,createdAt,updatedAt,manufacturer,model,joule,propulsion,caliber,publishedAt,bumpedAt,soldAt]);

@override
String toString() {
  return 'Listing(id: $id, sellerId: $sellerId, categoryId: $categoryId, title: $title, description: $description, priceCents: $priceCents, negotiable: $negotiable, isGiveaway: $isGiveaway, acceptsSwap: $acceptsSwap, condition: $condition, status: $status, hasFMarking: $hasFMarking, isModified: $isModified, ships: $ships, pickupOnly: $pickupOnly, postalCode: $postalCode, city: $city, lat: $lat, lng: $lng, viewCount: $viewCount, createdAt: $createdAt, updatedAt: $updatedAt, manufacturer: $manufacturer, model: $model, joule: $joule, propulsion: $propulsion, caliber: $caliber, publishedAt: $publishedAt, bumpedAt: $bumpedAt, soldAt: $soldAt)';
}


}

/// @nodoc
abstract mixin class $ListingCopyWith<$Res>  {
  factory $ListingCopyWith(Listing value, $Res Function(Listing) _then) = _$ListingCopyWithImpl;
@useResult
$Res call({
 String id, String sellerId, String categoryId, String title, String description, int priceCents, bool negotiable, bool isGiveaway, bool acceptsSwap, ListingCondition condition, ListingStatus status, bool hasFMarking, bool isModified, bool ships, bool pickupOnly, String postalCode, String city, double lat, double lng, int viewCount, DateTime createdAt, DateTime updatedAt, String? manufacturer, String? model, double? joule, PropulsionType? propulsion, String? caliber, DateTime? publishedAt, DateTime? bumpedAt, DateTime? soldAt
});




}
/// @nodoc
class _$ListingCopyWithImpl<$Res>
    implements $ListingCopyWith<$Res> {
  _$ListingCopyWithImpl(this._self, this._then);

  final Listing _self;
  final $Res Function(Listing) _then;

/// Create a copy of Listing
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? sellerId = null,Object? categoryId = null,Object? title = null,Object? description = null,Object? priceCents = null,Object? negotiable = null,Object? isGiveaway = null,Object? acceptsSwap = null,Object? condition = null,Object? status = null,Object? hasFMarking = null,Object? isModified = null,Object? ships = null,Object? pickupOnly = null,Object? postalCode = null,Object? city = null,Object? lat = null,Object? lng = null,Object? viewCount = null,Object? createdAt = null,Object? updatedAt = null,Object? manufacturer = freezed,Object? model = freezed,Object? joule = freezed,Object? propulsion = freezed,Object? caliber = freezed,Object? publishedAt = freezed,Object? bumpedAt = freezed,Object? soldAt = freezed,}) {
  return _then(Listing(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,sellerId: null == sellerId ? _self.sellerId : sellerId // ignore: cast_nullable_to_non_nullable
as String,categoryId: null == categoryId ? _self.categoryId : categoryId // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,description: null == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String,priceCents: null == priceCents ? _self.priceCents : priceCents // ignore: cast_nullable_to_non_nullable
as int,negotiable: null == negotiable ? _self.negotiable : negotiable // ignore: cast_nullable_to_non_nullable
as bool,isGiveaway: null == isGiveaway ? _self.isGiveaway : isGiveaway // ignore: cast_nullable_to_non_nullable
as bool,acceptsSwap: null == acceptsSwap ? _self.acceptsSwap : acceptsSwap // ignore: cast_nullable_to_non_nullable
as bool,condition: null == condition ? _self.condition : condition // ignore: cast_nullable_to_non_nullable
as ListingCondition,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as ListingStatus,hasFMarking: null == hasFMarking ? _self.hasFMarking : hasFMarking // ignore: cast_nullable_to_non_nullable
as bool,isModified: null == isModified ? _self.isModified : isModified // ignore: cast_nullable_to_non_nullable
as bool,ships: null == ships ? _self.ships : ships // ignore: cast_nullable_to_non_nullable
as bool,pickupOnly: null == pickupOnly ? _self.pickupOnly : pickupOnly // ignore: cast_nullable_to_non_nullable
as bool,postalCode: null == postalCode ? _self.postalCode : postalCode // ignore: cast_nullable_to_non_nullable
as String,city: null == city ? _self.city : city // ignore: cast_nullable_to_non_nullable
as String,lat: null == lat ? _self.lat : lat // ignore: cast_nullable_to_non_nullable
as double,lng: null == lng ? _self.lng : lng // ignore: cast_nullable_to_non_nullable
as double,viewCount: null == viewCount ? _self.viewCount : viewCount // ignore: cast_nullable_to_non_nullable
as int,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,manufacturer: freezed == manufacturer ? _self.manufacturer : manufacturer // ignore: cast_nullable_to_non_nullable
as String?,model: freezed == model ? _self.model : model // ignore: cast_nullable_to_non_nullable
as String?,joule: freezed == joule ? _self.joule : joule // ignore: cast_nullable_to_non_nullable
as double?,propulsion: freezed == propulsion ? _self.propulsion : propulsion // ignore: cast_nullable_to_non_nullable
as PropulsionType?,caliber: freezed == caliber ? _self.caliber : caliber // ignore: cast_nullable_to_non_nullable
as String?,publishedAt: freezed == publishedAt ? _self.publishedAt : publishedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,bumpedAt: freezed == bumpedAt ? _self.bumpedAt : bumpedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,soldAt: freezed == soldAt ? _self.soldAt : soldAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

}


/// Adds pattern-matching-related methods to [Listing].
extension ListingPatterns on Listing {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Listing value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Listing() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Listing value)  $default,){
final _that = this;
switch (_that) {
case _Listing():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Listing value)?  $default,){
final _that = this;
switch (_that) {
case _Listing() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String sellerId,  String categoryId,  String title,  String description,  int priceCents,  bool negotiable,  bool isGiveaway,  bool acceptsSwap,  ListingCondition condition,  ListingStatus status,  bool hasFMarking,  bool isModified,  bool ships,  bool pickupOnly,  String postalCode,  String city,  double lat,  double lng,  int viewCount,  DateTime createdAt,  DateTime updatedAt,  String? manufacturer,  String? model,  double? joule,  PropulsionType? propulsion,  String? caliber,  DateTime? publishedAt,  DateTime? bumpedAt,  DateTime? soldAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Listing() when $default != null:
return $default(_that.id,_that.sellerId,_that.categoryId,_that.title,_that.description,_that.priceCents,_that.negotiable,_that.isGiveaway,_that.acceptsSwap,_that.condition,_that.status,_that.hasFMarking,_that.isModified,_that.ships,_that.pickupOnly,_that.postalCode,_that.city,_that.lat,_that.lng,_that.viewCount,_that.createdAt,_that.updatedAt,_that.manufacturer,_that.model,_that.joule,_that.propulsion,_that.caliber,_that.publishedAt,_that.bumpedAt,_that.soldAt);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String sellerId,  String categoryId,  String title,  String description,  int priceCents,  bool negotiable,  bool isGiveaway,  bool acceptsSwap,  ListingCondition condition,  ListingStatus status,  bool hasFMarking,  bool isModified,  bool ships,  bool pickupOnly,  String postalCode,  String city,  double lat,  double lng,  int viewCount,  DateTime createdAt,  DateTime updatedAt,  String? manufacturer,  String? model,  double? joule,  PropulsionType? propulsion,  String? caliber,  DateTime? publishedAt,  DateTime? bumpedAt,  DateTime? soldAt)  $default,) {final _that = this;
switch (_that) {
case _Listing():
return $default(_that.id,_that.sellerId,_that.categoryId,_that.title,_that.description,_that.priceCents,_that.negotiable,_that.isGiveaway,_that.acceptsSwap,_that.condition,_that.status,_that.hasFMarking,_that.isModified,_that.ships,_that.pickupOnly,_that.postalCode,_that.city,_that.lat,_that.lng,_that.viewCount,_that.createdAt,_that.updatedAt,_that.manufacturer,_that.model,_that.joule,_that.propulsion,_that.caliber,_that.publishedAt,_that.bumpedAt,_that.soldAt);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String sellerId,  String categoryId,  String title,  String description,  int priceCents,  bool negotiable,  bool isGiveaway,  bool acceptsSwap,  ListingCondition condition,  ListingStatus status,  bool hasFMarking,  bool isModified,  bool ships,  bool pickupOnly,  String postalCode,  String city,  double lat,  double lng,  int viewCount,  DateTime createdAt,  DateTime updatedAt,  String? manufacturer,  String? model,  double? joule,  PropulsionType? propulsion,  String? caliber,  DateTime? publishedAt,  DateTime? bumpedAt,  DateTime? soldAt)?  $default,) {final _that = this;
switch (_that) {
case _Listing() when $default != null:
return $default(_that.id,_that.sellerId,_that.categoryId,_that.title,_that.description,_that.priceCents,_that.negotiable,_that.isGiveaway,_that.acceptsSwap,_that.condition,_that.status,_that.hasFMarking,_that.isModified,_that.ships,_that.pickupOnly,_that.postalCode,_that.city,_that.lat,_that.lng,_that.viewCount,_that.createdAt,_that.updatedAt,_that.manufacturer,_that.model,_that.joule,_that.propulsion,_that.caliber,_that.publishedAt,_that.bumpedAt,_that.soldAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Listing implements Listing {
  const _Listing({required this.id, required this.sellerId, required this.categoryId, required this.title, required this.description, required this.priceCents, required this.negotiable, required this.isGiveaway, required this.acceptsSwap, required this.condition, required this.status, required this.hasFMarking, required this.isModified, required this.ships, required this.pickupOnly, required this.postalCode, required this.city, required this.lat, required this.lng, required this.viewCount, required this.createdAt, required this.updatedAt, this.manufacturer, this.model, this.joule, this.propulsion, this.caliber, this.publishedAt, this.bumpedAt, this.soldAt});
  factory _Listing.fromJson(Map<String, dynamic> json) => _$ListingFromJson(json);

@override final  String id;
@override final  String sellerId;
@override final  String categoryId;
@override final  String title;
@override final  String description;
@override final  int priceCents;
@override final  bool negotiable;
@override final  bool isGiveaway;
@override final  bool acceptsSwap;
@override final  ListingCondition condition;
@override final  ListingStatus status;
@override final  bool hasFMarking;
@override final  bool isModified;
@override final  bool ships;
@override final  bool pickupOnly;
@override final  String postalCode;
@override final  String city;
@override final  double lat;
@override final  double lng;
@override final  int viewCount;
@override final  DateTime createdAt;
@override final  DateTime updatedAt;
@override final  String? manufacturer;
@override final  String? model;
@override final  double? joule;
@override final  PropulsionType? propulsion;
@override final  String? caliber;
@override final  DateTime? publishedAt;
@override final  DateTime? bumpedAt;
@override final  DateTime? soldAt;

/// Create a copy of Listing
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ListingCopyWith<_Listing> get copyWith => __$ListingCopyWithImpl<_Listing>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ListingToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Listing&&(identical(other.id, id) || other.id == id)&&(identical(other.sellerId, sellerId) || other.sellerId == sellerId)&&(identical(other.categoryId, categoryId) || other.categoryId == categoryId)&&(identical(other.title, title) || other.title == title)&&(identical(other.description, description) || other.description == description)&&(identical(other.priceCents, priceCents) || other.priceCents == priceCents)&&(identical(other.negotiable, negotiable) || other.negotiable == negotiable)&&(identical(other.isGiveaway, isGiveaway) || other.isGiveaway == isGiveaway)&&(identical(other.acceptsSwap, acceptsSwap) || other.acceptsSwap == acceptsSwap)&&(identical(other.condition, condition) || other.condition == condition)&&(identical(other.status, status) || other.status == status)&&(identical(other.hasFMarking, hasFMarking) || other.hasFMarking == hasFMarking)&&(identical(other.isModified, isModified) || other.isModified == isModified)&&(identical(other.ships, ships) || other.ships == ships)&&(identical(other.pickupOnly, pickupOnly) || other.pickupOnly == pickupOnly)&&(identical(other.postalCode, postalCode) || other.postalCode == postalCode)&&(identical(other.city, city) || other.city == city)&&(identical(other.lat, lat) || other.lat == lat)&&(identical(other.lng, lng) || other.lng == lng)&&(identical(other.viewCount, viewCount) || other.viewCount == viewCount)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.manufacturer, manufacturer) || other.manufacturer == manufacturer)&&(identical(other.model, model) || other.model == model)&&(identical(other.joule, joule) || other.joule == joule)&&(identical(other.propulsion, propulsion) || other.propulsion == propulsion)&&(identical(other.caliber, caliber) || other.caliber == caliber)&&(identical(other.publishedAt, publishedAt) || other.publishedAt == publishedAt)&&(identical(other.bumpedAt, bumpedAt) || other.bumpedAt == bumpedAt)&&(identical(other.soldAt, soldAt) || other.soldAt == soldAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hashAll([runtimeType,id,sellerId,categoryId,title,description,priceCents,negotiable,isGiveaway,acceptsSwap,condition,status,hasFMarking,isModified,ships,pickupOnly,postalCode,city,lat,lng,viewCount,createdAt,updatedAt,manufacturer,model,joule,propulsion,caliber,publishedAt,bumpedAt,soldAt]);

@override
String toString() {
  return 'Listing(id: $id, sellerId: $sellerId, categoryId: $categoryId, title: $title, description: $description, priceCents: $priceCents, negotiable: $negotiable, isGiveaway: $isGiveaway, acceptsSwap: $acceptsSwap, condition: $condition, status: $status, hasFMarking: $hasFMarking, isModified: $isModified, ships: $ships, pickupOnly: $pickupOnly, postalCode: $postalCode, city: $city, lat: $lat, lng: $lng, viewCount: $viewCount, createdAt: $createdAt, updatedAt: $updatedAt, manufacturer: $manufacturer, model: $model, joule: $joule, propulsion: $propulsion, caliber: $caliber, publishedAt: $publishedAt, bumpedAt: $bumpedAt, soldAt: $soldAt)';
}


}

/// @nodoc
abstract mixin class _$ListingCopyWith<$Res> implements $ListingCopyWith<$Res> {
  factory _$ListingCopyWith(_Listing value, $Res Function(_Listing) _then) = __$ListingCopyWithImpl;
@override @useResult
$Res call({
 String id, String sellerId, String categoryId, String title, String description, int priceCents, bool negotiable, bool isGiveaway, bool acceptsSwap, ListingCondition condition, ListingStatus status, bool hasFMarking, bool isModified, bool ships, bool pickupOnly, String postalCode, String city, double lat, double lng, int viewCount, DateTime createdAt, DateTime updatedAt, String? manufacturer, String? model, double? joule, PropulsionType? propulsion, String? caliber, DateTime? publishedAt, DateTime? bumpedAt, DateTime? soldAt
});




}
/// @nodoc
class __$ListingCopyWithImpl<$Res>
    implements _$ListingCopyWith<$Res> {
  __$ListingCopyWithImpl(this._self, this._then);

  final _Listing _self;
  final $Res Function(_Listing) _then;

/// Create a copy of Listing
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? sellerId = null,Object? categoryId = null,Object? title = null,Object? description = null,Object? priceCents = null,Object? negotiable = null,Object? isGiveaway = null,Object? acceptsSwap = null,Object? condition = null,Object? status = null,Object? hasFMarking = null,Object? isModified = null,Object? ships = null,Object? pickupOnly = null,Object? postalCode = null,Object? city = null,Object? lat = null,Object? lng = null,Object? viewCount = null,Object? createdAt = null,Object? updatedAt = null,Object? manufacturer = freezed,Object? model = freezed,Object? joule = freezed,Object? propulsion = freezed,Object? caliber = freezed,Object? publishedAt = freezed,Object? bumpedAt = freezed,Object? soldAt = freezed,}) {
  return _then(_Listing(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,sellerId: null == sellerId ? _self.sellerId : sellerId // ignore: cast_nullable_to_non_nullable
as String,categoryId: null == categoryId ? _self.categoryId : categoryId // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,description: null == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String,priceCents: null == priceCents ? _self.priceCents : priceCents // ignore: cast_nullable_to_non_nullable
as int,negotiable: null == negotiable ? _self.negotiable : negotiable // ignore: cast_nullable_to_non_nullable
as bool,isGiveaway: null == isGiveaway ? _self.isGiveaway : isGiveaway // ignore: cast_nullable_to_non_nullable
as bool,acceptsSwap: null == acceptsSwap ? _self.acceptsSwap : acceptsSwap // ignore: cast_nullable_to_non_nullable
as bool,condition: null == condition ? _self.condition : condition // ignore: cast_nullable_to_non_nullable
as ListingCondition,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as ListingStatus,hasFMarking: null == hasFMarking ? _self.hasFMarking : hasFMarking // ignore: cast_nullable_to_non_nullable
as bool,isModified: null == isModified ? _self.isModified : isModified // ignore: cast_nullable_to_non_nullable
as bool,ships: null == ships ? _self.ships : ships // ignore: cast_nullable_to_non_nullable
as bool,pickupOnly: null == pickupOnly ? _self.pickupOnly : pickupOnly // ignore: cast_nullable_to_non_nullable
as bool,postalCode: null == postalCode ? _self.postalCode : postalCode // ignore: cast_nullable_to_non_nullable
as String,city: null == city ? _self.city : city // ignore: cast_nullable_to_non_nullable
as String,lat: null == lat ? _self.lat : lat // ignore: cast_nullable_to_non_nullable
as double,lng: null == lng ? _self.lng : lng // ignore: cast_nullable_to_non_nullable
as double,viewCount: null == viewCount ? _self.viewCount : viewCount // ignore: cast_nullable_to_non_nullable
as int,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,manufacturer: freezed == manufacturer ? _self.manufacturer : manufacturer // ignore: cast_nullable_to_non_nullable
as String?,model: freezed == model ? _self.model : model // ignore: cast_nullable_to_non_nullable
as String?,joule: freezed == joule ? _self.joule : joule // ignore: cast_nullable_to_non_nullable
as double?,propulsion: freezed == propulsion ? _self.propulsion : propulsion // ignore: cast_nullable_to_non_nullable
as PropulsionType?,caliber: freezed == caliber ? _self.caliber : caliber // ignore: cast_nullable_to_non_nullable
as String?,publishedAt: freezed == publishedAt ? _self.publishedAt : publishedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,bumpedAt: freezed == bumpedAt ? _self.bumpedAt : bumpedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,soldAt: freezed == soldAt ? _self.soldAt : soldAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}


/// @nodoc
mixin _$ListingDraft {

 String get categoryId; String get title; String get description; int get priceCents; ListingCondition get condition; String get postalCode; String get city; double get lat; double get lng; bool get negotiable; bool get isGiveaway; bool get acceptsSwap; String? get manufacturer; String? get model; double? get joule; PropulsionType? get propulsion; String? get caliber; bool get hasFMarking; bool get isModified; bool get ships; bool get pickupOnly;
/// Create a copy of ListingDraft
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ListingDraftCopyWith<ListingDraft> get copyWith => _$ListingDraftCopyWithImpl<ListingDraft>(this as ListingDraft, _$identity);

  /// Serializes this ListingDraft to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ListingDraft&&(identical(other.categoryId, categoryId) || other.categoryId == categoryId)&&(identical(other.title, title) || other.title == title)&&(identical(other.description, description) || other.description == description)&&(identical(other.priceCents, priceCents) || other.priceCents == priceCents)&&(identical(other.condition, condition) || other.condition == condition)&&(identical(other.postalCode, postalCode) || other.postalCode == postalCode)&&(identical(other.city, city) || other.city == city)&&(identical(other.lat, lat) || other.lat == lat)&&(identical(other.lng, lng) || other.lng == lng)&&(identical(other.negotiable, negotiable) || other.negotiable == negotiable)&&(identical(other.isGiveaway, isGiveaway) || other.isGiveaway == isGiveaway)&&(identical(other.acceptsSwap, acceptsSwap) || other.acceptsSwap == acceptsSwap)&&(identical(other.manufacturer, manufacturer) || other.manufacturer == manufacturer)&&(identical(other.model, model) || other.model == model)&&(identical(other.joule, joule) || other.joule == joule)&&(identical(other.propulsion, propulsion) || other.propulsion == propulsion)&&(identical(other.caliber, caliber) || other.caliber == caliber)&&(identical(other.hasFMarking, hasFMarking) || other.hasFMarking == hasFMarking)&&(identical(other.isModified, isModified) || other.isModified == isModified)&&(identical(other.ships, ships) || other.ships == ships)&&(identical(other.pickupOnly, pickupOnly) || other.pickupOnly == pickupOnly));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hashAll([runtimeType,categoryId,title,description,priceCents,condition,postalCode,city,lat,lng,negotiable,isGiveaway,acceptsSwap,manufacturer,model,joule,propulsion,caliber,hasFMarking,isModified,ships,pickupOnly]);

@override
String toString() {
  return 'ListingDraft(categoryId: $categoryId, title: $title, description: $description, priceCents: $priceCents, condition: $condition, postalCode: $postalCode, city: $city, lat: $lat, lng: $lng, negotiable: $negotiable, isGiveaway: $isGiveaway, acceptsSwap: $acceptsSwap, manufacturer: $manufacturer, model: $model, joule: $joule, propulsion: $propulsion, caliber: $caliber, hasFMarking: $hasFMarking, isModified: $isModified, ships: $ships, pickupOnly: $pickupOnly)';
}


}

/// @nodoc
abstract mixin class $ListingDraftCopyWith<$Res>  {
  factory $ListingDraftCopyWith(ListingDraft value, $Res Function(ListingDraft) _then) = _$ListingDraftCopyWithImpl;
@useResult
$Res call({
 String categoryId, String title, String description, int priceCents, ListingCondition condition, String postalCode, String city, double lat, double lng, bool negotiable, bool isGiveaway, bool acceptsSwap, String? manufacturer, String? model, double? joule, PropulsionType? propulsion, String? caliber, bool hasFMarking, bool isModified, bool ships, bool pickupOnly
});




}
/// @nodoc
class _$ListingDraftCopyWithImpl<$Res>
    implements $ListingDraftCopyWith<$Res> {
  _$ListingDraftCopyWithImpl(this._self, this._then);

  final ListingDraft _self;
  final $Res Function(ListingDraft) _then;

/// Create a copy of ListingDraft
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? categoryId = null,Object? title = null,Object? description = null,Object? priceCents = null,Object? condition = null,Object? postalCode = null,Object? city = null,Object? lat = null,Object? lng = null,Object? negotiable = null,Object? isGiveaway = null,Object? acceptsSwap = null,Object? manufacturer = freezed,Object? model = freezed,Object? joule = freezed,Object? propulsion = freezed,Object? caliber = freezed,Object? hasFMarking = null,Object? isModified = null,Object? ships = null,Object? pickupOnly = null,}) {
  return _then(ListingDraft(
categoryId: null == categoryId ? _self.categoryId : categoryId // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,description: null == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String,priceCents: null == priceCents ? _self.priceCents : priceCents // ignore: cast_nullable_to_non_nullable
as int,condition: null == condition ? _self.condition : condition // ignore: cast_nullable_to_non_nullable
as ListingCondition,postalCode: null == postalCode ? _self.postalCode : postalCode // ignore: cast_nullable_to_non_nullable
as String,city: null == city ? _self.city : city // ignore: cast_nullable_to_non_nullable
as String,lat: null == lat ? _self.lat : lat // ignore: cast_nullable_to_non_nullable
as double,lng: null == lng ? _self.lng : lng // ignore: cast_nullable_to_non_nullable
as double,negotiable: null == negotiable ? _self.negotiable : negotiable // ignore: cast_nullable_to_non_nullable
as bool,isGiveaway: null == isGiveaway ? _self.isGiveaway : isGiveaway // ignore: cast_nullable_to_non_nullable
as bool,acceptsSwap: null == acceptsSwap ? _self.acceptsSwap : acceptsSwap // ignore: cast_nullable_to_non_nullable
as bool,manufacturer: freezed == manufacturer ? _self.manufacturer : manufacturer // ignore: cast_nullable_to_non_nullable
as String?,model: freezed == model ? _self.model : model // ignore: cast_nullable_to_non_nullable
as String?,joule: freezed == joule ? _self.joule : joule // ignore: cast_nullable_to_non_nullable
as double?,propulsion: freezed == propulsion ? _self.propulsion : propulsion // ignore: cast_nullable_to_non_nullable
as PropulsionType?,caliber: freezed == caliber ? _self.caliber : caliber // ignore: cast_nullable_to_non_nullable
as String?,hasFMarking: null == hasFMarking ? _self.hasFMarking : hasFMarking // ignore: cast_nullable_to_non_nullable
as bool,isModified: null == isModified ? _self.isModified : isModified // ignore: cast_nullable_to_non_nullable
as bool,ships: null == ships ? _self.ships : ships // ignore: cast_nullable_to_non_nullable
as bool,pickupOnly: null == pickupOnly ? _self.pickupOnly : pickupOnly // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [ListingDraft].
extension ListingDraftPatterns on ListingDraft {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ListingDraft value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ListingDraft() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ListingDraft value)  $default,){
final _that = this;
switch (_that) {
case _ListingDraft():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ListingDraft value)?  $default,){
final _that = this;
switch (_that) {
case _ListingDraft() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String categoryId,  String title,  String description,  int priceCents,  ListingCondition condition,  String postalCode,  String city,  double lat,  double lng,  bool negotiable,  bool isGiveaway,  bool acceptsSwap,  String? manufacturer,  String? model,  double? joule,  PropulsionType? propulsion,  String? caliber,  bool hasFMarking,  bool isModified,  bool ships,  bool pickupOnly)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ListingDraft() when $default != null:
return $default(_that.categoryId,_that.title,_that.description,_that.priceCents,_that.condition,_that.postalCode,_that.city,_that.lat,_that.lng,_that.negotiable,_that.isGiveaway,_that.acceptsSwap,_that.manufacturer,_that.model,_that.joule,_that.propulsion,_that.caliber,_that.hasFMarking,_that.isModified,_that.ships,_that.pickupOnly);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String categoryId,  String title,  String description,  int priceCents,  ListingCondition condition,  String postalCode,  String city,  double lat,  double lng,  bool negotiable,  bool isGiveaway,  bool acceptsSwap,  String? manufacturer,  String? model,  double? joule,  PropulsionType? propulsion,  String? caliber,  bool hasFMarking,  bool isModified,  bool ships,  bool pickupOnly)  $default,) {final _that = this;
switch (_that) {
case _ListingDraft():
return $default(_that.categoryId,_that.title,_that.description,_that.priceCents,_that.condition,_that.postalCode,_that.city,_that.lat,_that.lng,_that.negotiable,_that.isGiveaway,_that.acceptsSwap,_that.manufacturer,_that.model,_that.joule,_that.propulsion,_that.caliber,_that.hasFMarking,_that.isModified,_that.ships,_that.pickupOnly);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String categoryId,  String title,  String description,  int priceCents,  ListingCondition condition,  String postalCode,  String city,  double lat,  double lng,  bool negotiable,  bool isGiveaway,  bool acceptsSwap,  String? manufacturer,  String? model,  double? joule,  PropulsionType? propulsion,  String? caliber,  bool hasFMarking,  bool isModified,  bool ships,  bool pickupOnly)?  $default,) {final _that = this;
switch (_that) {
case _ListingDraft() when $default != null:
return $default(_that.categoryId,_that.title,_that.description,_that.priceCents,_that.condition,_that.postalCode,_that.city,_that.lat,_that.lng,_that.negotiable,_that.isGiveaway,_that.acceptsSwap,_that.manufacturer,_that.model,_that.joule,_that.propulsion,_that.caliber,_that.hasFMarking,_that.isModified,_that.ships,_that.pickupOnly);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ListingDraft implements ListingDraft {
  const _ListingDraft({required this.categoryId, required this.title, required this.description, required this.priceCents, required this.condition, required this.postalCode, required this.city, required this.lat, required this.lng, this.negotiable = false, this.isGiveaway = false, this.acceptsSwap = false, this.manufacturer, this.model, this.joule, this.propulsion, this.caliber, this.hasFMarking = false, this.isModified = false, this.ships = false, this.pickupOnly = true});
  factory _ListingDraft.fromJson(Map<String, dynamic> json) => _$ListingDraftFromJson(json);

@override final  String categoryId;
@override final  String title;
@override final  String description;
@override final  int priceCents;
@override final  ListingCondition condition;
@override final  String postalCode;
@override final  String city;
@override final  double lat;
@override final  double lng;
@override@JsonKey() final  bool negotiable;
@override@JsonKey() final  bool isGiveaway;
@override@JsonKey() final  bool acceptsSwap;
@override final  String? manufacturer;
@override final  String? model;
@override final  double? joule;
@override final  PropulsionType? propulsion;
@override final  String? caliber;
@override@JsonKey() final  bool hasFMarking;
@override@JsonKey() final  bool isModified;
@override@JsonKey() final  bool ships;
@override@JsonKey() final  bool pickupOnly;

/// Create a copy of ListingDraft
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ListingDraftCopyWith<_ListingDraft> get copyWith => __$ListingDraftCopyWithImpl<_ListingDraft>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ListingDraftToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ListingDraft&&(identical(other.categoryId, categoryId) || other.categoryId == categoryId)&&(identical(other.title, title) || other.title == title)&&(identical(other.description, description) || other.description == description)&&(identical(other.priceCents, priceCents) || other.priceCents == priceCents)&&(identical(other.condition, condition) || other.condition == condition)&&(identical(other.postalCode, postalCode) || other.postalCode == postalCode)&&(identical(other.city, city) || other.city == city)&&(identical(other.lat, lat) || other.lat == lat)&&(identical(other.lng, lng) || other.lng == lng)&&(identical(other.negotiable, negotiable) || other.negotiable == negotiable)&&(identical(other.isGiveaway, isGiveaway) || other.isGiveaway == isGiveaway)&&(identical(other.acceptsSwap, acceptsSwap) || other.acceptsSwap == acceptsSwap)&&(identical(other.manufacturer, manufacturer) || other.manufacturer == manufacturer)&&(identical(other.model, model) || other.model == model)&&(identical(other.joule, joule) || other.joule == joule)&&(identical(other.propulsion, propulsion) || other.propulsion == propulsion)&&(identical(other.caliber, caliber) || other.caliber == caliber)&&(identical(other.hasFMarking, hasFMarking) || other.hasFMarking == hasFMarking)&&(identical(other.isModified, isModified) || other.isModified == isModified)&&(identical(other.ships, ships) || other.ships == ships)&&(identical(other.pickupOnly, pickupOnly) || other.pickupOnly == pickupOnly));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hashAll([runtimeType,categoryId,title,description,priceCents,condition,postalCode,city,lat,lng,negotiable,isGiveaway,acceptsSwap,manufacturer,model,joule,propulsion,caliber,hasFMarking,isModified,ships,pickupOnly]);

@override
String toString() {
  return 'ListingDraft(categoryId: $categoryId, title: $title, description: $description, priceCents: $priceCents, condition: $condition, postalCode: $postalCode, city: $city, lat: $lat, lng: $lng, negotiable: $negotiable, isGiveaway: $isGiveaway, acceptsSwap: $acceptsSwap, manufacturer: $manufacturer, model: $model, joule: $joule, propulsion: $propulsion, caliber: $caliber, hasFMarking: $hasFMarking, isModified: $isModified, ships: $ships, pickupOnly: $pickupOnly)';
}


}

/// @nodoc
abstract mixin class _$ListingDraftCopyWith<$Res> implements $ListingDraftCopyWith<$Res> {
  factory _$ListingDraftCopyWith(_ListingDraft value, $Res Function(_ListingDraft) _then) = __$ListingDraftCopyWithImpl;
@override @useResult
$Res call({
 String categoryId, String title, String description, int priceCents, ListingCondition condition, String postalCode, String city, double lat, double lng, bool negotiable, bool isGiveaway, bool acceptsSwap, String? manufacturer, String? model, double? joule, PropulsionType? propulsion, String? caliber, bool hasFMarking, bool isModified, bool ships, bool pickupOnly
});




}
/// @nodoc
class __$ListingDraftCopyWithImpl<$Res>
    implements _$ListingDraftCopyWith<$Res> {
  __$ListingDraftCopyWithImpl(this._self, this._then);

  final _ListingDraft _self;
  final $Res Function(_ListingDraft) _then;

/// Create a copy of ListingDraft
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? categoryId = null,Object? title = null,Object? description = null,Object? priceCents = null,Object? condition = null,Object? postalCode = null,Object? city = null,Object? lat = null,Object? lng = null,Object? negotiable = null,Object? isGiveaway = null,Object? acceptsSwap = null,Object? manufacturer = freezed,Object? model = freezed,Object? joule = freezed,Object? propulsion = freezed,Object? caliber = freezed,Object? hasFMarking = null,Object? isModified = null,Object? ships = null,Object? pickupOnly = null,}) {
  return _then(_ListingDraft(
categoryId: null == categoryId ? _self.categoryId : categoryId // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,description: null == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String,priceCents: null == priceCents ? _self.priceCents : priceCents // ignore: cast_nullable_to_non_nullable
as int,condition: null == condition ? _self.condition : condition // ignore: cast_nullable_to_non_nullable
as ListingCondition,postalCode: null == postalCode ? _self.postalCode : postalCode // ignore: cast_nullable_to_non_nullable
as String,city: null == city ? _self.city : city // ignore: cast_nullable_to_non_nullable
as String,lat: null == lat ? _self.lat : lat // ignore: cast_nullable_to_non_nullable
as double,lng: null == lng ? _self.lng : lng // ignore: cast_nullable_to_non_nullable
as double,negotiable: null == negotiable ? _self.negotiable : negotiable // ignore: cast_nullable_to_non_nullable
as bool,isGiveaway: null == isGiveaway ? _self.isGiveaway : isGiveaway // ignore: cast_nullable_to_non_nullable
as bool,acceptsSwap: null == acceptsSwap ? _self.acceptsSwap : acceptsSwap // ignore: cast_nullable_to_non_nullable
as bool,manufacturer: freezed == manufacturer ? _self.manufacturer : manufacturer // ignore: cast_nullable_to_non_nullable
as String?,model: freezed == model ? _self.model : model // ignore: cast_nullable_to_non_nullable
as String?,joule: freezed == joule ? _self.joule : joule // ignore: cast_nullable_to_non_nullable
as double?,propulsion: freezed == propulsion ? _self.propulsion : propulsion // ignore: cast_nullable_to_non_nullable
as PropulsionType?,caliber: freezed == caliber ? _self.caliber : caliber // ignore: cast_nullable_to_non_nullable
as String?,hasFMarking: null == hasFMarking ? _self.hasFMarking : hasFMarking // ignore: cast_nullable_to_non_nullable
as bool,isModified: null == isModified ? _self.isModified : isModified // ignore: cast_nullable_to_non_nullable
as bool,ships: null == ships ? _self.ships : ships // ignore: cast_nullable_to_non_nullable
as bool,pickupOnly: null == pickupOnly ? _self.pickupOnly : pickupOnly // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

// dart format on
