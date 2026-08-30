// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'create_listing_draft.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$DraftImage {

 String get localPath; ImageKind get kind; String? get uploadedPath;
/// Create a copy of DraftImage
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$DraftImageCopyWith<DraftImage> get copyWith => _$DraftImageCopyWithImpl<DraftImage>(this as DraftImage, _$identity);

  /// Serializes this DraftImage to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is DraftImage&&(identical(other.localPath, localPath) || other.localPath == localPath)&&(identical(other.kind, kind) || other.kind == kind)&&(identical(other.uploadedPath, uploadedPath) || other.uploadedPath == uploadedPath));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,localPath,kind,uploadedPath);

@override
String toString() {
  return 'DraftImage(localPath: $localPath, kind: $kind, uploadedPath: $uploadedPath)';
}


}

/// @nodoc
abstract mixin class $DraftImageCopyWith<$Res>  {
  factory $DraftImageCopyWith(DraftImage value, $Res Function(DraftImage) _then) = _$DraftImageCopyWithImpl;
@useResult
$Res call({
 String localPath, ImageKind kind, String? uploadedPath
});




}
/// @nodoc
class _$DraftImageCopyWithImpl<$Res>
    implements $DraftImageCopyWith<$Res> {
  _$DraftImageCopyWithImpl(this._self, this._then);

  final DraftImage _self;
  final $Res Function(DraftImage) _then;

/// Create a copy of DraftImage
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? localPath = null,Object? kind = null,Object? uploadedPath = freezed,}) {
  return _then(DraftImage(
localPath: null == localPath ? _self.localPath : localPath // ignore: cast_nullable_to_non_nullable
as String,kind: null == kind ? _self.kind : kind // ignore: cast_nullable_to_non_nullable
as ImageKind,uploadedPath: freezed == uploadedPath ? _self.uploadedPath : uploadedPath // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [DraftImage].
extension DraftImagePatterns on DraftImage {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _DraftImage value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _DraftImage() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _DraftImage value)  $default,){
final _that = this;
switch (_that) {
case _DraftImage():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _DraftImage value)?  $default,){
final _that = this;
switch (_that) {
case _DraftImage() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String localPath,  ImageKind kind,  String? uploadedPath)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _DraftImage() when $default != null:
return $default(_that.localPath,_that.kind,_that.uploadedPath);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String localPath,  ImageKind kind,  String? uploadedPath)  $default,) {final _that = this;
switch (_that) {
case _DraftImage():
return $default(_that.localPath,_that.kind,_that.uploadedPath);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String localPath,  ImageKind kind,  String? uploadedPath)?  $default,) {final _that = this;
switch (_that) {
case _DraftImage() when $default != null:
return $default(_that.localPath,_that.kind,_that.uploadedPath);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _DraftImage implements DraftImage {
  const _DraftImage({required this.localPath, required this.kind, this.uploadedPath});
  factory _DraftImage.fromJson(Map<String, dynamic> json) => _$DraftImageFromJson(json);

@override final  String localPath;
@override final  ImageKind kind;
@override final  String? uploadedPath;

/// Create a copy of DraftImage
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$DraftImageCopyWith<_DraftImage> get copyWith => __$DraftImageCopyWithImpl<_DraftImage>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$DraftImageToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _DraftImage&&(identical(other.localPath, localPath) || other.localPath == localPath)&&(identical(other.kind, kind) || other.kind == kind)&&(identical(other.uploadedPath, uploadedPath) || other.uploadedPath == uploadedPath));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,localPath,kind,uploadedPath);

@override
String toString() {
  return 'DraftImage(localPath: $localPath, kind: $kind, uploadedPath: $uploadedPath)';
}


}

/// @nodoc
abstract mixin class _$DraftImageCopyWith<$Res> implements $DraftImageCopyWith<$Res> {
  factory _$DraftImageCopyWith(_DraftImage value, $Res Function(_DraftImage) _then) = __$DraftImageCopyWithImpl;
@override @useResult
$Res call({
 String localPath, ImageKind kind, String? uploadedPath
});




}
/// @nodoc
class __$DraftImageCopyWithImpl<$Res>
    implements _$DraftImageCopyWith<$Res> {
  __$DraftImageCopyWithImpl(this._self, this._then);

  final _DraftImage _self;
  final $Res Function(_DraftImage) _then;

/// Create a copy of DraftImage
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? localPath = null,Object? kind = null,Object? uploadedPath = freezed,}) {
  return _then(_DraftImage(
localPath: null == localPath ? _self.localPath : localPath // ignore: cast_nullable_to_non_nullable
as String,kind: null == kind ? _self.kind : kind // ignore: cast_nullable_to_non_nullable
as ImageKind,uploadedPath: freezed == uploadedPath ? _self.uploadedPath : uploadedPath // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}


/// @nodoc
mixin _$CreateListingDraft {

 int get step; String? get categoryId; List<DraftImage> get images; String? get title; String? get description; ListingCondition? get condition; String? get manufacturer; String? get model; double? get joule; PropulsionType? get propulsion; String? get caliber; bool get isModified; int? get priceCents; bool get negotiable; bool get isGiveaway; bool get acceptsSwap; bool get ships; bool get pickupOnly; String? get postalCode; String? get city; double? get lat; double? get lng;
/// Create a copy of CreateListingDraft
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CreateListingDraftCopyWith<CreateListingDraft> get copyWith => _$CreateListingDraftCopyWithImpl<CreateListingDraft>(this as CreateListingDraft, _$identity);

  /// Serializes this CreateListingDraft to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CreateListingDraft&&(identical(other.step, step) || other.step == step)&&(identical(other.categoryId, categoryId) || other.categoryId == categoryId)&&const DeepCollectionEquality().equals(other.images, images)&&(identical(other.title, title) || other.title == title)&&(identical(other.description, description) || other.description == description)&&(identical(other.condition, condition) || other.condition == condition)&&(identical(other.manufacturer, manufacturer) || other.manufacturer == manufacturer)&&(identical(other.model, model) || other.model == model)&&(identical(other.joule, joule) || other.joule == joule)&&(identical(other.propulsion, propulsion) || other.propulsion == propulsion)&&(identical(other.caliber, caliber) || other.caliber == caliber)&&(identical(other.isModified, isModified) || other.isModified == isModified)&&(identical(other.priceCents, priceCents) || other.priceCents == priceCents)&&(identical(other.negotiable, negotiable) || other.negotiable == negotiable)&&(identical(other.isGiveaway, isGiveaway) || other.isGiveaway == isGiveaway)&&(identical(other.acceptsSwap, acceptsSwap) || other.acceptsSwap == acceptsSwap)&&(identical(other.ships, ships) || other.ships == ships)&&(identical(other.pickupOnly, pickupOnly) || other.pickupOnly == pickupOnly)&&(identical(other.postalCode, postalCode) || other.postalCode == postalCode)&&(identical(other.city, city) || other.city == city)&&(identical(other.lat, lat) || other.lat == lat)&&(identical(other.lng, lng) || other.lng == lng));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hashAll([runtimeType,step,categoryId,const DeepCollectionEquality().hash(images),title,description,condition,manufacturer,model,joule,propulsion,caliber,isModified,priceCents,negotiable,isGiveaway,acceptsSwap,ships,pickupOnly,postalCode,city,lat,lng]);

@override
String toString() {
  return 'CreateListingDraft(step: $step, categoryId: $categoryId, images: $images, title: $title, description: $description, condition: $condition, manufacturer: $manufacturer, model: $model, joule: $joule, propulsion: $propulsion, caliber: $caliber, isModified: $isModified, priceCents: $priceCents, negotiable: $negotiable, isGiveaway: $isGiveaway, acceptsSwap: $acceptsSwap, ships: $ships, pickupOnly: $pickupOnly, postalCode: $postalCode, city: $city, lat: $lat, lng: $lng)';
}


}

/// @nodoc
abstract mixin class $CreateListingDraftCopyWith<$Res>  {
  factory $CreateListingDraftCopyWith(CreateListingDraft value, $Res Function(CreateListingDraft) _then) = _$CreateListingDraftCopyWithImpl;
@useResult
$Res call({
 int step, String? categoryId, List<DraftImage> images, String? title, String? description, ListingCondition? condition, String? manufacturer, String? model, double? joule, PropulsionType? propulsion, String? caliber, bool isModified, int? priceCents, bool negotiable, bool isGiveaway, bool acceptsSwap, bool ships, bool pickupOnly, String? postalCode, String? city, double? lat, double? lng
});




}
/// @nodoc
class _$CreateListingDraftCopyWithImpl<$Res>
    implements $CreateListingDraftCopyWith<$Res> {
  _$CreateListingDraftCopyWithImpl(this._self, this._then);

  final CreateListingDraft _self;
  final $Res Function(CreateListingDraft) _then;

/// Create a copy of CreateListingDraft
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? step = null,Object? categoryId = freezed,Object? images = null,Object? title = freezed,Object? description = freezed,Object? condition = freezed,Object? manufacturer = freezed,Object? model = freezed,Object? joule = freezed,Object? propulsion = freezed,Object? caliber = freezed,Object? isModified = null,Object? priceCents = freezed,Object? negotiable = null,Object? isGiveaway = null,Object? acceptsSwap = null,Object? ships = null,Object? pickupOnly = null,Object? postalCode = freezed,Object? city = freezed,Object? lat = freezed,Object? lng = freezed,}) {
  return _then(CreateListingDraft(
step: null == step ? _self.step : step // ignore: cast_nullable_to_non_nullable
as int,categoryId: freezed == categoryId ? _self.categoryId : categoryId // ignore: cast_nullable_to_non_nullable
as String?,images: null == images ? _self.images : images // ignore: cast_nullable_to_non_nullable
as List<DraftImage>,title: freezed == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String?,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,condition: freezed == condition ? _self.condition : condition // ignore: cast_nullable_to_non_nullable
as ListingCondition?,manufacturer: freezed == manufacturer ? _self.manufacturer : manufacturer // ignore: cast_nullable_to_non_nullable
as String?,model: freezed == model ? _self.model : model // ignore: cast_nullable_to_non_nullable
as String?,joule: freezed == joule ? _self.joule : joule // ignore: cast_nullable_to_non_nullable
as double?,propulsion: freezed == propulsion ? _self.propulsion : propulsion // ignore: cast_nullable_to_non_nullable
as PropulsionType?,caliber: freezed == caliber ? _self.caliber : caliber // ignore: cast_nullable_to_non_nullable
as String?,isModified: null == isModified ? _self.isModified : isModified // ignore: cast_nullable_to_non_nullable
as bool,priceCents: freezed == priceCents ? _self.priceCents : priceCents // ignore: cast_nullable_to_non_nullable
as int?,negotiable: null == negotiable ? _self.negotiable : negotiable // ignore: cast_nullable_to_non_nullable
as bool,isGiveaway: null == isGiveaway ? _self.isGiveaway : isGiveaway // ignore: cast_nullable_to_non_nullable
as bool,acceptsSwap: null == acceptsSwap ? _self.acceptsSwap : acceptsSwap // ignore: cast_nullable_to_non_nullable
as bool,ships: null == ships ? _self.ships : ships // ignore: cast_nullable_to_non_nullable
as bool,pickupOnly: null == pickupOnly ? _self.pickupOnly : pickupOnly // ignore: cast_nullable_to_non_nullable
as bool,postalCode: freezed == postalCode ? _self.postalCode : postalCode // ignore: cast_nullable_to_non_nullable
as String?,city: freezed == city ? _self.city : city // ignore: cast_nullable_to_non_nullable
as String?,lat: freezed == lat ? _self.lat : lat // ignore: cast_nullable_to_non_nullable
as double?,lng: freezed == lng ? _self.lng : lng // ignore: cast_nullable_to_non_nullable
as double?,
  ));
}

}


/// Adds pattern-matching-related methods to [CreateListingDraft].
extension CreateListingDraftPatterns on CreateListingDraft {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CreateListingDraft value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CreateListingDraft() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CreateListingDraft value)  $default,){
final _that = this;
switch (_that) {
case _CreateListingDraft():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CreateListingDraft value)?  $default,){
final _that = this;
switch (_that) {
case _CreateListingDraft() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int step,  String? categoryId,  List<DraftImage> images,  String? title,  String? description,  ListingCondition? condition,  String? manufacturer,  String? model,  double? joule,  PropulsionType? propulsion,  String? caliber,  bool isModified,  int? priceCents,  bool negotiable,  bool isGiveaway,  bool acceptsSwap,  bool ships,  bool pickupOnly,  String? postalCode,  String? city,  double? lat,  double? lng)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CreateListingDraft() when $default != null:
return $default(_that.step,_that.categoryId,_that.images,_that.title,_that.description,_that.condition,_that.manufacturer,_that.model,_that.joule,_that.propulsion,_that.caliber,_that.isModified,_that.priceCents,_that.negotiable,_that.isGiveaway,_that.acceptsSwap,_that.ships,_that.pickupOnly,_that.postalCode,_that.city,_that.lat,_that.lng);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int step,  String? categoryId,  List<DraftImage> images,  String? title,  String? description,  ListingCondition? condition,  String? manufacturer,  String? model,  double? joule,  PropulsionType? propulsion,  String? caliber,  bool isModified,  int? priceCents,  bool negotiable,  bool isGiveaway,  bool acceptsSwap,  bool ships,  bool pickupOnly,  String? postalCode,  String? city,  double? lat,  double? lng)  $default,) {final _that = this;
switch (_that) {
case _CreateListingDraft():
return $default(_that.step,_that.categoryId,_that.images,_that.title,_that.description,_that.condition,_that.manufacturer,_that.model,_that.joule,_that.propulsion,_that.caliber,_that.isModified,_that.priceCents,_that.negotiable,_that.isGiveaway,_that.acceptsSwap,_that.ships,_that.pickupOnly,_that.postalCode,_that.city,_that.lat,_that.lng);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int step,  String? categoryId,  List<DraftImage> images,  String? title,  String? description,  ListingCondition? condition,  String? manufacturer,  String? model,  double? joule,  PropulsionType? propulsion,  String? caliber,  bool isModified,  int? priceCents,  bool negotiable,  bool isGiveaway,  bool acceptsSwap,  bool ships,  bool pickupOnly,  String? postalCode,  String? city,  double? lat,  double? lng)?  $default,) {final _that = this;
switch (_that) {
case _CreateListingDraft() when $default != null:
return $default(_that.step,_that.categoryId,_that.images,_that.title,_that.description,_that.condition,_that.manufacturer,_that.model,_that.joule,_that.propulsion,_that.caliber,_that.isModified,_that.priceCents,_that.negotiable,_that.isGiveaway,_that.acceptsSwap,_that.ships,_that.pickupOnly,_that.postalCode,_that.city,_that.lat,_that.lng);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _CreateListingDraft extends CreateListingDraft {
  const _CreateListingDraft({this.step = 0, this.categoryId,  List<DraftImage> images = const [], this.title, this.description, this.condition, this.manufacturer, this.model, this.joule, this.propulsion, this.caliber, this.isModified = false, this.priceCents, this.negotiable = false, this.isGiveaway = false, this.acceptsSwap = false, this.ships = false, this.pickupOnly = true, this.postalCode, this.city, this.lat, this.lng}): _images = images,super._();
  factory _CreateListingDraft.fromJson(Map<String, dynamic> json) => _$CreateListingDraftFromJson(json);

@override@JsonKey() final  int step;
@override final  String? categoryId;
 final  List<DraftImage> _images;
@override@JsonKey() List<DraftImage> get images {
  if (_images is EqualUnmodifiableListView) return _images;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_images);
}

@override final  String? title;
@override final  String? description;
@override final  ListingCondition? condition;
@override final  String? manufacturer;
@override final  String? model;
@override final  double? joule;
@override final  PropulsionType? propulsion;
@override final  String? caliber;
@override@JsonKey() final  bool isModified;
@override final  int? priceCents;
@override@JsonKey() final  bool negotiable;
@override@JsonKey() final  bool isGiveaway;
@override@JsonKey() final  bool acceptsSwap;
@override@JsonKey() final  bool ships;
@override@JsonKey() final  bool pickupOnly;
@override final  String? postalCode;
@override final  String? city;
@override final  double? lat;
@override final  double? lng;

/// Create a copy of CreateListingDraft
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CreateListingDraftCopyWith<_CreateListingDraft> get copyWith => __$CreateListingDraftCopyWithImpl<_CreateListingDraft>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$CreateListingDraftToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _CreateListingDraft&&(identical(other.step, step) || other.step == step)&&(identical(other.categoryId, categoryId) || other.categoryId == categoryId)&&const DeepCollectionEquality().equals(other._images, _images)&&(identical(other.title, title) || other.title == title)&&(identical(other.description, description) || other.description == description)&&(identical(other.condition, condition) || other.condition == condition)&&(identical(other.manufacturer, manufacturer) || other.manufacturer == manufacturer)&&(identical(other.model, model) || other.model == model)&&(identical(other.joule, joule) || other.joule == joule)&&(identical(other.propulsion, propulsion) || other.propulsion == propulsion)&&(identical(other.caliber, caliber) || other.caliber == caliber)&&(identical(other.isModified, isModified) || other.isModified == isModified)&&(identical(other.priceCents, priceCents) || other.priceCents == priceCents)&&(identical(other.negotiable, negotiable) || other.negotiable == negotiable)&&(identical(other.isGiveaway, isGiveaway) || other.isGiveaway == isGiveaway)&&(identical(other.acceptsSwap, acceptsSwap) || other.acceptsSwap == acceptsSwap)&&(identical(other.ships, ships) || other.ships == ships)&&(identical(other.pickupOnly, pickupOnly) || other.pickupOnly == pickupOnly)&&(identical(other.postalCode, postalCode) || other.postalCode == postalCode)&&(identical(other.city, city) || other.city == city)&&(identical(other.lat, lat) || other.lat == lat)&&(identical(other.lng, lng) || other.lng == lng));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hashAll([runtimeType,step,categoryId,const DeepCollectionEquality().hash(_images),title,description,condition,manufacturer,model,joule,propulsion,caliber,isModified,priceCents,negotiable,isGiveaway,acceptsSwap,ships,pickupOnly,postalCode,city,lat,lng]);

@override
String toString() {
  return 'CreateListingDraft(step: $step, categoryId: $categoryId, images: $images, title: $title, description: $description, condition: $condition, manufacturer: $manufacturer, model: $model, joule: $joule, propulsion: $propulsion, caliber: $caliber, isModified: $isModified, priceCents: $priceCents, negotiable: $negotiable, isGiveaway: $isGiveaway, acceptsSwap: $acceptsSwap, ships: $ships, pickupOnly: $pickupOnly, postalCode: $postalCode, city: $city, lat: $lat, lng: $lng)';
}


}

