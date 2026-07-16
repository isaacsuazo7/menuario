// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'package_spec.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$PackageSpec {

 String get label; num? get yieldQty; Unit? get baseDimension;
/// Create a copy of PackageSpec
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PackageSpecCopyWith<PackageSpec> get copyWith => _$PackageSpecCopyWithImpl<PackageSpec>(this as PackageSpec, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PackageSpec&&(identical(other.label, label) || other.label == label)&&(identical(other.yieldQty, yieldQty) || other.yieldQty == yieldQty)&&(identical(other.baseDimension, baseDimension) || other.baseDimension == baseDimension));
}


@override
int get hashCode => Object.hash(runtimeType,label,yieldQty,baseDimension);

@override
String toString() {
  return 'PackageSpec(label: $label, yieldQty: $yieldQty, baseDimension: $baseDimension)';
}


}

/// @nodoc
abstract mixin class $PackageSpecCopyWith<$Res>  {
  factory $PackageSpecCopyWith(PackageSpec value, $Res Function(PackageSpec) _then) = _$PackageSpecCopyWithImpl;
@useResult
$Res call({
 String label, num? yieldQty, Unit? baseDimension
});


$UnitCopyWith<$Res>? get baseDimension;

}
/// @nodoc
class _$PackageSpecCopyWithImpl<$Res>
    implements $PackageSpecCopyWith<$Res> {
  _$PackageSpecCopyWithImpl(this._self, this._then);

  final PackageSpec _self;
  final $Res Function(PackageSpec) _then;

/// Create a copy of PackageSpec
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? label = null,Object? yieldQty = freezed,Object? baseDimension = freezed,}) {
  return _then(_self.copyWith(
label: null == label ? _self.label : label // ignore: cast_nullable_to_non_nullable
as String,yieldQty: freezed == yieldQty ? _self.yieldQty : yieldQty // ignore: cast_nullable_to_non_nullable
as num?,baseDimension: freezed == baseDimension ? _self.baseDimension : baseDimension // ignore: cast_nullable_to_non_nullable
as Unit?,
  ));
}
/// Create a copy of PackageSpec
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$UnitCopyWith<$Res>? get baseDimension {
    if (_self.baseDimension == null) {
    return null;
  }

  return $UnitCopyWith<$Res>(_self.baseDimension!, (value) {
    return _then(_self.copyWith(baseDimension: value));
  });
}
}


/// Adds pattern-matching-related methods to [PackageSpec].
extension PackageSpecPatterns on PackageSpec {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PackageSpec value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PackageSpec() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PackageSpec value)  $default,){
final _that = this;
switch (_that) {
case _PackageSpec():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PackageSpec value)?  $default,){
final _that = this;
switch (_that) {
case _PackageSpec() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String label,  num? yieldQty,  Unit? baseDimension)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PackageSpec() when $default != null:
return $default(_that.label,_that.yieldQty,_that.baseDimension);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String label,  num? yieldQty,  Unit? baseDimension)  $default,) {final _that = this;
switch (_that) {
case _PackageSpec():
return $default(_that.label,_that.yieldQty,_that.baseDimension);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String label,  num? yieldQty,  Unit? baseDimension)?  $default,) {final _that = this;
switch (_that) {
case _PackageSpec() when $default != null:
return $default(_that.label,_that.yieldQty,_that.baseDimension);case _:
  return null;

}
}

}

/// @nodoc


class _PackageSpec implements PackageSpec {
  const _PackageSpec({required this.label, this.yieldQty, this.baseDimension});
  

@override final  String label;
@override final  num? yieldQty;
@override final  Unit? baseDimension;

/// Create a copy of PackageSpec
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PackageSpecCopyWith<_PackageSpec> get copyWith => __$PackageSpecCopyWithImpl<_PackageSpec>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _PackageSpec&&(identical(other.label, label) || other.label == label)&&(identical(other.yieldQty, yieldQty) || other.yieldQty == yieldQty)&&(identical(other.baseDimension, baseDimension) || other.baseDimension == baseDimension));
}


@override
int get hashCode => Object.hash(runtimeType,label,yieldQty,baseDimension);

@override
String toString() {
  return 'PackageSpec(label: $label, yieldQty: $yieldQty, baseDimension: $baseDimension)';
}


}

/// @nodoc
abstract mixin class _$PackageSpecCopyWith<$Res> implements $PackageSpecCopyWith<$Res> {
  factory _$PackageSpecCopyWith(_PackageSpec value, $Res Function(_PackageSpec) _then) = __$PackageSpecCopyWithImpl;
@override @useResult
$Res call({
 String label, num? yieldQty, Unit? baseDimension
});


@override $UnitCopyWith<$Res>? get baseDimension;

}
/// @nodoc
class __$PackageSpecCopyWithImpl<$Res>
    implements _$PackageSpecCopyWith<$Res> {
  __$PackageSpecCopyWithImpl(this._self, this._then);

  final _PackageSpec _self;
  final $Res Function(_PackageSpec) _then;

/// Create a copy of PackageSpec
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? label = null,Object? yieldQty = freezed,Object? baseDimension = freezed,}) {
  return _then(_PackageSpec(
label: null == label ? _self.label : label // ignore: cast_nullable_to_non_nullable
as String,yieldQty: freezed == yieldQty ? _self.yieldQty : yieldQty // ignore: cast_nullable_to_non_nullable
as num?,baseDimension: freezed == baseDimension ? _self.baseDimension : baseDimension // ignore: cast_nullable_to_non_nullable
as Unit?,
  ));
}

/// Create a copy of PackageSpec
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$UnitCopyWith<$Res>? get baseDimension {
    if (_self.baseDimension == null) {
    return null;
  }

  return $UnitCopyWith<$Res>(_self.baseDimension!, (value) {
    return _then(_self.copyWith(baseDimension: value));
  });
}
}

// dart format on
