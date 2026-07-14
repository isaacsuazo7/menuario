// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'plan_entry_dto.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$PlanEntryDTO {

 String get day; String get mealSlot; String get recipeId; bool get cooked;
/// Create a copy of PlanEntryDTO
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PlanEntryDTOCopyWith<PlanEntryDTO> get copyWith => _$PlanEntryDTOCopyWithImpl<PlanEntryDTO>(this as PlanEntryDTO, _$identity);

  /// Serializes this PlanEntryDTO to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PlanEntryDTO&&(identical(other.day, day) || other.day == day)&&(identical(other.mealSlot, mealSlot) || other.mealSlot == mealSlot)&&(identical(other.recipeId, recipeId) || other.recipeId == recipeId)&&(identical(other.cooked, cooked) || other.cooked == cooked));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,day,mealSlot,recipeId,cooked);

@override
String toString() {
  return 'PlanEntryDTO(day: $day, mealSlot: $mealSlot, recipeId: $recipeId, cooked: $cooked)';
}


}

/// @nodoc
abstract mixin class $PlanEntryDTOCopyWith<$Res>  {
  factory $PlanEntryDTOCopyWith(PlanEntryDTO value, $Res Function(PlanEntryDTO) _then) = _$PlanEntryDTOCopyWithImpl;
@useResult
$Res call({
 String day, String mealSlot, String recipeId, bool cooked
});




}
/// @nodoc
class _$PlanEntryDTOCopyWithImpl<$Res>
    implements $PlanEntryDTOCopyWith<$Res> {
  _$PlanEntryDTOCopyWithImpl(this._self, this._then);

  final PlanEntryDTO _self;
  final $Res Function(PlanEntryDTO) _then;

/// Create a copy of PlanEntryDTO
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? day = null,Object? mealSlot = null,Object? recipeId = null,Object? cooked = null,}) {
  return _then(_self.copyWith(
day: null == day ? _self.day : day // ignore: cast_nullable_to_non_nullable
as String,mealSlot: null == mealSlot ? _self.mealSlot : mealSlot // ignore: cast_nullable_to_non_nullable
as String,recipeId: null == recipeId ? _self.recipeId : recipeId // ignore: cast_nullable_to_non_nullable
as String,cooked: null == cooked ? _self.cooked : cooked // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [PlanEntryDTO].
extension PlanEntryDTOPatterns on PlanEntryDTO {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PlanEntryDTO value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PlanEntryDTO() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PlanEntryDTO value)  $default,){
final _that = this;
switch (_that) {
case _PlanEntryDTO():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PlanEntryDTO value)?  $default,){
final _that = this;
switch (_that) {
case _PlanEntryDTO() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String day,  String mealSlot,  String recipeId,  bool cooked)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PlanEntryDTO() when $default != null:
return $default(_that.day,_that.mealSlot,_that.recipeId,_that.cooked);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String day,  String mealSlot,  String recipeId,  bool cooked)  $default,) {final _that = this;
switch (_that) {
case _PlanEntryDTO():
return $default(_that.day,_that.mealSlot,_that.recipeId,_that.cooked);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String day,  String mealSlot,  String recipeId,  bool cooked)?  $default,) {final _that = this;
switch (_that) {
case _PlanEntryDTO() when $default != null:
return $default(_that.day,_that.mealSlot,_that.recipeId,_that.cooked);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _PlanEntryDTO extends PlanEntryDTO {
  const _PlanEntryDTO({required this.day, required this.mealSlot, required this.recipeId, required this.cooked}): super._();
  factory _PlanEntryDTO.fromJson(Map<String, dynamic> json) => _$PlanEntryDTOFromJson(json);

@override final  String day;
@override final  String mealSlot;
@override final  String recipeId;
@override final  bool cooked;

/// Create a copy of PlanEntryDTO
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PlanEntryDTOCopyWith<_PlanEntryDTO> get copyWith => __$PlanEntryDTOCopyWithImpl<_PlanEntryDTO>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$PlanEntryDTOToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _PlanEntryDTO&&(identical(other.day, day) || other.day == day)&&(identical(other.mealSlot, mealSlot) || other.mealSlot == mealSlot)&&(identical(other.recipeId, recipeId) || other.recipeId == recipeId)&&(identical(other.cooked, cooked) || other.cooked == cooked));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,day,mealSlot,recipeId,cooked);

@override
String toString() {
  return 'PlanEntryDTO(day: $day, mealSlot: $mealSlot, recipeId: $recipeId, cooked: $cooked)';
}


}

/// @nodoc
abstract mixin class _$PlanEntryDTOCopyWith<$Res> implements $PlanEntryDTOCopyWith<$Res> {
  factory _$PlanEntryDTOCopyWith(_PlanEntryDTO value, $Res Function(_PlanEntryDTO) _then) = __$PlanEntryDTOCopyWithImpl;
@override @useResult
$Res call({
 String day, String mealSlot, String recipeId, bool cooked
});




}
/// @nodoc
class __$PlanEntryDTOCopyWithImpl<$Res>
    implements _$PlanEntryDTOCopyWith<$Res> {
  __$PlanEntryDTOCopyWithImpl(this._self, this._then);

  final _PlanEntryDTO _self;
  final $Res Function(_PlanEntryDTO) _then;

/// Create a copy of PlanEntryDTO
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? day = null,Object? mealSlot = null,Object? recipeId = null,Object? cooked = null,}) {
  return _then(_PlanEntryDTO(
day: null == day ? _self.day : day // ignore: cast_nullable_to_non_nullable
as String,mealSlot: null == mealSlot ? _self.mealSlot : mealSlot // ignore: cast_nullable_to_non_nullable
as String,recipeId: null == recipeId ? _self.recipeId : recipeId // ignore: cast_nullable_to_non_nullable
as String,cooked: null == cooked ? _self.cooked : cooked // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

// dart format on
