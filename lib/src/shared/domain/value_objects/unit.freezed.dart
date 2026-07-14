// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'unit.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$Unit {

 String get symbol; UnitDimension get dimension;
/// Create a copy of Unit
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$UnitCopyWith<Unit> get copyWith => _$UnitCopyWithImpl<Unit>(this as Unit, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Unit&&(identical(other.symbol, symbol) || other.symbol == symbol)&&(identical(other.dimension, dimension) || other.dimension == dimension));
}


@override
int get hashCode => Object.hash(runtimeType,symbol,dimension);

@override
String toString() {
  return 'Unit(symbol: $symbol, dimension: $dimension)';
}


}

/// @nodoc
abstract mixin class $UnitCopyWith<$Res>  {
  factory $UnitCopyWith(Unit value, $Res Function(Unit) _then) = _$UnitCopyWithImpl;
@useResult
$Res call({
 String symbol, UnitDimension dimension
});




}
/// @nodoc
class _$UnitCopyWithImpl<$Res>
    implements $UnitCopyWith<$Res> {
  _$UnitCopyWithImpl(this._self, this._then);

  final Unit _self;
  final $Res Function(Unit) _then;

/// Create a copy of Unit
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? symbol = null,Object? dimension = null,}) {
  return _then(_self.copyWith(
symbol: null == symbol ? _self.symbol : symbol // ignore: cast_nullable_to_non_nullable
as String,dimension: null == dimension ? _self.dimension : dimension // ignore: cast_nullable_to_non_nullable
as UnitDimension,
  ));
}

}


/// Adds pattern-matching-related methods to [Unit].
extension UnitPatterns on Unit {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Unit value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Unit() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Unit value)  $default,){
final _that = this;
switch (_that) {
case _Unit():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Unit value)?  $default,){
final _that = this;
switch (_that) {
case _Unit() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String symbol,  UnitDimension dimension)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Unit() when $default != null:
return $default(_that.symbol,_that.dimension);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String symbol,  UnitDimension dimension)  $default,) {final _that = this;
switch (_that) {
case _Unit():
return $default(_that.symbol,_that.dimension);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String symbol,  UnitDimension dimension)?  $default,) {final _that = this;
switch (_that) {
case _Unit() when $default != null:
return $default(_that.symbol,_that.dimension);case _:
  return null;

}
}

}

/// @nodoc


class _Unit extends Unit {
  const _Unit({required this.symbol, required this.dimension}): super._();
  

@override final  String symbol;
@override final  UnitDimension dimension;

/// Create a copy of Unit
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$UnitCopyWith<_Unit> get copyWith => __$UnitCopyWithImpl<_Unit>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Unit&&(identical(other.symbol, symbol) || other.symbol == symbol)&&(identical(other.dimension, dimension) || other.dimension == dimension));
}


@override
int get hashCode => Object.hash(runtimeType,symbol,dimension);

@override
String toString() {
  return 'Unit(symbol: $symbol, dimension: $dimension)';
}


}

/// @nodoc
abstract mixin class _$UnitCopyWith<$Res> implements $UnitCopyWith<$Res> {
  factory _$UnitCopyWith(_Unit value, $Res Function(_Unit) _then) = __$UnitCopyWithImpl;
@override @useResult
$Res call({
 String symbol, UnitDimension dimension
});




}
/// @nodoc
class __$UnitCopyWithImpl<$Res>
    implements _$UnitCopyWith<$Res> {
  __$UnitCopyWithImpl(this._self, this._then);

  final _Unit _self;
  final $Res Function(_Unit) _then;

/// Create a copy of Unit
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? symbol = null,Object? dimension = null,}) {
  return _then(_Unit(
symbol: null == symbol ? _self.symbol : symbol // ignore: cast_nullable_to_non_nullable
as String,dimension: null == dimension ? _self.dimension : dimension // ignore: cast_nullable_to_non_nullable
as UnitDimension,
  ));
}


}

// dart format on
