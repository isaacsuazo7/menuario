// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'plan_entry.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$PlanEntry {

 DayOfWeek get day; MealSlot get mealSlot; String get recipeId; bool get cooked;
/// Create a copy of PlanEntry
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PlanEntryCopyWith<PlanEntry> get copyWith => _$PlanEntryCopyWithImpl<PlanEntry>(this as PlanEntry, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PlanEntry&&(identical(other.day, day) || other.day == day)&&(identical(other.mealSlot, mealSlot) || other.mealSlot == mealSlot)&&(identical(other.recipeId, recipeId) || other.recipeId == recipeId)&&(identical(other.cooked, cooked) || other.cooked == cooked));
}


@override
int get hashCode => Object.hash(runtimeType,day,mealSlot,recipeId,cooked);

@override
String toString() {
  return 'PlanEntry(day: $day, mealSlot: $mealSlot, recipeId: $recipeId, cooked: $cooked)';
}


}

/// @nodoc
abstract mixin class $PlanEntryCopyWith<$Res>  {
  factory $PlanEntryCopyWith(PlanEntry value, $Res Function(PlanEntry) _then) = _$PlanEntryCopyWithImpl;
@useResult
$Res call({
 DayOfWeek day, MealSlot mealSlot, String recipeId, bool cooked
});




}
/// @nodoc
class _$PlanEntryCopyWithImpl<$Res>
    implements $PlanEntryCopyWith<$Res> {
  _$PlanEntryCopyWithImpl(this._self, this._then);

  final PlanEntry _self;
  final $Res Function(PlanEntry) _then;

/// Create a copy of PlanEntry
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? day = null,Object? mealSlot = null,Object? recipeId = null,Object? cooked = null,}) {
  return _then(_self.copyWith(
day: null == day ? _self.day : day // ignore: cast_nullable_to_non_nullable
as DayOfWeek,mealSlot: null == mealSlot ? _self.mealSlot : mealSlot // ignore: cast_nullable_to_non_nullable
as MealSlot,recipeId: null == recipeId ? _self.recipeId : recipeId // ignore: cast_nullable_to_non_nullable
as String,cooked: null == cooked ? _self.cooked : cooked // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [PlanEntry].
extension PlanEntryPatterns on PlanEntry {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PlanEntry value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PlanEntry() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PlanEntry value)  $default,){
final _that = this;
switch (_that) {
case _PlanEntry():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PlanEntry value)?  $default,){
final _that = this;
switch (_that) {
case _PlanEntry() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( DayOfWeek day,  MealSlot mealSlot,  String recipeId,  bool cooked)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PlanEntry() when $default != null:
return $default(_that.day,_that.mealSlot,_that.recipeId,_that.cooked);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( DayOfWeek day,  MealSlot mealSlot,  String recipeId,  bool cooked)  $default,) {final _that = this;
switch (_that) {
case _PlanEntry():
return $default(_that.day,_that.mealSlot,_that.recipeId,_that.cooked);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( DayOfWeek day,  MealSlot mealSlot,  String recipeId,  bool cooked)?  $default,) {final _that = this;
switch (_that) {
case _PlanEntry() when $default != null:
return $default(_that.day,_that.mealSlot,_that.recipeId,_that.cooked);case _:
  return null;

}
}

}

/// @nodoc


class _PlanEntry implements PlanEntry {
  const _PlanEntry({required this.day, required this.mealSlot, required this.recipeId, required this.cooked});
  

@override final  DayOfWeek day;
@override final  MealSlot mealSlot;
@override final  String recipeId;
@override final  bool cooked;

/// Create a copy of PlanEntry
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PlanEntryCopyWith<_PlanEntry> get copyWith => __$PlanEntryCopyWithImpl<_PlanEntry>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _PlanEntry&&(identical(other.day, day) || other.day == day)&&(identical(other.mealSlot, mealSlot) || other.mealSlot == mealSlot)&&(identical(other.recipeId, recipeId) || other.recipeId == recipeId)&&(identical(other.cooked, cooked) || other.cooked == cooked));
}


@override
int get hashCode => Object.hash(runtimeType,day,mealSlot,recipeId,cooked);

@override
String toString() {
  return 'PlanEntry(day: $day, mealSlot: $mealSlot, recipeId: $recipeId, cooked: $cooked)';
}


}

/// @nodoc
abstract mixin class _$PlanEntryCopyWith<$Res> implements $PlanEntryCopyWith<$Res> {
  factory _$PlanEntryCopyWith(_PlanEntry value, $Res Function(_PlanEntry) _then) = __$PlanEntryCopyWithImpl;
@override @useResult
$Res call({
 DayOfWeek day, MealSlot mealSlot, String recipeId, bool cooked
});




}
/// @nodoc
class __$PlanEntryCopyWithImpl<$Res>
    implements _$PlanEntryCopyWith<$Res> {
  __$PlanEntryCopyWithImpl(this._self, this._then);

  final _PlanEntry _self;
  final $Res Function(_PlanEntry) _then;

/// Create a copy of PlanEntry
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? day = null,Object? mealSlot = null,Object? recipeId = null,Object? cooked = null,}) {
  return _then(_PlanEntry(
day: null == day ? _self.day : day // ignore: cast_nullable_to_non_nullable
as DayOfWeek,mealSlot: null == mealSlot ? _self.mealSlot : mealSlot // ignore: cast_nullable_to_non_nullable
as MealSlot,recipeId: null == recipeId ? _self.recipeId : recipeId // ignore: cast_nullable_to_non_nullable
as String,cooked: null == cooked ? _self.cooked : cooked // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

// dart format on
