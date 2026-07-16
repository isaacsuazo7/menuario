// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'package_spec_dto.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$PackageSpecDTO {

 String get label; num? get yieldQty; String? get baseDimensionSymbol; String? get baseDimensionKind;
/// Create a copy of PackageSpecDTO
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PackageSpecDTOCopyWith<PackageSpecDTO> get copyWith => _$PackageSpecDTOCopyWithImpl<PackageSpecDTO>(this as PackageSpecDTO, _$identity);

  /// Serializes this PackageSpecDTO to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PackageSpecDTO&&(identical(other.label, label) || other.label == label)&&(identical(other.yieldQty, yieldQty) || other.yieldQty == yieldQty)&&(identical(other.baseDimensionSymbol, baseDimensionSymbol) || other.baseDimensionSymbol == baseDimensionSymbol)&&(identical(other.baseDimensionKind, baseDimensionKind) || other.baseDimensionKind == baseDimensionKind));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,label,yieldQty,baseDimensionSymbol,baseDimensionKind);

@override
String toString() {
  return 'PackageSpecDTO(label: $label, yieldQty: $yieldQty, baseDimensionSymbol: $baseDimensionSymbol, baseDimensionKind: $baseDimensionKind)';
}


}

/// @nodoc
abstract mixin class $PackageSpecDTOCopyWith<$Res>  {
  factory $PackageSpecDTOCopyWith(PackageSpecDTO value, $Res Function(PackageSpecDTO) _then) = _$PackageSpecDTOCopyWithImpl;
@useResult
$Res call({
 String label, num? yieldQty, String? baseDimensionSymbol, String? baseDimensionKind
});




}
/// @nodoc
class _$PackageSpecDTOCopyWithImpl<$Res>
    implements $PackageSpecDTOCopyWith<$Res> {
  _$PackageSpecDTOCopyWithImpl(this._self, this._then);

  final PackageSpecDTO _self;
  final $Res Function(PackageSpecDTO) _then;

/// Create a copy of PackageSpecDTO
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? label = null,Object? yieldQty = freezed,Object? baseDimensionSymbol = freezed,Object? baseDimensionKind = freezed,}) {
  return _then(_self.copyWith(
label: null == label ? _self.label : label // ignore: cast_nullable_to_non_nullable
as String,yieldQty: freezed == yieldQty ? _self.yieldQty : yieldQty // ignore: cast_nullable_to_non_nullable
as num?,baseDimensionSymbol: freezed == baseDimensionSymbol ? _self.baseDimensionSymbol : baseDimensionSymbol // ignore: cast_nullable_to_non_nullable
as String?,baseDimensionKind: freezed == baseDimensionKind ? _self.baseDimensionKind : baseDimensionKind // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [PackageSpecDTO].
extension PackageSpecDTOPatterns on PackageSpecDTO {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PackageSpecDTO value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PackageSpecDTO() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PackageSpecDTO value)  $default,){
final _that = this;
switch (_that) {
case _PackageSpecDTO():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PackageSpecDTO value)?  $default,){
final _that = this;
switch (_that) {
case _PackageSpecDTO() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String label,  num? yieldQty,  String? baseDimensionSymbol,  String? baseDimensionKind)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PackageSpecDTO() when $default != null:
return $default(_that.label,_that.yieldQty,_that.baseDimensionSymbol,_that.baseDimensionKind);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String label,  num? yieldQty,  String? baseDimensionSymbol,  String? baseDimensionKind)  $default,) {final _that = this;
switch (_that) {
case _PackageSpecDTO():
return $default(_that.label,_that.yieldQty,_that.baseDimensionSymbol,_that.baseDimensionKind);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String label,  num? yieldQty,  String? baseDimensionSymbol,  String? baseDimensionKind)?  $default,) {final _that = this;
switch (_that) {
case _PackageSpecDTO() when $default != null:
return $default(_that.label,_that.yieldQty,_that.baseDimensionSymbol,_that.baseDimensionKind);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _PackageSpecDTO extends PackageSpecDTO {
  const _PackageSpecDTO({required this.label, this.yieldQty, this.baseDimensionSymbol, this.baseDimensionKind}): super._();
  factory _PackageSpecDTO.fromJson(Map<String, dynamic> json) => _$PackageSpecDTOFromJson(json);

@override final  String label;
@override final  num? yieldQty;
@override final  String? baseDimensionSymbol;
@override final  String? baseDimensionKind;

/// Create a copy of PackageSpecDTO
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PackageSpecDTOCopyWith<_PackageSpecDTO> get copyWith => __$PackageSpecDTOCopyWithImpl<_PackageSpecDTO>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$PackageSpecDTOToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _PackageSpecDTO&&(identical(other.label, label) || other.label == label)&&(identical(other.yieldQty, yieldQty) || other.yieldQty == yieldQty)&&(identical(other.baseDimensionSymbol, baseDimensionSymbol) || other.baseDimensionSymbol == baseDimensionSymbol)&&(identical(other.baseDimensionKind, baseDimensionKind) || other.baseDimensionKind == baseDimensionKind));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,label,yieldQty,baseDimensionSymbol,baseDimensionKind);

@override
String toString() {
  return 'PackageSpecDTO(label: $label, yieldQty: $yieldQty, baseDimensionSymbol: $baseDimensionSymbol, baseDimensionKind: $baseDimensionKind)';
}


}

/// @nodoc
abstract mixin class _$PackageSpecDTOCopyWith<$Res> implements $PackageSpecDTOCopyWith<$Res> {
  factory _$PackageSpecDTOCopyWith(_PackageSpecDTO value, $Res Function(_PackageSpecDTO) _then) = __$PackageSpecDTOCopyWithImpl;
@override @useResult
$Res call({
 String label, num? yieldQty, String? baseDimensionSymbol, String? baseDimensionKind
});




}
/// @nodoc
class __$PackageSpecDTOCopyWithImpl<$Res>
    implements _$PackageSpecDTOCopyWith<$Res> {
  __$PackageSpecDTOCopyWithImpl(this._self, this._then);

  final _PackageSpecDTO _self;
  final $Res Function(_PackageSpecDTO) _then;

/// Create a copy of PackageSpecDTO
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? label = null,Object? yieldQty = freezed,Object? baseDimensionSymbol = freezed,Object? baseDimensionKind = freezed,}) {
  return _then(_PackageSpecDTO(
label: null == label ? _self.label : label // ignore: cast_nullable_to_non_nullable
as String,yieldQty: freezed == yieldQty ? _self.yieldQty : yieldQty // ignore: cast_nullable_to_non_nullable
as num?,baseDimensionSymbol: freezed == baseDimensionSymbol ? _self.baseDimensionSymbol : baseDimensionSymbol // ignore: cast_nullable_to_non_nullable
as String?,baseDimensionKind: freezed == baseDimensionKind ? _self.baseDimensionKind : baseDimensionKind // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
