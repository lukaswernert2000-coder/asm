// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'asm_user.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$AsmUser {

 String get id; String get email; bool get emailConfirmed;
/// Create a copy of AsmUser
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AsmUserCopyWith<AsmUser> get copyWith => _$AsmUserCopyWithImpl<AsmUser>(this as AsmUser, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AsmUser&&(identical(other.id, id) || other.id == id)&&(identical(other.email, email) || other.email == email)&&(identical(other.emailConfirmed, emailConfirmed) || other.emailConfirmed == emailConfirmed));
}


@override
int get hashCode => Object.hash(runtimeType,id,email,emailConfirmed);

@override
String toString() {
  return 'AsmUser(id: $id, email: $email, emailConfirmed: $emailConfirmed)';
}


}

/// @nodoc
abstract mixin class $AsmUserCopyWith<$Res>  {
  factory $AsmUserCopyWith(AsmUser value, $Res Function(AsmUser) _then) = _$AsmUserCopyWithImpl;
@useResult
$Res call({
 String id, String email, bool emailConfirmed
});




}
/// @nodoc
class _$AsmUserCopyWithImpl<$Res>
    implements $AsmUserCopyWith<$Res> {
  _$AsmUserCopyWithImpl(this._self, this._then);

  final AsmUser _self;
  final $Res Function(AsmUser) _then;

/// Create a copy of AsmUser
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? email = null,Object? emailConfirmed = null,}) {
  return _then(AsmUser(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,email: null == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String,emailConfirmed: null == emailConfirmed ? _self.emailConfirmed : emailConfirmed // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [AsmUser].
extension AsmUserPatterns on AsmUser {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _AsmUser value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _AsmUser() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _AsmUser value)  $default,){
final _that = this;
switch (_that) {
case _AsmUser():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _AsmUser value)?  $default,){
final _that = this;
switch (_that) {
case _AsmUser() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String email,  bool emailConfirmed)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _AsmUser() when $default != null:
return $default(_that.id,_that.email,_that.emailConfirmed);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String email,  bool emailConfirmed)  $default,) {final _that = this;
switch (_that) {
case _AsmUser():
return $default(_that.id,_that.email,_that.emailConfirmed);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String email,  bool emailConfirmed)?  $default,) {final _that = this;
switch (_that) {
case _AsmUser() when $default != null:
return $default(_that.id,_that.email,_that.emailConfirmed);case _:
  return null;

}
}

}

/// @nodoc


class _AsmUser implements AsmUser {
  const _AsmUser({required this.id, required this.email, required this.emailConfirmed});
  

@override final  String id;
@override final  String email;
@override final  bool emailConfirmed;

/// Create a copy of AsmUser
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AsmUserCopyWith<_AsmUser> get copyWith => __$AsmUserCopyWithImpl<_AsmUser>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _AsmUser&&(identical(other.id, id) || other.id == id)&&(identical(other.email, email) || other.email == email)&&(identical(other.emailConfirmed, emailConfirmed) || other.emailConfirmed == emailConfirmed));
}


@override
int get hashCode => Object.hash(runtimeType,id,email,emailConfirmed);

@override
String toString() {
  return 'AsmUser(id: $id, email: $email, emailConfirmed: $emailConfirmed)';
}


}

/// @nodoc
abstract mixin class _$AsmUserCopyWith<$Res> implements $AsmUserCopyWith<$Res> {
  factory _$AsmUserCopyWith(_AsmUser value, $Res Function(_AsmUser) _then) = __$AsmUserCopyWithImpl;
@override @useResult
$Res call({
 String id, String email, bool emailConfirmed
});




}
/// @nodoc
class __$AsmUserCopyWithImpl<$Res>
    implements _$AsmUserCopyWith<$Res> {
  __$AsmUserCopyWithImpl(this._self, this._then);

  final _AsmUser _self;
  final $Res Function(_AsmUser) _then;

/// Create a copy of AsmUser
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? email = null,Object? emailConfirmed = null,}) {
  return _then(_AsmUser(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,email: null == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String,emailConfirmed: null == emailConfirmed ? _self.emailConfirmed : emailConfirmed // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

// dart format on
