// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'week_plan.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$WeekPlan {

 List<PlanEntry> get entries;
/// Create a copy of WeekPlan
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$WeekPlanCopyWith<WeekPlan> get copyWith => _$WeekPlanCopyWithImpl<WeekPlan>(this as WeekPlan, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is WeekPlan&&const DeepCollectionEquality().equals(other.entries, entries));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(entries));

@override
String toString() {
  return 'WeekPlan(entries: $entries)';
}


}

/// @nodoc
abstract mixin class $WeekPlanCopyWith<$Res>  {
  factory $WeekPlanCopyWith(WeekPlan value, $Res Function(WeekPlan) _then) = _$WeekPlanCopyWithImpl;
@useResult
$Res call({
 List<PlanEntry> entries
});




}
/// @nodoc
class _$WeekPlanCopyWithImpl<$Res>
    implements $WeekPlanCopyWith<$Res> {
  _$WeekPlanCopyWithImpl(this._self, this._then);

  final WeekPlan _self;
  final $Res Function(WeekPlan) _then;

/// Create a copy of WeekPlan
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? entries = null,}) {
  return _then(_self.copyWith(
entries: null == entries ? _self.entries : entries // ignore: cast_nullable_to_non_nullable
as List<PlanEntry>,
  ));
}

}


/// Adds pattern-matching-related methods to [WeekPlan].
extension WeekPlanPatterns on WeekPlan {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _WeekPlan value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _WeekPlan() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _WeekPlan value)  $default,){
final _that = this;
switch (_that) {
case _WeekPlan():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _WeekPlan value)?  $default,){
final _that = this;
switch (_that) {
case _WeekPlan() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( List<PlanEntry> entries)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _WeekPlan() when $default != null:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( List<PlanEntry> entries)  $default,) {final _that = this;
switch (_that) {
case _WeekPlan():
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( List<PlanEntry> entries)?  $default,) {final _that = this;
switch (_that) {
case _WeekPlan() when $default != null:
return $default(_that.entries);case _:
  return null;

}
}

}

/// @nodoc


class _WeekPlan extends WeekPlan {
  const _WeekPlan({required final  List<PlanEntry> entries}): _entries = entries,super._();
  

 final  List<PlanEntry> _entries;
@override List<PlanEntry> get entries {
  if (_entries is EqualUnmodifiableListView) return _entries;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_entries);
}


/// Create a copy of WeekPlan
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$WeekPlanCopyWith<_WeekPlan> get copyWith => __$WeekPlanCopyWithImpl<_WeekPlan>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _WeekPlan&&const DeepCollectionEquality().equals(other._entries, _entries));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_entries));

@override
String toString() {
  return 'WeekPlan(entries: $entries)';
}


}

/// @nodoc
abstract mixin class _$WeekPlanCopyWith<$Res> implements $WeekPlanCopyWith<$Res> {
  factory _$WeekPlanCopyWith(_WeekPlan value, $Res Function(_WeekPlan) _then) = __$WeekPlanCopyWithImpl;
@override @useResult
$Res call({
 List<PlanEntry> entries
});




}
/// @nodoc
class __$WeekPlanCopyWithImpl<$Res>
    implements _$WeekPlanCopyWith<$Res> {
  __$WeekPlanCopyWithImpl(this._self, this._then);

  final _WeekPlan _self;
  final $Res Function(_WeekPlan) _then;

/// Create a copy of WeekPlan
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? entries = null,}) {
  return _then(_WeekPlan(
entries: null == entries ? _self._entries : entries // ignore: cast_nullable_to_non_nullable
as List<PlanEntry>,
  ));
}


}

// dart format on
