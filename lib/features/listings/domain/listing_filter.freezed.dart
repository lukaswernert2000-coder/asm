// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'listing_filter.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$ListingFilter {

 String? get query; String? get categorySlug; int? get minPrice; int? get maxPrice; List<ListingCondition>? get conditions; List<PropulsionType>? get propulsions; double? get minJoule; double? get maxJoule; bool? get ships; double? get lat; double? get lng; int? get radiusKm; SortOption get sort;
/// Create a copy of ListingFilter
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ListingFilterCopyWith<ListingFilter> get copyWith => _$ListingFilterCopyWithImpl<ListingFilter>(this as ListingFilter, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ListingFilter&&(identical(other.query, query) || other.query == query)&&(identical(other.categorySlug, categorySlug) || other.categorySlug == categorySlug)&&(identical(other.minPrice, minPrice) || other.minPrice == minPrice)&&(identical(other.maxPrice, maxPrice) || other.maxPrice == maxPrice)&&const DeepCollectionEquality().equals(other.conditions, conditions)&&const DeepCollectionEquality().equals(other.propulsions, propulsions)&&(identical(other.minJoule, minJoule) || other.minJoule == minJoule)&&(identical(other.maxJoule, maxJoule) || other.maxJoule == maxJoule)&&(identical(other.ships, ships) || other.ships == ships)&&(identical(other.lat, lat) || other.lat == lat)&&(identical(other.lng, lng) || other.lng == lng)&&(identical(other.radiusKm, radiusKm) || other.radiusKm == radiusKm)&&(identical(other.sort, sort) || other.sort == sort));
}


@override
int get hashCode => Object.hash(runtimeType,query,categorySlug,minPrice,maxPrice,const DeepCollectionEquality().hash(conditions),const DeepCollectionEquality().hash(propulsions),minJoule,maxJoule,ships,lat,lng,radiusKm,sort);

@override
String toString() {
  return 'ListingFilter(query: $query, categorySlug: $categorySlug, minPrice: $minPrice, maxPrice: $maxPrice, conditions: $conditions, propulsions: $propulsions, minJoule: $minJoule, maxJoule: $maxJoule, ships: $ships, lat: $lat, lng: $lng, radiusKm: $radiusKm, sort: $sort)';
}


}

/// @nodoc
abstract mixin class $ListingFilterCopyWith<$Res>  {
  factory $ListingFilterCopyWith(ListingFilter value, $Res Function(ListingFilter) _then) = _$ListingFilterCopyWithImpl;
@useResult
$Res call({
 String? query, String? categorySlug, int? minPrice, int? maxPrice, List<ListingCondition>? conditions, List<PropulsionType>? propulsions, double? minJoule, double? maxJoule, bool? ships, double? lat, double? lng, int? radiusKm, SortOption sort
});




}
/// @nodoc
class _$ListingFilterCopyWithImpl<$Res>
    implements $ListingFilterCopyWith<$Res> {
  _$ListingFilterCopyWithImpl(this._self, this._then);

  final ListingFilter _self;
  final $Res Function(ListingFilter) _then;

/// Create a copy of ListingFilter
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? query = freezed,Object? categorySlug = freezed,Object? minPrice = freezed,Object? maxPrice = freezed,Object? conditions = freezed,Object? propulsions = freezed,Object? minJoule = freezed,Object? maxJoule = freezed,Object? ships = freezed,Object? lat = freezed,Object? lng = freezed,Object? radiusKm = freezed,Object? sort = null,}) {
  return _then(ListingFilter(
query: freezed == query ? _self.query : query // ignore: cast_nullable_to_non_nullable
as String?,categorySlug: freezed == categorySlug ? _self.categorySlug : categorySlug // ignore: cast_nullable_to_non_nullable
as String?,minPrice: freezed == minPrice ? _self.minPrice : minPrice // ignore: cast_nullable_to_non_nullable
as int?,maxPrice: freezed == maxPrice ? _self.maxPrice : maxPrice // ignore: cast_nullable_to_non_nullable
as int?,conditions: freezed == conditions ? _self.conditions : conditions // ignore: cast_nullable_to_non_nullable
as List<ListingCondition>?,propulsions: freezed == propulsions ? _self.propulsions : propulsions // ignore: cast_nullable_to_non_nullable
as List<PropulsionType>?,minJoule: freezed == minJoule ? _self.minJoule : minJoule // ignore: cast_nullable_to_non_nullable
as double?,maxJoule: freezed == maxJoule ? _self.maxJoule : maxJoule // ignore: cast_nullable_to_non_nullable
as double?,ships: freezed == ships ? _self.ships : ships // ignore: cast_nullable_to_non_nullable
as bool?,lat: freezed == lat ? _self.lat : lat // ignore: cast_nullable_to_non_nullable
as double?,lng: freezed == lng ? _self.lng : lng // ignore: cast_nullable_to_non_nullable
as double?,radiusKm: freezed == radiusKm ? _self.radiusKm : radiusKm // ignore: cast_nullable_to_non_nullable
as int?,sort: null == sort ? _self.sort : sort // ignore: cast_nullable_to_non_nullable
as SortOption,
  ));
}

}


