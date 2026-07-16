// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'stock_lens.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$StockLens {

 String get label; num get canonicalPerUnit; bool get allowsDecimal;
/// Create a copy of StockLens
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$StockLensCopyWith<StockLens> get copyWith => _$StockLensCopyWithImpl<StockLens>(this as StockLens, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is StockLens&&(identical(other.label, label) || other.label == label)&&(identical(other.canonicalPerUnit, canonicalPerUnit) || other.canonicalPerUnit == canonicalPerUnit)&&(identical(other.allowsDecimal, allowsDecimal) || other.allowsDecimal == allowsDecimal));
}


@override
int get hashCode => Object.hash(runtimeType,label,canonicalPerUnit,allowsDecimal);

@override
String toString() {
  return 'StockLens(label: $label, canonicalPerUnit: $canonicalPerUnit, allowsDecimal: $allowsDecimal)';
}


}

/// @nodoc
abstract mixin class $StockLensCopyWith<$Res>  {
  factory $StockLensCopyWith(StockLens value, $Res Function(StockLens) _then) = _$StockLensCopyWithImpl;
@useResult
$Res call({
 String label, num canonicalPerUnit, bool allowsDecimal
});




}
/// @nodoc
class _$StockLensCopyWithImpl<$Res>
    implements $StockLensCopyWith<$Res> {
  _$StockLensCopyWithImpl(this._self, this._then);

  final StockLens _self;
  final $Res Function(StockLens) _then;

/// Create a copy of StockLens
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? label = null,Object? canonicalPerUnit = null,Object? allowsDecimal = null,}) {
  return _then(_self.copyWith(
label: null == label ? _self.label : label // ignore: cast_nullable_to_non_nullable
as String,canonicalPerUnit: null == canonicalPerUnit ? _self.canonicalPerUnit : canonicalPerUnit // ignore: cast_nullable_to_non_nullable
as num,allowsDecimal: null == allowsDecimal ? _self.allowsDecimal : allowsDecimal // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [StockLens].
extension StockLensPatterns on StockLens {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _StockLens value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _StockLens() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _StockLens value)  $default,){
final _that = this;
switch (_that) {
case _StockLens():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _StockLens value)?  $default,){
final _that = this;
switch (_that) {
case _StockLens() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String label,  num canonicalPerUnit,  bool allowsDecimal)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _StockLens() when $default != null:
return $default(_that.label,_that.canonicalPerUnit,_that.allowsDecimal);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String label,  num canonicalPerUnit,  bool allowsDecimal)  $default,) {final _that = this;
switch (_that) {
case _StockLens():
return $default(_that.label,_that.canonicalPerUnit,_that.allowsDecimal);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String label,  num canonicalPerUnit,  bool allowsDecimal)?  $default,) {final _that = this;
switch (_that) {
case _StockLens() when $default != null:
return $default(_that.label,_that.canonicalPerUnit,_that.allowsDecimal);case _:
  return null;

}
}

}

/// @nodoc


class _StockLens extends StockLens {
  const _StockLens({required this.label, required this.canonicalPerUnit, required this.allowsDecimal}): super._();
  

@override final  String label;
@override final  num canonicalPerUnit;
@override final  bool allowsDecimal;

/// Create a copy of StockLens
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$StockLensCopyWith<_StockLens> get copyWith => __$StockLensCopyWithImpl<_StockLens>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _StockLens&&(identical(other.label, label) || other.label == label)&&(identical(other.canonicalPerUnit, canonicalPerUnit) || other.canonicalPerUnit == canonicalPerUnit)&&(identical(other.allowsDecimal, allowsDecimal) || other.allowsDecimal == allowsDecimal));
}


@override
int get hashCode => Object.hash(runtimeType,label,canonicalPerUnit,allowsDecimal);

@override
String toString() {
  return 'StockLens(label: $label, canonicalPerUnit: $canonicalPerUnit, allowsDecimal: $allowsDecimal)';
}


}

/// @nodoc
abstract mixin class _$StockLensCopyWith<$Res> implements $StockLensCopyWith<$Res> {
  factory _$StockLensCopyWith(_StockLens value, $Res Function(_StockLens) _then) = __$StockLensCopyWithImpl;
@override @useResult
$Res call({
 String label, num canonicalPerUnit, bool allowsDecimal
});




}
/// @nodoc
class __$StockLensCopyWithImpl<$Res>
    implements _$StockLensCopyWith<$Res> {
  __$StockLensCopyWithImpl(this._self, this._then);

  final _StockLens _self;
  final $Res Function(_StockLens) _then;

/// Create a copy of StockLens
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? label = null,Object? canonicalPerUnit = null,Object? allowsDecimal = null,}) {
  return _then(_StockLens(
label: null == label ? _self.label : label // ignore: cast_nullable_to_non_nullable
as String,canonicalPerUnit: null == canonicalPerUnit ? _self.canonicalPerUnit : canonicalPerUnit // ignore: cast_nullable_to_non_nullable
as num,allowsDecimal: null == allowsDecimal ? _self.allowsDecimal : allowsDecimal // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

// dart format on
