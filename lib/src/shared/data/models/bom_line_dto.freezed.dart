// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'bom_line_dto.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$BomLineDTO {

 String get recipeId; String get ingredientId;@JsonKey(readValue: _readQuantity) QuantityDTO? get quantity;
/// Create a copy of BomLineDTO
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$BomLineDTOCopyWith<BomLineDTO> get copyWith => _$BomLineDTOCopyWithImpl<BomLineDTO>(this as BomLineDTO, _$identity);

  /// Serializes this BomLineDTO to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is BomLineDTO&&(identical(other.recipeId, recipeId) || other.recipeId == recipeId)&&(identical(other.ingredientId, ingredientId) || other.ingredientId == ingredientId)&&(identical(other.quantity, quantity) || other.quantity == quantity));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,recipeId,ingredientId,quantity);

@override
String toString() {
  return 'BomLineDTO(recipeId: $recipeId, ingredientId: $ingredientId, quantity: $quantity)';
}


}

/// @nodoc
abstract mixin class $BomLineDTOCopyWith<$Res>  {
  factory $BomLineDTOCopyWith(BomLineDTO value, $Res Function(BomLineDTO) _then) = _$BomLineDTOCopyWithImpl;
@useResult
$Res call({
 String recipeId, String ingredientId,@JsonKey(readValue: _readQuantity) QuantityDTO? quantity
});


$QuantityDTOCopyWith<$Res>? get quantity;

}
/// @nodoc
class _$BomLineDTOCopyWithImpl<$Res>
    implements $BomLineDTOCopyWith<$Res> {
  _$BomLineDTOCopyWithImpl(this._self, this._then);

  final BomLineDTO _self;
  final $Res Function(BomLineDTO) _then;

/// Create a copy of BomLineDTO
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? recipeId = null,Object? ingredientId = null,Object? quantity = freezed,}) {
  return _then(_self.copyWith(
recipeId: null == recipeId ? _self.recipeId : recipeId // ignore: cast_nullable_to_non_nullable
as String,ingredientId: null == ingredientId ? _self.ingredientId : ingredientId // ignore: cast_nullable_to_non_nullable
as String,quantity: freezed == quantity ? _self.quantity : quantity // ignore: cast_nullable_to_non_nullable
as QuantityDTO?,
  ));
}
/// Create a copy of BomLineDTO
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$QuantityDTOCopyWith<$Res>? get quantity {
    if (_self.quantity == null) {
    return null;
  }

  return $QuantityDTOCopyWith<$Res>(_self.quantity!, (value) {
    return _then(_self.copyWith(quantity: value));
  });
}
}


/// Adds pattern-matching-related methods to [BomLineDTO].
extension BomLineDTOPatterns on BomLineDTO {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _BomLineDTO value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _BomLineDTO() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _BomLineDTO value)  $default,){
final _that = this;
switch (_that) {
case _BomLineDTO():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _BomLineDTO value)?  $default,){
final _that = this;
switch (_that) {
case _BomLineDTO() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String recipeId,  String ingredientId, @JsonKey(readValue: _readQuantity)  QuantityDTO? quantity)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _BomLineDTO() when $default != null:
return $default(_that.recipeId,_that.ingredientId,_that.quantity);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String recipeId,  String ingredientId, @JsonKey(readValue: _readQuantity)  QuantityDTO? quantity)  $default,) {final _that = this;
switch (_that) {
case _BomLineDTO():
return $default(_that.recipeId,_that.ingredientId,_that.quantity);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String recipeId,  String ingredientId, @JsonKey(readValue: _readQuantity)  QuantityDTO? quantity)?  $default,) {final _that = this;
switch (_that) {
case _BomLineDTO() when $default != null:
return $default(_that.recipeId,_that.ingredientId,_that.quantity);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _BomLineDTO extends BomLineDTO {
  const _BomLineDTO({required this.recipeId, required this.ingredientId, @JsonKey(readValue: _readQuantity) this.quantity}): super._();
  factory _BomLineDTO.fromJson(Map<String, dynamic> json) => _$BomLineDTOFromJson(json);

@override final  String recipeId;
@override final  String ingredientId;
@override@JsonKey(readValue: _readQuantity) final  QuantityDTO? quantity;

/// Create a copy of BomLineDTO
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$BomLineDTOCopyWith<_BomLineDTO> get copyWith => __$BomLineDTOCopyWithImpl<_BomLineDTO>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$BomLineDTOToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _BomLineDTO&&(identical(other.recipeId, recipeId) || other.recipeId == recipeId)&&(identical(other.ingredientId, ingredientId) || other.ingredientId == ingredientId)&&(identical(other.quantity, quantity) || other.quantity == quantity));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,recipeId,ingredientId,quantity);

@override
String toString() {
  return 'BomLineDTO(recipeId: $recipeId, ingredientId: $ingredientId, quantity: $quantity)';
}


}

/// @nodoc
abstract mixin class _$BomLineDTOCopyWith<$Res> implements $BomLineDTOCopyWith<$Res> {
  factory _$BomLineDTOCopyWith(_BomLineDTO value, $Res Function(_BomLineDTO) _then) = __$BomLineDTOCopyWithImpl;
@override @useResult
$Res call({
 String recipeId, String ingredientId,@JsonKey(readValue: _readQuantity) QuantityDTO? quantity
});


@override $QuantityDTOCopyWith<$Res>? get quantity;

}
/// @nodoc
class __$BomLineDTOCopyWithImpl<$Res>
    implements _$BomLineDTOCopyWith<$Res> {
  __$BomLineDTOCopyWithImpl(this._self, this._then);

  final _BomLineDTO _self;
  final $Res Function(_BomLineDTO) _then;

/// Create a copy of BomLineDTO
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? recipeId = null,Object? ingredientId = null,Object? quantity = freezed,}) {
  return _then(_BomLineDTO(
recipeId: null == recipeId ? _self.recipeId : recipeId // ignore: cast_nullable_to_non_nullable
as String,ingredientId: null == ingredientId ? _self.ingredientId : ingredientId // ignore: cast_nullable_to_non_nullable
as String,quantity: freezed == quantity ? _self.quantity : quantity // ignore: cast_nullable_to_non_nullable
as QuantityDTO?,
  ));
}

/// Create a copy of BomLineDTO
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$QuantityDTOCopyWith<$Res>? get quantity {
    if (_self.quantity == null) {
    return null;
  }

  return $QuantityDTOCopyWith<$Res>(_self.quantity!, (value) {
    return _then(_self.copyWith(quantity: value));
  });
}
}

// dart format on
