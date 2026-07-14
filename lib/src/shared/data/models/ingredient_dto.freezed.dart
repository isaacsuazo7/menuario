// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'ingredient_dto.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$IngredientDTO {

 String get name; String? get emoji; String get category; String get measurementKind; bool get booleanTracked; num? get conversionFactor;
/// Create a copy of IngredientDTO
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$IngredientDTOCopyWith<IngredientDTO> get copyWith => _$IngredientDTOCopyWithImpl<IngredientDTO>(this as IngredientDTO, _$identity);

  /// Serializes this IngredientDTO to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is IngredientDTO&&(identical(other.name, name) || other.name == name)&&(identical(other.emoji, emoji) || other.emoji == emoji)&&(identical(other.category, category) || other.category == category)&&(identical(other.measurementKind, measurementKind) || other.measurementKind == measurementKind)&&(identical(other.booleanTracked, booleanTracked) || other.booleanTracked == booleanTracked)&&(identical(other.conversionFactor, conversionFactor) || other.conversionFactor == conversionFactor));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,name,emoji,category,measurementKind,booleanTracked,conversionFactor);

@override
String toString() {
  return 'IngredientDTO(name: $name, emoji: $emoji, category: $category, measurementKind: $measurementKind, booleanTracked: $booleanTracked, conversionFactor: $conversionFactor)';
}


}

/// @nodoc
abstract mixin class $IngredientDTOCopyWith<$Res>  {
  factory $IngredientDTOCopyWith(IngredientDTO value, $Res Function(IngredientDTO) _then) = _$IngredientDTOCopyWithImpl;
@useResult
$Res call({
 String name, String? emoji, String category, String measurementKind, bool booleanTracked, num? conversionFactor
});




}
/// @nodoc
class _$IngredientDTOCopyWithImpl<$Res>
    implements $IngredientDTOCopyWith<$Res> {
  _$IngredientDTOCopyWithImpl(this._self, this._then);

  final IngredientDTO _self;
  final $Res Function(IngredientDTO) _then;

/// Create a copy of IngredientDTO
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? name = null,Object? emoji = freezed,Object? category = null,Object? measurementKind = null,Object? booleanTracked = null,Object? conversionFactor = freezed,}) {
  return _then(_self.copyWith(
name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,emoji: freezed == emoji ? _self.emoji : emoji // ignore: cast_nullable_to_non_nullable
as String?,category: null == category ? _self.category : category // ignore: cast_nullable_to_non_nullable
as String,measurementKind: null == measurementKind ? _self.measurementKind : measurementKind // ignore: cast_nullable_to_non_nullable
as String,booleanTracked: null == booleanTracked ? _self.booleanTracked : booleanTracked // ignore: cast_nullable_to_non_nullable
as bool,conversionFactor: freezed == conversionFactor ? _self.conversionFactor : conversionFactor // ignore: cast_nullable_to_non_nullable
as num?,
  ));
}

}


/// Adds pattern-matching-related methods to [IngredientDTO].
extension IngredientDTOPatterns on IngredientDTO {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _IngredientDTO value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _IngredientDTO() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _IngredientDTO value)  $default,){
final _that = this;
switch (_that) {
case _IngredientDTO():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _IngredientDTO value)?  $default,){
final _that = this;
switch (_that) {
case _IngredientDTO() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String name,  String? emoji,  String category,  String measurementKind,  bool booleanTracked,  num? conversionFactor)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _IngredientDTO() when $default != null:
return $default(_that.name,_that.emoji,_that.category,_that.measurementKind,_that.booleanTracked,_that.conversionFactor);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String name,  String? emoji,  String category,  String measurementKind,  bool booleanTracked,  num? conversionFactor)  $default,) {final _that = this;
switch (_that) {
case _IngredientDTO():
return $default(_that.name,_that.emoji,_that.category,_that.measurementKind,_that.booleanTracked,_that.conversionFactor);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String name,  String? emoji,  String category,  String measurementKind,  bool booleanTracked,  num? conversionFactor)?  $default,) {final _that = this;
switch (_that) {
case _IngredientDTO() when $default != null:
return $default(_that.name,_that.emoji,_that.category,_that.measurementKind,_that.booleanTracked,_that.conversionFactor);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _IngredientDTO extends IngredientDTO {
  const _IngredientDTO({required this.name, this.emoji, required this.category, required this.measurementKind, required this.booleanTracked, this.conversionFactor}): super._();
  factory _IngredientDTO.fromJson(Map<String, dynamic> json) => _$IngredientDTOFromJson(json);

@override final  String name;
@override final  String? emoji;
@override final  String category;
@override final  String measurementKind;
@override final  bool booleanTracked;
@override final  num? conversionFactor;

/// Create a copy of IngredientDTO
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$IngredientDTOCopyWith<_IngredientDTO> get copyWith => __$IngredientDTOCopyWithImpl<_IngredientDTO>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$IngredientDTOToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _IngredientDTO&&(identical(other.name, name) || other.name == name)&&(identical(other.emoji, emoji) || other.emoji == emoji)&&(identical(other.category, category) || other.category == category)&&(identical(other.measurementKind, measurementKind) || other.measurementKind == measurementKind)&&(identical(other.booleanTracked, booleanTracked) || other.booleanTracked == booleanTracked)&&(identical(other.conversionFactor, conversionFactor) || other.conversionFactor == conversionFactor));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,name,emoji,category,measurementKind,booleanTracked,conversionFactor);

@override
String toString() {
  return 'IngredientDTO(name: $name, emoji: $emoji, category: $category, measurementKind: $measurementKind, booleanTracked: $booleanTracked, conversionFactor: $conversionFactor)';
}


}

/// @nodoc
abstract mixin class _$IngredientDTOCopyWith<$Res> implements $IngredientDTOCopyWith<$Res> {
  factory _$IngredientDTOCopyWith(_IngredientDTO value, $Res Function(_IngredientDTO) _then) = __$IngredientDTOCopyWithImpl;
@override @useResult
$Res call({
 String name, String? emoji, String category, String measurementKind, bool booleanTracked, num? conversionFactor
});




}
/// @nodoc
class __$IngredientDTOCopyWithImpl<$Res>
    implements _$IngredientDTOCopyWith<$Res> {
  __$IngredientDTOCopyWithImpl(this._self, this._then);

  final _IngredientDTO _self;
  final $Res Function(_IngredientDTO) _then;

/// Create a copy of IngredientDTO
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? name = null,Object? emoji = freezed,Object? category = null,Object? measurementKind = null,Object? booleanTracked = null,Object? conversionFactor = freezed,}) {
  return _then(_IngredientDTO(
name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,emoji: freezed == emoji ? _self.emoji : emoji // ignore: cast_nullable_to_non_nullable
as String?,category: null == category ? _self.category : category // ignore: cast_nullable_to_non_nullable
as String,measurementKind: null == measurementKind ? _self.measurementKind : measurementKind // ignore: cast_nullable_to_non_nullable
as String,booleanTracked: null == booleanTracked ? _self.booleanTracked : booleanTracked // ignore: cast_nullable_to_non_nullable
as bool,conversionFactor: freezed == conversionFactor ? _self.conversionFactor : conversionFactor // ignore: cast_nullable_to_non_nullable
as num?,
  ));
}


}

// dart format on
