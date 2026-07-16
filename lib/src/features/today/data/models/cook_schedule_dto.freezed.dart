// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'cook_schedule_dto.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$CookScheduleDTO {

 List<CookTargetDTO> get targets;
/// Create a copy of CookScheduleDTO
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CookScheduleDTOCopyWith<CookScheduleDTO> get copyWith => _$CookScheduleDTOCopyWithImpl<CookScheduleDTO>(this as CookScheduleDTO, _$identity);

  /// Serializes this CookScheduleDTO to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CookScheduleDTO&&const DeepCollectionEquality().equals(other.targets, targets));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(targets));

@override
String toString() {
  return 'CookScheduleDTO(targets: $targets)';
}


}

/// @nodoc
abstract mixin class $CookScheduleDTOCopyWith<$Res>  {
  factory $CookScheduleDTOCopyWith(CookScheduleDTO value, $Res Function(CookScheduleDTO) _then) = _$CookScheduleDTOCopyWithImpl;
@useResult
$Res call({
 List<CookTargetDTO> targets
});




}
/// @nodoc
class _$CookScheduleDTOCopyWithImpl<$Res>
    implements $CookScheduleDTOCopyWith<$Res> {
  _$CookScheduleDTOCopyWithImpl(this._self, this._then);

  final CookScheduleDTO _self;
  final $Res Function(CookScheduleDTO) _then;

/// Create a copy of CookScheduleDTO
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? targets = null,}) {
  return _then(_self.copyWith(
targets: null == targets ? _self.targets : targets // ignore: cast_nullable_to_non_nullable
as List<CookTargetDTO>,
  ));
}

}


/// Adds pattern-matching-related methods to [CookScheduleDTO].
extension CookScheduleDTOPatterns on CookScheduleDTO {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CookScheduleDTO value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CookScheduleDTO() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CookScheduleDTO value)  $default,){
final _that = this;
switch (_that) {
case _CookScheduleDTO():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CookScheduleDTO value)?  $default,){
final _that = this;
switch (_that) {
case _CookScheduleDTO() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( List<CookTargetDTO> targets)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CookScheduleDTO() when $default != null:
return $default(_that.targets);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( List<CookTargetDTO> targets)  $default,) {final _that = this;
switch (_that) {
case _CookScheduleDTO():
return $default(_that.targets);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( List<CookTargetDTO> targets)?  $default,) {final _that = this;
switch (_that) {
case _CookScheduleDTO() when $default != null:
return $default(_that.targets);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _CookScheduleDTO extends CookScheduleDTO {
  const _CookScheduleDTO({required final  List<CookTargetDTO> targets}): _targets = targets,super._();
  factory _CookScheduleDTO.fromJson(Map<String, dynamic> json) => _$CookScheduleDTOFromJson(json);

 final  List<CookTargetDTO> _targets;
@override List<CookTargetDTO> get targets {
  if (_targets is EqualUnmodifiableListView) return _targets;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_targets);
}


/// Create a copy of CookScheduleDTO
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CookScheduleDTOCopyWith<_CookScheduleDTO> get copyWith => __$CookScheduleDTOCopyWithImpl<_CookScheduleDTO>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$CookScheduleDTOToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _CookScheduleDTO&&const DeepCollectionEquality().equals(other._targets, _targets));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_targets));

@override
String toString() {
  return 'CookScheduleDTO(targets: $targets)';
}


}

/// @nodoc
abstract mixin class _$CookScheduleDTOCopyWith<$Res> implements $CookScheduleDTOCopyWith<$Res> {
  factory _$CookScheduleDTOCopyWith(_CookScheduleDTO value, $Res Function(_CookScheduleDTO) _then) = __$CookScheduleDTOCopyWithImpl;
@override @useResult
$Res call({
 List<CookTargetDTO> targets
});




}
/// @nodoc
class __$CookScheduleDTOCopyWithImpl<$Res>
    implements _$CookScheduleDTOCopyWith<$Res> {
  __$CookScheduleDTOCopyWithImpl(this._self, this._then);

  final _CookScheduleDTO _self;
  final $Res Function(_CookScheduleDTO) _then;

/// Create a copy of CookScheduleDTO
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? targets = null,}) {
  return _then(_CookScheduleDTO(
targets: null == targets ? _self._targets : targets // ignore: cast_nullable_to_non_nullable
as List<CookTargetDTO>,
  ));
}


}

// dart format on