/// @nodoc
abstract mixin class _$CreateListingDraftCopyWith<$Res> implements $CreateListingDraftCopyWith<$Res> {
  factory _$CreateListingDraftCopyWith(_CreateListingDraft value, $Res Function(_CreateListingDraft) _then) = __$CreateListingDraftCopyWithImpl;
@override @useResult
$Res call({
 int step, String? categoryId, List<DraftImage> images, String? title, String? description, ListingCondition? condition, String? manufacturer, String? model, double? joule, PropulsionType? propulsion, String? caliber, bool isModified, int? priceCents, bool negotiable, bool isGiveaway, bool acceptsSwap, bool ships, bool pickupOnly, String? postalCode, String? city, double? lat, double? lng
});




}
/// @nodoc
class __$CreateListingDraftCopyWithImpl<$Res>
    implements _$CreateListingDraftCopyWith<$Res> {
  __$CreateListingDraftCopyWithImpl(this._self, this._then);

  final _CreateListingDraft _self;
  final $Res Function(_CreateListingDraft) _then;

/// Create a copy of CreateListingDraft
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? step = null,Object? categoryId = freezed,Object? images = null,Object? title = freezed,Object? description = freezed,Object? condition = freezed,Object? manufacturer = freezed,Object? model = freezed,Object? joule = freezed,Object? propulsion = freezed,Object? caliber = freezed,Object? isModified = null,Object? priceCents = freezed,Object? negotiable = null,Object? isGiveaway = null,Object? acceptsSwap = null,Object? ships = null,Object? pickupOnly = null,Object? postalCode = freezed,Object? city = freezed,Object? lat = freezed,Object? lng = freezed,}) {
  return _then(_CreateListingDraft(
step: null == step ? _self.step : step // ignore: cast_nullable_to_non_nullable
as int,categoryId: freezed == categoryId ? _self.categoryId : categoryId // ignore: cast_nullable_to_non_nullable
as String?,images: null == images ? _self._images : images // ignore: cast_nullable_to_non_nullable
as List<DraftImage>,title: freezed == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String?,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,condition: freezed == condition ? _self.condition : condition // ignore: cast_nullable_to_non_nullable
as ListingCondition?,manufacturer: freezed == manufacturer ? _self.manufacturer : manufacturer // ignore: cast_nullable_to_non_nullable
as String?,model: freezed == model ? _self.model : model // ignore: cast_nullable_to_non_nullable
as String?,joule: freezed == joule ? _self.joule : joule // ignore: cast_nullable_to_non_nullable
as double?,propulsion: freezed == propulsion ? _self.propulsion : propulsion // ignore: cast_nullable_to_non_nullable
as PropulsionType?,caliber: freezed == caliber ? _self.caliber : caliber // ignore: cast_nullable_to_non_nullable
as String?,isModified: null == isModified ? _self.isModified : isModified // ignore: cast_nullable_to_non_nullable
as bool,priceCents: freezed == priceCents ? _self.priceCents : priceCents // ignore: cast_nullable_to_non_nullable
as int?,negotiable: null == negotiable ? _self.negotiable : negotiable // ignore: cast_nullable_to_non_nullable
as bool,isGiveaway: null == isGiveaway ? _self.isGiveaway : isGiveaway // ignore: cast_nullable_to_non_nullable
as bool,acceptsSwap: null == acceptsSwap ? _self.acceptsSwap : acceptsSwap // ignore: cast_nullable_to_non_nullable
as bool,ships: null == ships ? _self.ships : ships // ignore: cast_nullable_to_non_nullable
as bool,pickupOnly: null == pickupOnly ? _self.pickupOnly : pickupOnly // ignore: cast_nullable_to_non_nullable
as bool,postalCode: freezed == postalCode ? _self.postalCode : postalCode // ignore: cast_nullable_to_non_nullable
as String?,city: freezed == city ? _self.city : city // ignore: cast_nullable_to_non_nullable
as String?,lat: freezed == lat ? _self.lat : lat // ignore: cast_nullable_to_non_nullable
as double?,lng: freezed == lng ? _self.lng : lng // ignore: cast_nullable_to_non_nullable
as double?,
  ));
}


}

// dart format on
