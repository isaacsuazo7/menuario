// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'cook_target_dto.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$CookTargetDTO {

 int get weekday; String get targetDay; String get slot; String get group;
/// Create a copy of CookTargetDTO
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CookTargetDTOCopyWith<CookTargetDTO> get copyWith => _$CookTargetDTOCopyWithImpl<CookTargetDTO>(this as CookTargetDTO, _$identity);

  /// Serializes this CookTargetDTO to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CookTargetDTO&&(identical(other.weekday, weekday) || other.weekday == weekday)&&(identical(other.targetDay, targetDay) || other.targetDay == targetDay)&&(identical(other.slot, slot) || other.slot == slot)&&(identical(other.group, group) || other.group == group));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,weekday,targetDay,slot,group);

@override
String toString() {
  return 'CookTargetDTO(weekday: $weekday, targetDay: $targetDay, slot: $slot, group: $group)';
}


}

/// @nodoc
abstract mixin class $CookTargetDTOCopyWith<$Res>  {
  factory $CookTargetDTOCopyWith(CookTargetDTO value, $Res Function(CookTargetDTO) _then) = _$CookTargetDTOCopyWithImpl;
@useResult
$Res call({
 int weekday, String targetDay, String slot, String group
});




}
/// @nodoc
class _$CookTargetDTOCopyWithImpl<$Res>
    implements $CookTargetDTOCopyWith<$Res> {
  _$CookTargetDTOCopyWithImpl(this._self, this._then);

  final CookTargetDTO _self;
  final $Res Function(CookTargetDTO) _then;

/// Create a copy of CookTargetDTO
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? weekday = null,Object? targetDay = null,Object? slot = null,Object? group = null,}) {
  return _then(_self.copyWith(
weekday: null == weekday ? _self.weekday : weekday // ignore: cast_nullable_to_non_nullable
as int,targetDay: null == targetDay ? _self.targetDay : targetDay // ignore: cast_nullable_to_non_nullable
as String,slot: null == slot ? _self.slot : slot // ignore: cast_nullable_to_non_nullable
as String,group: null == group ? _self.group : group // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [CookTargetDTO].
extension CookTargetDTOPatterns on CookTargetDTO {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CookTargetDTO value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CookTargetDTO() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CookTargetDTO value)  $default,){
final _that = this;
switch (_that) {
case _CookTargetDTO():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CookTargetDTO value)?  $default,){
final _that = this;
switch (_that) {
case _CookTargetDTO() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int weekday,  String targetDay,  String slot,  String group)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CookTargetDTO() when $default != null:
return $default(_that.weekday,_that.targetDay,_that.slot,_that.group);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int weekday,  String targetDay,  String slot,  String group)  $default,) {final _that = this;
switch (_that) {
case _CookTargetDTO():
return $default(_that.weekday,_that.targetDay,_that.slot,_that.group);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int weekday,  String targetDay,  String slot,  String group)?  $default,) {final _that = this;
switch (_that) {
case _CookTargetDTO() when $default != null:
return $default(_that.weekday,_that.targetDay,_that.slot,_that.group);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _CookTargetDTO extends CookTargetDTO {
  const _CookTargetDTO({required this.weekday, required this.targetDay, required this.slot, required this.group}): super._();
  factory _CookTargetDTO.fromJson(Map<String, dynamic> json) => _$CookTargetDTOFromJson(json);

@override final  int weekday;
@override final  String targetDay;
@override final  String slot;
@override final  String group;

/// Create a copy of CookTargetDTO
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CookTargetDTOCopyWith<_CookTargetDTO> get copyWith => __$CookTargetDTOCopyWithImpl<_CookTargetDTO>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$CookTargetDTOToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _CookTargetDTO&&(identical(other.weekday, weekday) || other.weekday == weekday)&&(identical(other.targetDay, targetDay) || other.targetDay == targetDay)&&(identical(other.slot, slot) || other.slot == slot)&&(identical(other.group, group) || other.group == group));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,weekday,targetDay,slot,group);

@override
String toString() {
  return 'CookTargetDTO(weekday: $weekday, targetDay: $targetDay, slot: $slot, group: $group)';
}


}

/// @nodoc
abstract mixin class _$CookTargetDTOCopyWith<$Res> implements $CookTargetDTOCopyWith<$Res> {
  factory _$CookTargetDTOCopyWith(_CookTargetDTO value, $Res Function(_CookTargetDTO) _then) = __$CookTargetDTOCopyWithImpl;
@override @useResult
$Res call({
 int weekday, String targetDay, String slot, String group
});




}
/// @nodoc
class __$CookTargetDTOCopyWithImpl<$Res>
    implements _$CookTargetDTOCopyWith<$Res> {
  __$CookTargetDTOCopyWithImpl(this._self, this._then);

  final _CookTargetDTO _self;
  final $Res Function(_CookTargetDTO) _then;

/// Create a copy of CookTargetDTO
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? weekday = null,Object? targetDay = null,Object? slot = null,Object? group = null,}) {
  return _then(_CookTargetDTO(
weekday: null == weekday ? _self.weekday : weekday // ignore: cast_nullable_to_non_nullable
as int,targetDay: null == targetDay ? _self.targetDay : targetDay // ignore: cast_nullable_to_non_nullable
as String,slot: null == slot ? _self.slot : slot // ignore: cast_nullable_to_non_nullable
as String,group: null == group ? _self.group : group // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
