// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'recipe_dto.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$RecipeDTO {

 String get name; String? get emoji; List<BomLineDTO> get bomLines;
/// Create a copy of RecipeDTO
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$RecipeDTOCopyWith<RecipeDTO> get copyWith => _$RecipeDTOCopyWithImpl<RecipeDTO>(this as RecipeDTO, _$identity);

  /// Serializes this RecipeDTO to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is RecipeDTO&&(identical(other.name, name) || other.name == name)&&(identical(other.emoji, emoji) || other.emoji == emoji)&&const DeepCollectionEquality().equals(other.bomLines, bomLines));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,name,emoji,const DeepCollectionEquality().hash(bomLines));

@override
String toString() {
  return 'RecipeDTO(name: $name, emoji: $emoji, bomLines: $bomLines)';
}


}

/// @nodoc
abstract mixin class $RecipeDTOCopyWith<$Res>  {
  factory $RecipeDTOCopyWith(RecipeDTO value, $Res Function(RecipeDTO) _then) = _$RecipeDTOCopyWithImpl;
@useResult
$Res call({
 String name, String? emoji, List<BomLineDTO> bomLines
});




}
/// @nodoc
class _$RecipeDTOCopyWithImpl<$Res>
    implements $RecipeDTOCopyWith<$Res> {
  _$RecipeDTOCopyWithImpl(this._self, this._then);

  final RecipeDTO _self;
  final $Res Function(RecipeDTO) _then;

/// Create a copy of RecipeDTO
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? name = null,Object? emoji = freezed,Object? bomLines = null,}) {
  return _then(_self.copyWith(
name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,emoji: freezed == emoji ? _self.emoji : emoji // ignore: cast_nullable_to_non_nullable
as String?,bomLines: null == bomLines ? _self.bomLines : bomLines // ignore: cast_nullable_to_non_nullable
as List<BomLineDTO>,
  ));
}

}


/// Adds pattern-matching-related methods to [RecipeDTO].
extension RecipeDTOPatterns on RecipeDTO {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _RecipeDTO value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _RecipeDTO() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _RecipeDTO value)  $default,){
final _that = this;
switch (_that) {
case _RecipeDTO():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _RecipeDTO value)?  $default,){
final _that = this;
switch (_that) {
case _RecipeDTO() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String name,  String? emoji,  List<BomLineDTO> bomLines)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _RecipeDTO() when $default != null:
return $default(_that.name,_that.emoji,_that.bomLines);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String name,  String? emoji,  List<BomLineDTO> bomLines)  $default,) {final _that = this;
switch (_that) {
case _RecipeDTO():
return $default(_that.name,_that.emoji,_that.bomLines);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String name,  String? emoji,  List<BomLineDTO> bomLines)?  $default,) {final _that = this;
switch (_that) {
case _RecipeDTO() when $default != null:
return $default(_that.name,_that.emoji,_that.bomLines);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _RecipeDTO extends RecipeDTO {
  const _RecipeDTO({required this.name, this.emoji, required final  List<BomLineDTO> bomLines}): _bomLines = bomLines,super._();
  factory _RecipeDTO.fromJson(Map<String, dynamic> json) => _$RecipeDTOFromJson(json);

@override final  String name;
@override final  String? emoji;
 final  List<BomLineDTO> _bomLines;
@override List<BomLineDTO> get bomLines {
  if (_bomLines is EqualUnmodifiableListView) return _bomLines;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_bomLines);
}


/// Create a copy of RecipeDTO
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$RecipeDTOCopyWith<_RecipeDTO> get copyWith => __$RecipeDTOCopyWithImpl<_RecipeDTO>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$RecipeDTOToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _RecipeDTO&&(identical(other.name, name) || other.name == name)&&(identical(other.emoji, emoji) || other.emoji == emoji)&&const DeepCollectionEquality().equals(other._bomLines, _bomLines));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,name,emoji,const DeepCollectionEquality().hash(_bomLines));

@override
String toString() {
  return 'RecipeDTO(name: $name, emoji: $emoji, bomLines: $bomLines)';
}


}

/// @nodoc
abstract mixin class _$RecipeDTOCopyWith<$Res> implements $RecipeDTOCopyWith<$Res> {
  factory _$RecipeDTOCopyWith(_RecipeDTO value, $Res Function(_RecipeDTO) _then) = __$RecipeDTOCopyWithImpl;
@override @useResult
$Res call({
 String name, String? emoji, List<BomLineDTO> bomLines
});




}
/// @nodoc
class __$RecipeDTOCopyWithImpl<$Res>
    implements _$RecipeDTOCopyWith<$Res> {
  __$RecipeDTOCopyWithImpl(this._self, this._then);

  final _RecipeDTO _self;
  final $Res Function(_RecipeDTO) _then;

/// Create a copy of RecipeDTO
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? name = null,Object? emoji = freezed,Object? bomLines = null,}) {
  return _then(_RecipeDTO(
name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,emoji: freezed == emoji ? _self.emoji : emoji // ignore: cast_nullable_to_non_nullable
as String?,bomLines: null == bomLines ? _self._bomLines : bomLines // ignore: cast_nullable_to_non_nullable
as List<BomLineDTO>,
  ));
}


}

// dart format on
