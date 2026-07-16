// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'ingredient.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$Ingredient {

 String get id; String get name; String? get emoji; Category get category; MeasurementKind get measurementKind; bool get booleanTracked; num? get conversionFactor; MeasurementMode get measurementMode; PackageSpec? get package; String? get defaultLensLabel;
/// Create a copy of Ingredient
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$IngredientCopyWith<Ingredient> get copyWith => _$IngredientCopyWithImpl<Ingredient>(this as Ingredient, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Ingredient&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.emoji, emoji) || other.emoji == emoji)&&(identical(other.category, category) || other.category == category)&&(identical(other.measurementKind, measurementKind) || other.measurementKind == measurementKind)&&(identical(other.booleanTracked, booleanTracked) || other.booleanTracked == booleanTracked)&&(identical(other.conversionFactor, conversionFactor) || other.conversionFactor == conversionFactor)&&(identical(other.measurementMode, measurementMode) || other.measurementMode == measurementMode)&&(identical(other.package, package) || other.package == package)&&(identical(other.defaultLensLabel, defaultLensLabel) || other.defaultLensLabel == defaultLensLabel));
}


@override
int get hashCode => Object.hash(runtimeType,id,name,emoji,category,measurementKind,booleanTracked,conversionFactor,measurementMode,package,defaultLensLabel);

@override
String toString() {
  return 'Ingredient(id: $id, name: $name, emoji: $emoji, category: $category, measurementKind: $measurementKind, booleanTracked: $booleanTracked, conversionFactor: $conversionFactor, measurementMode: $measurementMode, package: $package, defaultLensLabel: $defaultLensLabel)';
}


}

/// @nodoc
abstract mixin class $IngredientCopyWith<$Res>  {
  factory $IngredientCopyWith(Ingredient value, $Res Function(Ingredient) _then) = _$IngredientCopyWithImpl;
@useResult
$Res call({
 String id, String name, String? emoji, Category category, MeasurementKind measurementKind, bool booleanTracked, num? conversionFactor, MeasurementMode measurementMode, PackageSpec? package, String? defaultLensLabel
});


$PackageSpecCopyWith<$Res>? get package;

}
/// @nodoc
class _$IngredientCopyWithImpl<$Res>
    implements $IngredientCopyWith<$Res> {
  _$IngredientCopyWithImpl(this._self, this._then);

  final Ingredient _self;
  final $Res Function(Ingredient) _then;

/// Create a copy of Ingredient
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? name = null,Object? emoji = freezed,Object? category = null,Object? measurementKind = null,Object? booleanTracked = null,Object? conversionFactor = freezed,Object? measurementMode = null,Object? package = freezed,Object? defaultLensLabel = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,emoji: freezed == emoji ? _self.emoji : emoji // ignore: cast_nullable_to_non_nullable
as String?,category: null == category ? _self.category : category // ignore: cast_nullable_to_non_nullable
as Category,measurementKind: null == measurementKind ? _self.measurementKind : measurementKind // ignore: cast_nullable_to_non_nullable
as MeasurementKind,booleanTracked: null == booleanTracked ? _self.booleanTracked : booleanTracked // ignore: cast_nullable_to_non_nullable
as bool,conversionFactor: freezed == conversionFactor ? _self.conversionFactor : conversionFactor // ignore: cast_nullable_to_non_nullable
as num?,measurementMode: null == measurementMode ? _self.measurementMode : measurementMode // ignore: cast_nullable_to_non_nullable
as MeasurementMode,package: freezed == package ? _self.package : package // ignore: cast_nullable_to_non_nullable
as PackageSpec?,defaultLensLabel: freezed == defaultLensLabel ? _self.defaultLensLabel : defaultLensLabel // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}
/// Create a copy of Ingredient
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$PackageSpecCopyWith<$Res>? get package {
    if (_self.package == null) {
    return null;
  }

  return $PackageSpecCopyWith<$Res>(_self.package!, (value) {
    return _then(_self.copyWith(package: value));
  });
}
}


/// Adds pattern-matching-related methods to [Ingredient].
extension IngredientPatterns on Ingredient {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Ingredient value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Ingredient() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Ingredient value)  $default,){
final _that = this;
switch (_that) {
case _Ingredient():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Ingredient value)?  $default,){
final _that = this;
switch (_that) {
case _Ingredient() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String name,  String? emoji,  Category category,  MeasurementKind measurementKind,  bool booleanTracked,  num? conversionFactor,  MeasurementMode measurementMode,  PackageSpec? package,  String? defaultLensLabel)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Ingredient() when $default != null:
return $default(_that.id,_that.name,_that.emoji,_that.category,_that.measurementKind,_that.booleanTracked,_that.conversionFactor,_that.measurementMode,_that.package,_that.defaultLensLabel);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String name,  String? emoji,  Category category,  MeasurementKind measurementKind,  bool booleanTracked,  num? conversionFactor,  MeasurementMode measurementMode,  PackageSpec? package,  String? defaultLensLabel)  $default,) {final _that = this;
switch (_that) {
case _Ingredient():
return $default(_that.id,_that.name,_that.emoji,_that.category,_that.measurementKind,_that.booleanTracked,_that.conversionFactor,_that.measurementMode,_that.package,_that.defaultLensLabel);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String name,  String? emoji,  Category category,  MeasurementKind measurementKind,  bool booleanTracked,  num? conversionFactor,  MeasurementMode measurementMode,  PackageSpec? package,  String? defaultLensLabel)?  $default,) {final _that = this;
switch (_that) {
case _Ingredient() when $default != null:
return $default(_that.id,_that.name,_that.emoji,_that.category,_that.measurementKind,_that.booleanTracked,_that.conversionFactor,_that.measurementMode,_that.package,_that.defaultLensLabel);case _:
  return null;

}
}

}

