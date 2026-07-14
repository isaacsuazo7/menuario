// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'quantity_dto.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$QuantityDTO {

 num get value; String get unitSymbol; String get unitDimension;
/// Create a copy of QuantityDTO
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$QuantityDTOCopyWith<QuantityDTO> get copyWith => _$QuantityDTOCopyWithImpl<QuantityDTO>(this as QuantityDTO, _$identity);

  /// Serializes this QuantityDTO to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is QuantityDTO&&(identical(other.value, value) || other.value == value)&&(identical(other.unitSymbol, unitSymbol) || other.unitSymbol == unitSymbol)&&(identical(other.unitDimension, unitDimension) || other.unitDimension == unitDimension));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,value,unitSymbol,unitDimension);

@override
String toString() {
  return 'QuantityDTO(value: $value, unitSymbol: $unitSymbol, unitDimension: $unitDimension)';
}


}

/// @nodoc
abstract mixin class $QuantityDTOCopyWith<$Res>  {
  factory $QuantityDTOCopyWith(QuantityDTO value, $Res Function(QuantityDTO) _then) = _$QuantityDTOCopyWithImpl;
@useResult
$Res call({
 num value, String unitSymbol, String unitDimension
});




}
/// @nodoc
class _$QuantityDTOCopyWithImpl<$Res>
    implements $QuantityDTOCopyWith<$Res> {
  _$QuantityDTOCopyWithImpl(this._self, this._then);

  final QuantityDTO _self;
  final $Res Function(QuantityDTO) _then;

/// Create a copy of QuantityDTO
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? value = null,Object? unitSymbol = null,Object? unitDimension = null,}) {
  return _then(_self.copyWith(
value: null == value ? _self.value : value // ignore: cast_nullable_to_non_nullable
as num,unitSymbol: null == unitSymbol ? _self.unitSymbol : unitSymbol // ignore: cast_nullable_to_non_nullable
as String,unitDimension: null == unitDimension ? _self.unitDimension : unitDimension // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [QuantityDTO].
extension QuantityDTOPatterns on QuantityDTO {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _QuantityDTO value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _QuantityDTO() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _QuantityDTO value)  $default,){
final _that = this;
switch (_that) {
case _QuantityDTO():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _QuantityDTO value)?  $default,){
final _that = this;
switch (_that) {
case _QuantityDTO() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( num value,  String unitSymbol,  String unitDimension)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _QuantityDTO() when $default != null:
return $default(_that.value,_that.unitSymbol,_that.unitDimension);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( num value,  String unitSymbol,  String unitDimension)  $default,) {final _that = this;
switch (_that) {
case _QuantityDTO():
return $default(_that.value,_that.unitSymbol,_that.unitDimension);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( num value,  String unitSymbol,  String unitDimension)?  $default,) {final _that = this;
switch (_that) {
case _QuantityDTO() when $default != null:
return $default(_that.value,_that.unitSymbol,_that.unitDimension);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _QuantityDTO extends QuantityDTO {
  const _QuantityDTO({required this.value, required this.unitSymbol, required this.unitDimension}): super._();
  factory _QuantityDTO.fromJson(Map<String, dynamic> json) => _$QuantityDTOFromJson(json);

@override final  num value;
@override final  String unitSymbol;
@override final  String unitDimension;

/// Create a copy of QuantityDTO
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$QuantityDTOCopyWith<_QuantityDTO> get copyWith => __$QuantityDTOCopyWithImpl<_QuantityDTO>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$QuantityDTOToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _QuantityDTO&&(identical(other.value, value) || other.value == value)&&(identical(other.unitSymbol, unitSymbol) || other.unitSymbol == unitSymbol)&&(identical(other.unitDimension, unitDimension) || other.unitDimension == unitDimension));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,value,unitSymbol,unitDimension);

@override
String toString() {
  return 'QuantityDTO(value: $value, unitSymbol: $unitSymbol, unitDimension: $unitDimension)';
}


}

/// @nodoc
abstract mixin class _$QuantityDTOCopyWith<$Res> implements $QuantityDTOCopyWith<$Res> {
  factory _$QuantityDTOCopyWith(_QuantityDTO value, $Res Function(_QuantityDTO) _then) = __$QuantityDTOCopyWithImpl;
@override @useResult
$Res call({
 num value, String unitSymbol, String unitDimension
});




}
/// @nodoc
class __$QuantityDTOCopyWithImpl<$Res>
    implements _$QuantityDTOCopyWith<$Res> {
  __$QuantityDTOCopyWithImpl(this._self, this._then);

  final _QuantityDTO _self;
  final $Res Function(_QuantityDTO) _then;

/// Create a copy of QuantityDTO
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? value = null,Object? unitSymbol = null,Object? unitDimension = null,}) {
  return _then(_QuantityDTO(
value: null == value ? _self.value : value // ignore: cast_nullable_to_non_nullable
as num,unitSymbol: null == unitSymbol ? _self.unitSymbol : unitSymbol // ignore: cast_nullable_to_non_nullable
as String,unitDimension: null == unitDimension ? _self.unitDimension : unitDimension // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