/// Adds pattern-matching-related methods to [ListingFilter].
extension ListingFilterPatterns on ListingFilter {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ListingFilter value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ListingFilter() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ListingFilter value)  $default,){
final _that = this;
switch (_that) {
case _ListingFilter():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ListingFilter value)?  $default,){
final _that = this;
switch (_that) {
case _ListingFilter() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String? query,  String? categorySlug,  int? minPrice,  int? maxPrice,  List<ListingCondition>? conditions,  List<PropulsionType>? propulsions,  double? minJoule,  double? maxJoule,  bool? ships,  double? lat,  double? lng,  int? radiusKm,  SortOption sort)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ListingFilter() when $default != null:
return $default(_that.query,_that.categorySlug,_that.minPrice,_that.maxPrice,_that.conditions,_that.propulsions,_that.minJoule,_that.maxJoule,_that.ships,_that.lat,_that.lng,_that.radiusKm,_that.sort);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String? query,  String? categorySlug,  int? minPrice,  int? maxPrice,  List<ListingCondition>? conditions,  List<PropulsionType>? propulsions,  double? minJoule,  double? maxJoule,  bool? ships,  double? lat,  double? lng,  int? radiusKm,  SortOption sort)  $default,) {final _that = this;
switch (_that) {
case _ListingFilter():
return $default(_that.query,_that.categorySlug,_that.minPrice,_that.maxPrice,_that.conditions,_that.propulsions,_that.minJoule,_that.maxJoule,_that.ships,_that.lat,_that.lng,_that.radiusKm,_that.sort);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String? query,  String? categorySlug,  int? minPrice,  int? maxPrice,  List<ListingCondition>? conditions,  List<PropulsionType>? propulsions,  double? minJoule,  double? maxJoule,  bool? ships,  double? lat,  double? lng,  int? radiusKm,  SortOption sort)?  $default,) {final _that = this;
switch (_that) {
case _ListingFilter() when $default != null:
return $default(_that.query,_that.categorySlug,_that.minPrice,_that.maxPrice,_that.conditions,_that.propulsions,_that.minJoule,_that.maxJoule,_that.ships,_that.lat,_that.lng,_that.radiusKm,_that.sort);case _:
  return null;

}
}

}

/// @nodoc


class _ListingFilter implements ListingFilter {
  const _ListingFilter({this.query, this.categorySlug, this.minPrice, this.maxPrice,  List<ListingCondition>? conditions,  List<PropulsionType>? propulsions, this.minJoule, this.maxJoule, this.ships, this.lat, this.lng, this.radiusKm, this.sort = SortOption.newest}): _conditions = conditions,_propulsions = propulsions;
  

@override final  String? query;
@override final  String? categorySlug;
@override final  int? minPrice;
@override final  int? maxPrice;
 final  List<ListingCondition>? _conditions;
@override List<ListingCondition>? get conditions {
  final value = _conditions;
  if (value == null) return null;
  if (_conditions is EqualUnmodifiableListView) return _conditions;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(value);
}

