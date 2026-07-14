// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'bom_line.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$BomLine {

 String get recipeId; String get ingredientId; Quantity get quantity;
/// Create a copy of BomLine
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$BomLineCopyWith<BomLine> get copyWith => _$BomLineCopyWithImpl<BomLine>(this as BomLine, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is BomLine&&(identical(other.recipeId, recipeId) || other.recipeId == recipeId)&&(identical(other.ingredientId, ingredientId) || other.ingredientId == ingredientId)&&(identical(other.quantity, quantity) || other.quantity == quantity));
}


@override
int get hashCode => Object.hash(runtimeType,recipeId,ingredientId,quantity);

@override
String toString() {
  return 'BomLine(recipeId: $recipeId, ingredientId: $ingredientId, quantity: $quantity)';
}


}

/// @nodoc
abstract mixin class $BomLineCopyWith<$Res>  {
  factory $BomLineCopyWith(BomLine value, $Res Function(BomLine) _then) = _$BomLineCopyWithImpl;
@useResult
$Res call({
 String recipeId, String ingredientId, Quantity quantity
});


$QuantityCopyWith<$Res> get quantity;

}
/// @nodoc
class _$BomLineCopyWithImpl<$Res>
    implements $BomLineCopyWith<$Res> {
  _$BomLineCopyWithImpl(this._self, this._then);

  final BomLine _self;
  final $Res Function(BomLine) _then;

/// Create a copy of BomLine
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? recipeId = null,Object? ingredientId = null,Object? quantity = null,}) {
  return _then(_self.copyWith(
recipeId: null == recipeId ? _self.recipeId : recipeId // ignore: cast_nullable_to_non_nullable
as String,ingredientId: null == ingredientId ? _self.ingredientId : ingredientId // ignore: cast_nullable_to_non_nullable
as String,quantity: null == quantity ? _self.quantity : quantity // ignore: cast_nullable_to_non_nullable
as Quantity,
  ));
}
/// Create a copy of BomLine
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$QuantityCopyWith<$Res> get quantity {
  
  return $QuantityCopyWith<$Res>(_self.quantity, (value) {
    return _then(_self.copyWith(quantity: value));
  });
}
}


/// Adds pattern-matching-related methods to [BomLine].
extension BomLinePatterns on BomLine {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _BomLine value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _BomLine() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _BomLine value)  $default,){
final _that = this;
switch (_that) {
case _BomLine():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _BomLine value)?  $default,){
final _that = this;
switch (_that) {
case _BomLine() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String recipeId,  String ingredientId,  Quantity quantity)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _BomLine() when $default != null:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String recipeId,  String ingredientId,  Quantity quantity)  $default,) {final _that = this;
switch (_that) {
case _BomLine():
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String recipeId,  String ingredientId,  Quantity quantity)?  $default,) {final _that = this;
switch (_that) {
case _BomLine() when $default != null:
return $default(_that.recipeId,_that.ingredientId,_that.quantity);case _:
  return null;

}
}

}

/// @nodoc


class _BomLine implements BomLine {
  const _BomLine({required this.recipeId, required this.ingredientId, required this.quantity});
  

@override final  String recipeId;
@override final  String ingredientId;
@override final  Quantity quantity;

/// Create a copy of BomLine
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$BomLineCopyWith<_BomLine> get copyWith => __$BomLineCopyWithImpl<_BomLine>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _BomLine&&(identical(other.recipeId, recipeId) || other.recipeId == recipeId)&&(identical(other.ingredientId, ingredientId) || other.ingredientId == ingredientId)&&(identical(other.quantity, quantity) || other.quantity == quantity));
}


@override
int get hashCode => Object.hash(runtimeType,recipeId,ingredientId,quantity);

@override
String toString() {
  return 'BomLine(recipeId: $recipeId, ingredientId: $ingredientId, quantity: $quantity)';
}


}

/// @nodoc
abstract mixin class _$BomLineCopyWith<$Res> implements $BomLineCopyWith<$Res> {
  factory _$BomLineCopyWith(_BomLine value, $Res Function(_BomLine) _then) = __$BomLineCopyWithImpl;
@override @useResult
$Res call({
 String recipeId, String ingredientId, Quantity quantity
});


@override $QuantityCopyWith<$Res> get quantity;

}
/// @nodoc
class __$BomLineCopyWithImpl<$Res>
    implements _$BomLineCopyWith<$Res> {
  __$BomLineCopyWithImpl(this._self, this._then);

  final _BomLine _self;
  final $Res Function(_BomLine) _then;

/// Create a copy of BomLine
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? recipeId = null,Object? ingredientId = null,Object? quantity = null,}) {
  return _then(_BomLine(
recipeId: null == recipeId ? _self.recipeId : recipeId // ignore: cast_nullable_to_non_nullable
as String,ingredientId: null == ingredientId ? _self.ingredientId : ingredientId // ignore: cast_nullable_to_non_nullable
as String,quantity: null == quantity ? _self.quantity : quantity // ignore: cast_nullable_to_non_nullable
as Quantity,
  ));
}

/// Create a copy of BomLine
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$QuantityCopyWith<$Res> get quantity {
  
  return $QuantityCopyWith<$Res>(_self.quantity, (value) {
    return _then(_self.copyWith(quantity: value));
  });
}
}

// dart format on
