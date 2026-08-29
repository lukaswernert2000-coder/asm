// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'listing_summary.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$ListingSummary {

 String get id; String get title; int get priceCents; bool get negotiable; ListingCondition get condition; ListingStatus get status; String get city; String get postalCode; bool get hasFMarking; bool get ships; DateTime get bumpedAt; String get sellerId; String get categorySlug; double? get joule; String? get coverPath; double? get distanceKm;
/// Create a copy of ListingSummary
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ListingSummaryCopyWith<ListingSummary> get copyWith => _$ListingSummaryCopyWithImpl<ListingSummary>(this as ListingSummary, _$identity);

  /// Serializes this ListingSummary to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ListingSummary&&(identical(other.id, id) || other.id == id)&&(identical(other.title, title) || other.title == title)&&(identical(other.priceCents, priceCents) || other.priceCents == priceCents)&&(identical(other.negotiable, negotiable) || other.negotiable == negotiable)&&(identical(other.condition, condition) || other.condition == condition)&&(identical(other.status, status) || other.status == status)&&(identical(other.city, city) || other.city == city)&&(identical(other.postalCode, postalCode) || other.postalCode == postalCode)&&(identical(other.hasFMarking, hasFMarking) || other.hasFMarking == hasFMarking)&&(identical(other.ships, ships) || other.ships == ships)&&(identical(other.bumpedAt, bumpedAt) || other.bumpedAt == bumpedAt)&&(identical(other.sellerId, sellerId) || other.sellerId == sellerId)&&(identical(other.categorySlug, categorySlug) || other.categorySlug == categorySlug)&&(identical(other.joule, joule) || other.joule == joule)&&(identical(other.coverPath, coverPath) || other.coverPath == coverPath)&&(identical(other.distanceKm, distanceKm) || other.distanceKm == distanceKm));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,title,priceCents,negotiable,condition,status,city,postalCode,hasFMarking,ships,bumpedAt,sellerId,categorySlug,joule,coverPath,distanceKm);

@override
String toString() {
  return 'ListingSummary(id: $id, title: $title, priceCents: $priceCents, negotiable: $negotiable, condition: $condition, status: $status, city: $city, postalCode: $postalCode, hasFMarking: $hasFMarking, ships: $ships, bumpedAt: $bumpedAt, sellerId: $sellerId, categorySlug: $categorySlug, joule: $joule, coverPath: $coverPath, distanceKm: $distanceKm)';
}


}

/// @nodoc
abstract mixin class $ListingSummaryCopyWith<$Res>  {
  factory $ListingSummaryCopyWith(ListingSummary value, $Res Function(ListingSummary) _then) = _$ListingSummaryCopyWithImpl;
@useResult
$Res call({
 String id, String title, int priceCents, bool negotiable, ListingCondition condition, ListingStatus status, String city, String postalCode, bool hasFMarking, bool ships, DateTime bumpedAt, String sellerId, String categorySlug, double? joule, String? coverPath, double? distanceKm
});




}
/// @nodoc
class _$ListingSummaryCopyWithImpl<$Res>
    implements $ListingSummaryCopyWith<$Res> {
  _$ListingSummaryCopyWithImpl(this._self, this._then);

  final ListingSummary _self;
  final $Res Function(ListingSummary) _then;

/// Create a copy of ListingSummary
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? title = null,Object? priceCents = null,Object? negotiable = null,Object? condition = null,Object? status = null,Object? city = null,Object? postalCode = null,Object? hasFMarking = null,Object? ships = null,Object? bumpedAt = null,Object? sellerId = null,Object? categorySlug = null,Object? joule = freezed,Object? coverPath = freezed,Object? distanceKm = freezed,}) {
  return _then(ListingSummary(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,priceCents: null == priceCents ? _self.priceCents : priceCents // ignore: cast_nullable_to_non_nullable
as int,negotiable: null == negotiable ? _self.negotiable : negotiable // ignore: cast_nullable_to_non_nullable
as bool,condition: null == condition ? _self.condition : condition // ignore: cast_nullable_to_non_nullable
as ListingCondition,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as ListingStatus,city: null == city ? _self.city : city // ignore: cast_nullable_to_non_nullable
as String,postalCode: null == postalCode ? _self.postalCode : postalCode // ignore: cast_nullable_to_non_nullable
as String,hasFMarking: null == hasFMarking ? _self.hasFMarking : hasFMarking // ignore: cast_nullable_to_non_nullable
as bool,ships: null == ships ? _self.ships : ships // ignore: cast_nullable_to_non_nullable
as bool,bumpedAt: null == bumpedAt ? _self.bumpedAt : bumpedAt // ignore: cast_nullable_to_non_nullable
as DateTime,sellerId: null == sellerId ? _self.sellerId : sellerId // ignore: cast_nullable_to_non_nullable
as String,categorySlug: null == categorySlug ? _self.categorySlug : categorySlug // ignore: cast_nullable_to_non_nullable
as String,joule: freezed == joule ? _self.joule : joule // ignore: cast_nullable_to_non_nullable
as double?,coverPath: freezed == coverPath ? _self.coverPath : coverPath // ignore: cast_nullable_to_non_nullable
as String?,distanceKm: freezed == distanceKm ? _self.distanceKm : distanceKm // ignore: cast_nullable_to_non_nullable
as double?,
  ));
}

}


