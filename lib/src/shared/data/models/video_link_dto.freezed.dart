// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'video_link_dto.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$VideoLinkDTO {

 String get source; String get url;
/// Create a copy of VideoLinkDTO
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$VideoLinkDTOCopyWith<VideoLinkDTO> get copyWith => _$VideoLinkDTOCopyWithImpl<VideoLinkDTO>(this as VideoLinkDTO, _$identity);

  /// Serializes this VideoLinkDTO to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is VideoLinkDTO&&(identical(other.source, source) || other.source == source)&&(identical(other.url, url) || other.url == url));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,source,url);

@override
String toString() {
  return 'VideoLinkDTO(source: $source, url: $url)';
}


}

/// @nodoc
abstract mixin class $VideoLinkDTOCopyWith<$Res>  {
  factory $VideoLinkDTOCopyWith(VideoLinkDTO value, $Res Function(VideoLinkDTO) _then) = _$VideoLinkDTOCopyWithImpl;
@useResult
$Res call({
 String source, String url
});




}
/// @nodoc
class _$VideoLinkDTOCopyWithImpl<$Res>
    implements $VideoLinkDTOCopyWith<$Res> {
  _$VideoLinkDTOCopyWithImpl(this._self, this._then);

  final VideoLinkDTO _self;
  final $Res Function(VideoLinkDTO) _then;

/// Create a copy of VideoLinkDTO
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? source = null,Object? url = null,}) {
  return _then(_self.copyWith(
source: null == source ? _self.source : source // ignore: cast_nullable_to_non_nullable
as String,url: null == url ? _self.url : url // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [VideoLinkDTO].
extension VideoLinkDTOPatterns on VideoLinkDTO {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _VideoLinkDTO value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _VideoLinkDTO() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _VideoLinkDTO value)  $default,){
final _that = this;
switch (_that) {
case _VideoLinkDTO():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _VideoLinkDTO value)?  $default,){
final _that = this;
switch (_that) {
case _VideoLinkDTO() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String source,  String url)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _VideoLinkDTO() when $default != null:
return $default(_that.source,_that.url);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String source,  String url)  $default,) {final _that = this;
switch (_that) {
case _VideoLinkDTO():
return $default(_that.source,_that.url);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String source,  String url)?  $default,) {final _that = this;
switch (_that) {
case _VideoLinkDTO() when $default != null:
return $default(_that.source,_that.url);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _VideoLinkDTO extends VideoLinkDTO {
  const _VideoLinkDTO({required this.source, required this.url}): super._();
  factory _VideoLinkDTO.fromJson(Map<String, dynamic> json) => _$VideoLinkDTOFromJson(json);

@override final  String source;
@override final  String url;

/// Create a copy of VideoLinkDTO
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$VideoLinkDTOCopyWith<_VideoLinkDTO> get copyWith => __$VideoLinkDTOCopyWithImpl<_VideoLinkDTO>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$VideoLinkDTOToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _VideoLinkDTO&&(identical(other.source, source) || other.source == source)&&(identical(other.url, url) || other.url == url));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,source,url);

@override
String toString() {
  return 'VideoLinkDTO(source: $source, url: $url)';
}


}

/// @nodoc
abstract mixin class _$VideoLinkDTOCopyWith<$Res> implements $VideoLinkDTOCopyWith<$Res> {
  factory _$VideoLinkDTOCopyWith(_VideoLinkDTO value, $Res Function(_VideoLinkDTO) _then) = __$VideoLinkDTOCopyWithImpl;
@override @useResult
$Res call({
 String source, String url
});




}
/// @nodoc
class __$VideoLinkDTOCopyWithImpl<$Res>
    implements _$VideoLinkDTOCopyWith<$Res> {
  __$VideoLinkDTOCopyWithImpl(this._self, this._then);

  final _VideoLinkDTO _self;
  final $Res Function(_VideoLinkDTO) _then;

/// Create a copy of VideoLinkDTO
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? source = null,Object? url = null,}) {
  return _then(_VideoLinkDTO(
source: null == source ? _self.source : source // ignore: cast_nullable_to_non_nullable
as String,url: null == url ? _self.url : url // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