/// @nodoc


class _Ingredient implements Ingredient {
  const _Ingredient({required this.id, required this.name, this.emoji, required this.category, required this.measurementKind, required this.booleanTracked, this.conversionFactor, this.measurementMode = MeasurementMode.mass, this.package, this.defaultLensLabel});
  

@override final  String id;
@override final  String name;
@override final  String? emoji;
@override final  Category category;
@override final  MeasurementKind measurementKind;
@override final  bool booleanTracked;
@override final  num? conversionFactor;
@override@JsonKey() final  MeasurementMode measurementMode;
@override final  PackageSpec? package;
@override final  String? defaultLensLabel;

/// Create a copy of Ingredient
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$IngredientCopyWith<_Ingredient> get copyWith => __$IngredientCopyWithImpl<_Ingredient>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Ingredient&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.emoji, emoji) || other.emoji == emoji)&&(identical(other.category, category) || other.category == category)&&(identical(other.measurementKind, measurementKind) || other.measurementKind == measurementKind)&&(identical(other.booleanTracked, booleanTracked) || other.booleanTracked == booleanTracked)&&(identical(other.conversionFactor, conversionFactor) || other.conversionFactor == conversionFactor)&&(identical(other.measurementMode, measurementMode) || other.measurementMode == measurementMode)&&(identical(other.package, package) || other.package == package)&&(identical(other.defaultLensLabel, defaultLensLabel) || other.defaultLensLabel == defaultLensLabel));
}


@override
int get hashCode => Object.hash(runtimeType,id,name,emoji,category,measurementKind,booleanTracked,conversionFactor,measurementMode,package,defaultLensLabel);

@override
String toString() {
  return 'Ingredient(id: $id, name: $name, emoji: $emoji, category: $category, measurementKind: $measurementKind, booleanTracked: $booleanTracked, conversionFactor: $conversionFactor, measurementMode: $measurementMode, package: $package, defaultLensLabel: $defaultLensLabel)';
}


}

/// @nodoc
abstract mixin class _$IngredientCopyWith<$Res> implements $IngredientCopyWith<$Res> {
  factory _$IngredientCopyWith(_Ingredient value, $Res Function(_Ingredient) _then) = __$IngredientCopyWithImpl;
@override @useResult
$Res call({
 String id, String name, String? emoji, Category category, MeasurementKind measurementKind, bool booleanTracked, num? conversionFactor, MeasurementMode measurementMode, PackageSpec? package, String? defaultLensLabel
});


@override $PackageSpecCopyWith<$Res>? get package;

}
/// @nodoc
class __$IngredientCopyWithImpl<$Res>
    implements _$IngredientCopyWith<$Res> {
  __$IngredientCopyWithImpl(this._self, this._then);

  final _Ingredient _self;
  final $Res Function(_Ingredient) _then;

/// Create a copy of Ingredient
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = null,Object? emoji = freezed,Object? category = null,Object? measurementKind = null,Object? booleanTracked = null,Object? conversionFactor = freezed,Object? measurementMode = null,Object? package = freezed,Object? defaultLensLabel = freezed,}) {
  return _then(_Ingredient(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,emoji: freezed == emoji ? _self.emoji : emoji // ignore: cast_nullable_to_non_nullable
as String?,category: null == category ? _self.category : category // ignore: cast_nullable_to_non_nullable
as Category,measurementKind: null == measurementKind ? _self.measurementKind : measurementKind // ignore: cast_nullable_to_non_nullable
as MeasurementKind,booleanTracked: null == booleanTracked ? _self.booleanTracked : booleanTracked // ignore: cast_nullable_to_non_nullable
as bool,conversionFactor: freezed == conversionFactor ? _self.conversionFactor : conversionFactor // ignore: cast_nullable_to_non_nullable
as num?,measurementMode: null == measurementMode ? _self.measurementMode : measurementMode // ignore: cast_nullable_to_non_nullable
as MeasurementMode,package: freezed == package ? _self.package : package // ignore: cast_nullable_to_non_nullable
as PackageSpec?,defaultLensLabel: freezed == defaultLensLabel ? _self.defaultLensLabel : defaultLensLabel // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

/// Create a copy of Ingredient
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$PackageSpecCopyWith<$Res>? get package {
    if (_self.package == null) {
    return null;
  }

  return $PackageSpecCopyWith<$Res>(_self.package!, (value) {
    return _then(_self.copyWith(package: value));
  });
}
}

// dart format on