/// Adds pattern-matching-related methods to [ListingSummary].
extension ListingSummaryPatterns on ListingSummary {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ListingSummary value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ListingSummary() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ListingSummary value)  $default,){
final _that = this;
switch (_that) {
case _ListingSummary():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ListingSummary value)?  $default,){
final _that = this;
switch (_that) {
case _ListingSummary() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String title,  int priceCents,  bool negotiable,  ListingCondition condition,  ListingStatus status,  String city,  String postalCode,  bool hasFMarking,  bool ships,  DateTime bumpedAt,  String sellerId,  String categorySlug,  double? joule,  String? coverPath,  double? distanceKm)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ListingSummary() when $default != null:
return $default(_that.id,_that.title,_that.priceCents,_that.negotiable,_that.condition,_that.status,_that.city,_that.postalCode,_that.hasFMarking,_that.ships,_that.bumpedAt,_that.sellerId,_that.categorySlug,_that.joule,_that.coverPath,_that.distanceKm);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String title,  int priceCents,  bool negotiable,  ListingCondition condition,  ListingStatus status,  String city,  String postalCode,  bool hasFMarking,  bool ships,  DateTime bumpedAt,  String sellerId,  String categorySlug,  double? joule,  String? coverPath,  double? distanceKm)  $default,) {final _that = this;
switch (_that) {
case _ListingSummary():
return $default(_that.id,_that.title,_that.priceCents,_that.negotiable,_that.condition,_that.status,_that.city,_that.postalCode,_that.hasFMarking,_that.ships,_that.bumpedAt,_that.sellerId,_that.categorySlug,_that.joule,_that.coverPath,_that.distanceKm);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String title,  int priceCents,  bool negotiable,  ListingCondition condition,  ListingStatus status,  String city,  String postalCode,  bool hasFMarking,  bool ships,  DateTime bumpedAt,  String sellerId,  String categorySlug,  double? joule,  String? coverPath,  double? distanceKm)?  $default,) {final _that = this;
switch (_that) {
case _ListingSummary() when $default != null:
return $default(_that.id,_that.title,_that.priceCents,_that.negotiable,_that.condition,_that.status,_that.city,_that.postalCode,_that.hasFMarking,_that.ships,_that.bumpedAt,_that.sellerId,_that.categorySlug,_that.joule,_that.coverPath,_that.distanceKm);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ListingSummary implements ListingSummary {
  const _ListingSummary({required this.id, required this.title, required this.priceCents, required this.negotiable, required this.condition, required this.status, required this.city, required this.postalCode, required this.hasFMarking, required this.ships, required this.bumpedAt, required this.sellerId, required this.categorySlug, this.joule, this.coverPath, this.distanceKm});
  factory _ListingSummary.fromJson(Map<String, dynamic> json) => _$ListingSummaryFromJson(json);

@override final  String id;
@override final  String title;
@override final  int priceCents;
@override final  bool negotiable;
@override final  ListingCondition condition;
@override final  ListingStatus status;
@override final  String city;
@override final  String postalCode;
@override final  bool hasFMarking;
@override final  bool ships;
@override final  DateTime bumpedAt;
@override final  String sellerId;
@override final  String categorySlug;
@override final  double? joule;
@override final  String? coverPath;
@override final  double? distanceKm;

/// Create a copy of ListingSummary
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ListingSummaryCopyWith<_ListingSummary> get copyWith => __$ListingSummaryCopyWithImpl<_ListingSummary>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ListingSummaryToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ListingSummary&&(identical(other.id, id) || other.id == id)&&(identical(other.title, title) || other.title == title)&&(identical(other.priceCents, priceCents) || other.priceCents == priceCents)&&(identical(other.negotiable, negotiable) || other.negotiable == negotiable)&&(identical(other.condition, condition) || other.condition == condition)&&(identical(other.status, status) || other.status == status)&&(identical(other.city, city) || other.city == city)&&(identical(other.postalCode, postalCode) || other.postalCode == postalCode)&&(identical(other.hasFMarking, hasFMarking) || other.hasFMarking == hasFMarking)&&(identical(other.ships, ships) || other.ships == ships)&&(identical(other.bumpedAt, bumpedAt) || other.bumpedAt == bumpedAt)&&(identical(other.sellerId, sellerId) || other.sellerId == sellerId)&&(identical(other.categorySlug, categorySlug) || other.categorySlug == categorySlug)&&(identical(other.joule, joule) || other.joule == joule)&&(identical(other.coverPath, coverPath) || other.coverPath == coverPath)&&(identical(other.distanceKm, distanceKm) || other.distanceKm == distanceKm));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,title,priceCents,negotiable,condition,status,city,postalCode,hasFMarking,ships,bumpedAt,sellerId,categorySlug,joule,coverPath,distanceKm);

@override
String toString() {
  return 'ListingSummary(id: $id, title: $title, priceCents: $priceCents, negotiable: $negotiable, condition: $condition, status: $status, city: $city, postalCode: $postalCode, hasFMarking: $hasFMarking, ships: $ships, bumpedAt: $bumpedAt, sellerId: $sellerId, categorySlug: $categorySlug, joule: $joule, coverPath: $coverPath, distanceKm: $distanceKm)';
}


}

