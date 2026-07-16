// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'cook_schedule.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$CookSchedule {

 Map<int, List<CookTarget>> get byWeekday;
/// Create a copy of CookSchedule
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CookScheduleCopyWith<CookSchedule> get copyWith => _$CookScheduleCopyWithImpl<CookSchedule>(this as CookSchedule, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CookSchedule&&const DeepCollectionEquality().equals(other.byWeekday, byWeekday));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(byWeekday));

@override
String toString() {
  return 'CookSchedule(byWeekday: $byWeekday)';
}


}

/// @nodoc
abstract mixin class $CookScheduleCopyWith<$Res>  {
  factory $CookScheduleCopyWith(CookSchedule value, $Res Function(CookSchedule) _then) = _$CookScheduleCopyWithImpl;
@useResult
$Res call({
 Map<int, List<CookTarget>> byWeekday
});




}
/// @nodoc
class _$CookScheduleCopyWithImpl<$Res>
    implements $CookScheduleCopyWith<$Res> {
  _$CookScheduleCopyWithImpl(this._self, this._then);

  final CookSchedule _self;
  final $Res Function(CookSchedule) _then;

/// Create a copy of CookSchedule
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? byWeekday = null,}) {
  return _then(_self.copyWith(
byWeekday: null == byWeekday ? _self.byWeekday : byWeekday // ignore: cast_nullable_to_non_nullable
as Map<int, List<CookTarget>>,
  ));
}

}


/// Adds pattern-matching-related methods to [CookSchedule].
extension CookSchedulePatterns on CookSchedule {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CookSchedule value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CookSchedule() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CookSchedule value)  $default,){
final _that = this;
switch (_that) {
case _CookSchedule():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CookSchedule value)?  $default,){
final _that = this;
switch (_that) {
case _CookSchedule() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( Map<int, List<CookTarget>> byWeekday)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CookSchedule() when $default != null:
return $default(_that.byWeekday);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( Map<int, List<CookTarget>> byWeekday)  $default,) {final _that = this;
switch (_that) {
case _CookSchedule():
return $default(_that.byWeekday);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( Map<int, List<CookTarget>> byWeekday)?  $default,) {final _that = this;
switch (_that) {
case _CookSchedule() when $default != null:
return $default(_that.byWeekday);case _:
  return null;

}
}

}

/// @nodoc


class _CookSchedule extends CookSchedule {
  const _CookSchedule({required final  Map<int, List<CookTarget>> byWeekday}): _byWeekday = byWeekday,super._();
  

 final  Map<int, List<CookTarget>> _byWeekday;
@override Map<int, List<CookTarget>> get byWeekday {
  if (_byWeekday is EqualUnmodifiableMapView) return _byWeekday;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_byWeekday);
}


/// Create a copy of CookSchedule
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CookScheduleCopyWith<_CookSchedule> get copyWith => __$CookScheduleCopyWithImpl<_CookSchedule>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _CookSchedule&&const DeepCollectionEquality().equals(other._byWeekday, _byWeekday));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_byWeekday));

@override
String toString() {
  return 'CookSchedule(byWeekday: $byWeekday)';
}


}

/// @nodoc
abstract mixin class _$CookScheduleCopyWith<$Res> implements $CookScheduleCopyWith<$Res> {
  factory _$CookScheduleCopyWith(_CookSchedule value, $Res Function(_CookSchedule) _then) = __$CookScheduleCopyWithImpl;
@override @useResult
$Res call({
 Map<int, List<CookTarget>> byWeekday
});




}
/// @nodoc
class __$CookScheduleCopyWithImpl<$Res>
    implements _$CookScheduleCopyWith<$Res> {
  __$CookScheduleCopyWithImpl(this._self, this._then);

  final _CookSchedule _self;
  final $Res Function(_CookSchedule) _then;

/// Create a copy of CookSchedule
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? byWeekday = null,}) {
  return _then(_CookSchedule(
byWeekday: null == byWeekday ? _self._byWeekday : byWeekday // ignore: cast_nullable_to_non_nullable
as Map<int, List<CookTarget>>,
  ));
}


}

// dart format on
