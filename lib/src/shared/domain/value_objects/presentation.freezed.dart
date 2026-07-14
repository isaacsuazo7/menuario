// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'presentation.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$Presentation {





@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Presentation);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'Presentation()';
}


}

/// @nodoc
class $PresentationCopyWith<$Res>  {
$PresentationCopyWith(Presentation _, $Res Function(Presentation) __);
}


/// Adds pattern-matching-related methods to [Presentation].
extension PresentationPatterns on Presentation {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( PresentationLoose value)?  loose,TResult Function( PresentationPackage value)?  package,TResult Function( PresentationCounter value)?  counter,required TResult orElse(),}){
final _that = this;
switch (_that) {
case PresentationLoose() when loose != null:
return loose(_that);case PresentationPackage() when package != null:
return package(_that);case PresentationCounter() when counter != null:
return counter(_that);case _:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( PresentationLoose value)  loose,required TResult Function( PresentationPackage value)  package,required TResult Function( PresentationCounter value)  counter,}){
final _that = this;
switch (_that) {
case PresentationLoose():
return loose(_that);case PresentationPackage():
return package(_that);case PresentationCounter():
return counter(_that);}
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( PresentationLoose value)?  loose,TResult? Function( PresentationPackage value)?  package,TResult? Function( PresentationCounter value)?  counter,}){
final _that = this;
switch (_that) {
case PresentationLoose() when loose != null:
return loose(_that);case PresentationPackage() when package != null:
return package(_that);case PresentationCounter() when counter != null:
return counter(_that);case _:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function()?  loose,TResult Function( num yieldQty,  String label)?  package,TResult Function()?  counter,required TResult orElse(),}) {final _that = this;
switch (_that) {
case PresentationLoose() when loose != null:
return loose();case PresentationPackage() when package != null:
return package(_that.yieldQty,_that.label);case PresentationCounter() when counter != null:
return counter();case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function()  loose,required TResult Function( num yieldQty,  String label)  package,required TResult Function()  counter,}) {final _that = this;
switch (_that) {
case PresentationLoose():
return loose();case PresentationPackage():
return package(_that.yieldQty,_that.label);case PresentationCounter():
return counter();}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function()?  loose,TResult? Function( num yieldQty,  String label)?  package,TResult? Function()?  counter,}) {final _that = this;
switch (_that) {
case PresentationLoose() when loose != null:
return loose();case PresentationPackage() when package != null:
return package(_that.yieldQty,_that.label);case PresentationCounter() when counter != null:
return counter();case _:
  return null;

}
}

}

/// @nodoc


class PresentationLoose implements Presentation {
  const PresentationLoose();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PresentationLoose);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'Presentation.loose()';
}


}




/// @nodoc


class PresentationPackage implements Presentation {
  const PresentationPackage({required this.yieldQty, required this.label});
  

 final  num yieldQty;
 final  String label;

/// Create a copy of Presentation
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PresentationPackageCopyWith<PresentationPackage> get copyWith => _$PresentationPackageCopyWithImpl<PresentationPackage>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PresentationPackage&&(identical(other.yieldQty, yieldQty) || other.yieldQty == yieldQty)&&(identical(other.label, label) || other.label == label));
}


@override
int get hashCode => Object.hash(runtimeType,yieldQty,label);

@override
String toString() {
  return 'Presentation.package(yieldQty: $yieldQty, label: $label)';
}


}

/// @nodoc
abstract mixin class $PresentationPackageCopyWith<$Res> implements $PresentationCopyWith<$Res> {
  factory $PresentationPackageCopyWith(PresentationPackage value, $Res Function(PresentationPackage) _then) = _$PresentationPackageCopyWithImpl;
@useResult
$Res call({
 num yieldQty, String label
});




}
/// @nodoc
class _$PresentationPackageCopyWithImpl<$Res>
    implements $PresentationPackageCopyWith<$Res> {
  _$PresentationPackageCopyWithImpl(this._self, this._then);

  final PresentationPackage _self;
  final $Res Function(PresentationPackage) _then;

/// Create a copy of Presentation
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? yieldQty = null,Object? label = null,}) {
  return _then(PresentationPackage(
yieldQty: null == yieldQty ? _self.yieldQty : yieldQty // ignore: cast_nullable_to_non_nullable
as num,label: null == label ? _self.label : label // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

/// @nodoc


class PresentationCounter implements Presentation {
  const PresentationCounter();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PresentationCounter);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'Presentation.counter()';
}


}




// dart format on
