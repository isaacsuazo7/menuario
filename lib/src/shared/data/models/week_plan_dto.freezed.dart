// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'week_plan_dto.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$WeekPlanDTO {

 List<PlanEntryDTO> get entries;
/// Create a copy of WeekPlanDTO
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$WeekPlanDTOCopyWith<WeekPlanDTO> get copyWith => _$WeekPlanDTOCopyWithImpl<WeekPlanDTO>(this as WeekPlanDTO, _$identity);

  /// Serializes this WeekPlanDTO to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is WeekPlanDTO&&const DeepCollectionEquality().equals(other.entries, entries));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(entries));

@override
String toString() {
  return 'WeekPlanDTO(entries: $entries)';
}


}

/// @nodoc
abstract mixin class $WeekPlanDTOCopyWith<$Res>  {
  factory $WeekPlanDTOCopyWith(WeekPlanDTO value, $Res Function(WeekPlanDTO) _then) = _$WeekPlanDTOCopyWithImpl;
@useResult
$Res call({
 List<PlanEntryDTO> entries
});




}
/// @nodoc
class _$WeekPlanDTOCopyWithImpl<$Res>
    implements $WeekPlanDTOCopyWith<$Res> {
  _$WeekPlanDTOCopyWithImpl(this._self, this._then);

  final WeekPlanDTO _self;
  final $Res Function(WeekPlanDTO) _then;

/// Create a copy of WeekPlanDTO
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? entries = null,}) {
  return _then(_self.copyWith(
entries: null == entries ? _self.entries : entries // ignore: cast_nullable_to_non_nullable
as List<PlanEntryDTO>,
  ));
}

}


/// Adds pattern-matching-related methods to [WeekPlanDTO].
extension WeekPlanDTOPatterns on WeekPlanDTO {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _WeekPlanDTO value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _WeekPlanDTO() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _WeekPlanDTO value)  $default,){
final _that = this;
switch (_that) {
case _WeekPlanDTO():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _WeekPlanDTO value)?  $default,){
final _that = this;
switch (_that) {
case _WeekPlanDTO() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( List<PlanEntryDTO> entries)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _WeekPlanDTO() when $default != null:
return $default(_that.entries);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( List<PlanEntryDTO> entries)  $default,) {final _that = this;
switch (_that) {
case _WeekPlanDTO():
return $default(_that.entries);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( List<PlanEntryDTO> entries)?  $default,) {final _that = this;
switch (_that) {
case _WeekPlanDTO() when $default != null:
return $default(_that.entries);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _WeekPlanDTO extends WeekPlanDTO {
  const _WeekPlanDTO({required final  List<PlanEntryDTO> entries}): _entries = entries,super._();
  factory _WeekPlanDTO.fromJson(Map<String, dynamic> json) => _$WeekPlanDTOFromJson(json);

 final  List<PlanEntryDTO> _entries;
@override List<PlanEntryDTO> get entries {
  if (_entries is EqualUnmodifiableListView) return _entries;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_entries);
}


/// Create a copy of WeekPlanDTO
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$WeekPlanDTOCopyWith<_WeekPlanDTO> get copyWith => __$WeekPlanDTOCopyWithImpl<_WeekPlanDTO>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$WeekPlanDTOToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _WeekPlanDTO&&const DeepCollectionEquality().equals(other._entries, _entries));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_entries));

@override
String toString() {
  return 'WeekPlanDTO(entries: $entries)';
}


}

/// @nodoc
abstract mixin class _$WeekPlanDTOCopyWith<$Res> implements $WeekPlanDTOCopyWith<$Res> {
  factory _$WeekPlanDTOCopyWith(_WeekPlanDTO value, $Res Function(_WeekPlanDTO) _then) = __$WeekPlanDTOCopyWithImpl;
@override @useResult
$Res call({
 List<PlanEntryDTO> entries
});




}
/// @nodoc
class __$WeekPlanDTOCopyWithImpl<$Res>
    implements _$WeekPlanDTOCopyWith<$Res> {
  __$WeekPlanDTOCopyWithImpl(this._self, this._then);

  final _WeekPlanDTO _self;
  final $Res Function(_WeekPlanDTO) _then;

/// Create a copy of WeekPlanDTO
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? entries = null,}) {
  return _then(_WeekPlanDTO(
entries: null == entries ? _self._entries : entries // ignore: cast_nullable_to_non_nullable
as List<PlanEntryDTO>,
  ));
}


}

// dart format on
