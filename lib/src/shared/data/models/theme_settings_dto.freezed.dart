// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'theme_settings_dto.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$ThemeSettingsDTO {

@JsonKey(readValue: _readString) String? get mode;@JsonKey(readValue: _readInt) int? get seed;
/// Create a copy of ThemeSettingsDTO
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ThemeSettingsDTOCopyWith<ThemeSettingsDTO> get copyWith => _$ThemeSettingsDTOCopyWithImpl<ThemeSettingsDTO>(this as ThemeSettingsDTO, _$identity);

  /// Serializes this ThemeSettingsDTO to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ThemeSettingsDTO&&(identical(other.mode, mode) || other.mode == mode)&&(identical(other.seed, seed) || other.seed == seed));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,mode,seed);

@override
String toString() {
  return 'ThemeSettingsDTO(mode: $mode, seed: $seed)';
}


}

/// @nodoc
abstract mixin class $ThemeSettingsDTOCopyWith<$Res>  {
  factory $ThemeSettingsDTOCopyWith(ThemeSettingsDTO value, $Res Function(ThemeSettingsDTO) _then) = _$ThemeSettingsDTOCopyWithImpl;
@useResult
$Res call({
@JsonKey(readValue: _readString) String? mode,@JsonKey(readValue: _readInt) int? seed
});




}
/// @nodoc
class _$ThemeSettingsDTOCopyWithImpl<$Res>
    implements $ThemeSettingsDTOCopyWith<$Res> {
  _$ThemeSettingsDTOCopyWithImpl(this._self, this._then);

  final ThemeSettingsDTO _self;
  final $Res Function(ThemeSettingsDTO) _then;

/// Create a copy of ThemeSettingsDTO
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? mode = freezed,Object? seed = freezed,}) {
  return _then(_self.copyWith(
mode: freezed == mode ? _self.mode : mode // ignore: cast_nullable_to_non_nullable
as String?,seed: freezed == seed ? _self.seed : seed // ignore: cast_nullable_to_non_nullable
as int?,
  ));
}

}


/// Adds pattern-matching-related methods to [ThemeSettingsDTO].
extension ThemeSettingsDTOPatterns on ThemeSettingsDTO {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ThemeSettingsDTO value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ThemeSettingsDTO() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ThemeSettingsDTO value)  $default,){
final _that = this;
switch (_that) {
case _ThemeSettingsDTO():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ThemeSettingsDTO value)?  $default,){
final _that = this;
switch (_that) {
case _ThemeSettingsDTO() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(readValue: _readString)  String? mode, @JsonKey(readValue: _readInt)  int? seed)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ThemeSettingsDTO() when $default != null:
return $default(_that.mode,_that.seed);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(readValue: _readString)  String? mode, @JsonKey(readValue: _readInt)  int? seed)  $default,) {final _that = this;
switch (_that) {
case _ThemeSettingsDTO():
return $default(_that.mode,_that.seed);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(readValue: _readString)  String? mode, @JsonKey(readValue: _readInt)  int? seed)?  $default,) {final _that = this;
switch (_that) {
case _ThemeSettingsDTO() when $default != null:
return $default(_that.mode,_that.seed);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ThemeSettingsDTO extends ThemeSettingsDTO {
  const _ThemeSettingsDTO({@JsonKey(readValue: _readString) this.mode, @JsonKey(readValue: _readInt) this.seed}): super._();
  factory _ThemeSettingsDTO.fromJson(Map<String, dynamic> json) => _$ThemeSettingsDTOFromJson(json);

@override@JsonKey(readValue: _readString) final  String? mode;
@override@JsonKey(readValue: _readInt) final  int? seed;

/// Create a copy of ThemeSettingsDTO
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ThemeSettingsDTOCopyWith<_ThemeSettingsDTO> get copyWith => __$ThemeSettingsDTOCopyWithImpl<_ThemeSettingsDTO>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ThemeSettingsDTOToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ThemeSettingsDTO&&(identical(other.mode, mode) || other.mode == mode)&&(identical(other.seed, seed) || other.seed == seed));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,mode,seed);

@override
String toString() {
  return 'ThemeSettingsDTO(mode: $mode, seed: $seed)';
}


}

/// @nodoc
abstract mixin class _$ThemeSettingsDTOCopyWith<$Res> implements $ThemeSettingsDTOCopyWith<$Res> {
  factory _$ThemeSettingsDTOCopyWith(_ThemeSettingsDTO value, $Res Function(_ThemeSettingsDTO) _then) = __$ThemeSettingsDTOCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(readValue: _readString) String? mode,@JsonKey(readValue: _readInt) int? seed
});




}
/// @nodoc
class __$ThemeSettingsDTOCopyWithImpl<$Res>
    implements _$ThemeSettingsDTOCopyWith<$Res> {
  __$ThemeSettingsDTOCopyWithImpl(this._self, this._then);

  final _ThemeSettingsDTO _self;
  final $Res Function(_ThemeSettingsDTO) _then;

/// Create a copy of ThemeSettingsDTO
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? mode = freezed,Object? seed = freezed,}) {
  return _then(_ThemeSettingsDTO(
mode: freezed == mode ? _self.mode : mode // ignore: cast_nullable_to_non_nullable
as String?,seed: freezed == seed ? _self.seed : seed // ignore: cast_nullable_to_non_nullable
as int?,
  ));
}


}

// dart format on