/// @nodoc
abstract mixin class _$ListingSummaryCopyWith<$Res> implements $ListingSummaryCopyWith<$Res> {
  factory _$ListingSummaryCopyWith(_ListingSummary value, $Res Function(_ListingSummary) _then) = __$ListingSummaryCopyWithImpl;
@override @useResult
$Res call({
 String id, String title, int priceCents, bool negotiable, ListingCondition condition, ListingStatus status, String city, String postalCode, bool hasFMarking, bool ships, DateTime bumpedAt, String sellerId, String categorySlug, double? joule, String? coverPath, double? distanceKm
});




}
/// @nodoc
class __$ListingSummaryCopyWithImpl<$Res>
    implements _$ListingSummaryCopyWith<$Res> {
  __$ListingSummaryCopyWithImpl(this._self, this._then);

  final _ListingSummary _self;
  final $Res Function(_ListingSummary) _then;

/// Create a copy of ListingSummary
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? title = null,Object? priceCents = null,Object? negotiable = null,Object? condition = null,Object? status = null,Object? city = null,Object? postalCode = null,Object? hasFMarking = null,Object? ships = null,Object? bumpedAt = null,Object? sellerId = null,Object? categorySlug = null,Object? joule = freezed,Object? coverPath = freezed,Object? distanceKm = freezed,}) {
  return _then(_ListingSummary(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,priceCents: null == priceCents ? _self.priceCents : priceCents // ignore: cast_nullable_to_non_nullable
as int,negotiable: null == negotiable ? _self.negotiable : negotiable // ignore: cast_nullable_to_non_nullable
as bool,condition: null == condition ? _self.condition : condition // ignore: cast_nullable_to_non_nullable
as ListingCondition,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as ListingStatus,city: null == city ? _self.city : city // ignore: cast_nullable_to_non_nullable
as String,postalCode: null == postalCode ? _self.postalCode : postalCode // ignore: cast_nullable_to_non_nullable
as String,hasFMarking: null == hasFMarking ? _self.hasFMarking : hasFMarking // ignore: cast_nullable_to_non_nullable
as bool,ships: null == ships ? _self.ships : ships // ignore: cast_nullable_to_non_nullable
as bool,bumpedAt: null == bumpedAt ? _self.bumpedAt : bumpedAt // ignore: cast_nullable_to_non_nullable
as DateTime,sellerId: null == sellerId ? _self.sellerId : sellerId // ignore: cast_nullable_to_non_nullable
as String,categorySlug: null == categorySlug ? _self.categorySlug : categorySlug // ignore: cast_nullable_to_non_nullable
as String,joule: freezed == joule ? _self.joule : joule // ignore: cast_nullable_to_non_nullable
as double?,coverPath: freezed == coverPath ? _self.coverPath : coverPath // ignore: cast_nullable_to_non_nullable
as String?,distanceKm: freezed == distanceKm ? _self.distanceKm : distanceKm // ignore: cast_nullable_to_non_nullable
as double?,
  ));
}


}

// dart format on