 final  List<PropulsionType>? _propulsions;
@override List<PropulsionType>? get propulsions {
  final value = _propulsions;
  if (value == null) return null;
  if (_propulsions is EqualUnmodifiableListView) return _propulsions;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(value);
}

@override final  double? minJoule;
@override final  double? maxJoule;
@override final  bool? ships;
@override final  double? lat;
@override final  double? lng;
@override final  int? radiusKm;
@override@JsonKey() final  SortOption sort;

/// Create a copy of ListingFilter
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ListingFilterCopyWith<_ListingFilter> get copyWith => __$ListingFilterCopyWithImpl<_ListingFilter>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ListingFilter&&(identical(other.query, query) || other.query == query)&&(identical(other.categorySlug, categorySlug) || other.categorySlug == categorySlug)&&(identical(other.minPrice, minPrice) || other.minPrice == minPrice)&&(identical(other.maxPrice, maxPrice) || other.maxPrice == maxPrice)&&const DeepCollectionEquality().equals(other._conditions, _conditions)&&const DeepCollectionEquality().equals(other._propulsions, _propulsions)&&(identical(other.minJoule, minJoule) || other.minJoule == minJoule)&&(identical(other.maxJoule, maxJoule) || other.maxJoule == maxJoule)&&(identical(other.ships, ships) || other.ships == ships)&&(identical(other.lat, lat) || other.lat == lat)&&(identical(other.lng, lng) || other.lng == lng)&&(identical(other.radiusKm, radiusKm) || other.radiusKm == radiusKm)&&(identical(other.sort, sort) || other.sort == sort));
}


@override
int get hashCode => Object.hash(runtimeType,query,categorySlug,minPrice,maxPrice,const DeepCollectionEquality().hash(_conditions),const DeepCollectionEquality().hash(_propulsions),minJoule,maxJoule,ships,lat,lng,radiusKm,sort);

@override
String toString() {
  return 'ListingFilter(query: $query, categorySlug: $categorySlug, minPrice: $minPrice, maxPrice: $maxPrice, conditions: $conditions, propulsions: $propulsions, minJoule: $minJoule, maxJoule: $maxJoule, ships: $ships, lat: $lat, lng: $lng, radiusKm: $radiusKm, sort: $sort)';
}


}

/// @nodoc
abstract mixin class _$ListingFilterCopyWith<$Res> implements $ListingFilterCopyWith<$Res> {
  factory _$ListingFilterCopyWith(_ListingFilter value, $Res Function(_ListingFilter) _then) = __$ListingFilterCopyWithImpl;
@override @useResult
$Res call({
 String? query, String? categorySlug, int? minPrice, int? maxPrice, List<ListingCondition>? conditions, List<PropulsionType>? propulsions, double? minJoule, double? maxJoule, bool? ships, double? lat, double? lng, int? radiusKm, SortOption sort
});




}
/// @nodoc
class __$ListingFilterCopyWithImpl<$Res>
    implements _$ListingFilterCopyWith<$Res> {
  __$ListingFilterCopyWithImpl(this._self, this._then);

  final _ListingFilter _self;
  final $Res Function(_ListingFilter) _then;

/// Create a copy of ListingFilter
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? query = freezed,Object? categorySlug = freezed,Object? minPrice = freezed,Object? maxPrice = freezed,Object? conditions = freezed,Object? propulsions = freezed,Object? minJoule = freezed,Object? maxJoule = freezed,Object? ships = freezed,Object? lat = freezed,Object? lng = freezed,Object? radiusKm = freezed,Object? sort = null,}) {
  return _then(_ListingFilter(
query: freezed == query ? _self.query : query // ignore: cast_nullable_to_non_nullable
as String?,categorySlug: freezed == categorySlug ? _self.categorySlug : categorySlug // ignore: cast_nullable_to_non_nullable
as String?,minPrice: freezed == minPrice ? _self.minPrice : minPrice // ignore: cast_nullable_to_non_nullable
as int?,maxPrice: freezed == maxPrice ? _self.maxPrice : maxPrice // ignore: cast_nullable_to_non_nullable
as int?,conditions: freezed == conditions ? _self._conditions : conditions // ignore: cast_nullable_to_non_nullable
as List<ListingCondition>?,propulsions: freezed == propulsions ? _self._propulsions : propulsions // ignore: cast_nullable_to_non_nullable
as List<PropulsionType>?,minJoule: freezed == minJoule ? _self.minJoule : minJoule // ignore: cast_nullable_to_non_nullable
as double?,maxJoule: freezed == maxJoule ? _self.maxJoule : maxJoule // ignore: cast_nullable_to_non_nullable
as double?,ships: freezed == ships ? _self.ships : ships // ignore: cast_nullable_to_non_nullable
as bool?,lat: freezed == lat ? _self.lat : lat // ignore: cast_nullable_to_non_nullable
as double?,lng: freezed == lng ? _self.lng : lng // ignore: cast_nullable_to_non_nullable
as double?,radiusKm: freezed == radiusKm ? _self.radiusKm : radiusKm // ignore: cast_nullable_to_non_nullable
as int?,sort: null == sort ? _self.sort : sort // ignore: cast_nullable_to_non_nullable
as SortOption,
  ));
}


}

// dart format on
