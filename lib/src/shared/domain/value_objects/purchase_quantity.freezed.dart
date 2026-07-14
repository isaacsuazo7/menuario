// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'purchase_quantity.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$PurchaseQuantity {





@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PurchaseQuantity);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'PurchaseQuantity()';
}


}

/// @nodoc
class $PurchaseQuantityCopyWith<$Res>  {
$PurchaseQuantityCopyWith(PurchaseQuantity _, $Res Function(PurchaseQuantity) __);
}


/// Adds pattern-matching-related methods to [PurchaseQuantity].
extension PurchaseQuantityPatterns on PurchaseQuantity {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( LoosePurchase value)?  loosePurchase,TResult Function( PackagePurchase value)?  packagePurchase,TResult Function( CounterPurchase value)?  counterPurchase,required TResult orElse(),}){
final _that = this;
switch (_that) {
case LoosePurchase() when loosePurchase != null:
return loosePurchase(_that);case PackagePurchase() when packagePurchase != null:
return packagePurchase(_that);case CounterPurchase() when counterPurchase != null:
return counterPurchase(_that);case _:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( LoosePurchase value)  loosePurchase,required TResult Function( PackagePurchase value)  packagePurchase,required TResult Function( CounterPurchase value)  counterPurchase,}){
final _that = this;
switch (_that) {
case LoosePurchase():
return loosePurchase(_that);case PackagePurchase():
return packagePurchase(_that);case CounterPurchase():
return counterPurchase(_that);}
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( LoosePurchase value)?  loosePurchase,TResult? Function( PackagePurchase value)?  packagePurchase,TResult? Function( CounterPurchase value)?  counterPurchase,}){
final _that = this;
switch (_that) {
case LoosePurchase() when loosePurchase != null:
return loosePurchase(_that);case PackagePurchase() when packagePurchase != null:
return packagePurchase(_that);case CounterPurchase() when counterPurchase != null:
return counterPurchase(_that);case _:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function( int units)?  loosePurchase,TResult Function( int packs,  String label)?  packagePurchase,TResult Function( int quarterPounds)?  counterPurchase,required TResult orElse(),}) {final _that = this;
switch (_that) {
case LoosePurchase() when loosePurchase != null:
return loosePurchase(_that.units);case PackagePurchase() when packagePurchase != null:
return packagePurchase(_that.packs,_that.label);case CounterPurchase() when counterPurchase != null:
return counterPurchase(_that.quarterPounds);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function( int units)  loosePurchase,required TResult Function( int packs,  String label)  packagePurchase,required TResult Function( int quarterPounds)  counterPurchase,}) {final _that = this;
switch (_that) {
case LoosePurchase():
return loosePurchase(_that.units);case PackagePurchase():
return packagePurchase(_that.packs,_that.label);case CounterPurchase():
return counterPurchase(_that.quarterPounds);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function( int units)?  loosePurchase,TResult? Function( int packs,  String label)?  packagePurchase,TResult? Function( int quarterPounds)?  counterPurchase,}) {final _that = this;
switch (_that) {
case LoosePurchase() when loosePurchase != null:
return loosePurchase(_that.units);case PackagePurchase() when packagePurchase != null:
return packagePurchase(_that.packs,_that.label);case CounterPurchase() when counterPurchase != null:
return counterPurchase(_that.quarterPounds);case _:
  return null;

}
}

}

/// @nodoc


class LoosePurchase extends PurchaseQuantity {
  const LoosePurchase({required this.units}): super._();
  

 final  int units;

/// Create a copy of PurchaseQuantity
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$LoosePurchaseCopyWith<LoosePurchase> get copyWith => _$LoosePurchaseCopyWithImpl<LoosePurchase>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is LoosePurchase&&(identical(other.units, units) || other.units == units));
}


@override
int get hashCode => Object.hash(runtimeType,units);

@override
String toString() {
  return 'PurchaseQuantity.loosePurchase(units: $units)';
}


}

/// @nodoc
abstract mixin class $LoosePurchaseCopyWith<$Res> implements $PurchaseQuantityCopyWith<$Res> {
  factory $LoosePurchaseCopyWith(LoosePurchase value, $Res Function(LoosePurchase) _then) = _$LoosePurchaseCopyWithImpl;
@useResult
$Res call({
 int units
});




}
/// @nodoc
class _$LoosePurchaseCopyWithImpl<$Res>
    implements $LoosePurchaseCopyWith<$Res> {
  _$LoosePurchaseCopyWithImpl(this._self, this._then);

  final LoosePurchase _self;
  final $Res Function(LoosePurchase) _then;

/// Create a copy of PurchaseQuantity
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? units = null,}) {
  return _then(LoosePurchase(
units: null == units ? _self.units : units // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

/// @nodoc


class PackagePurchase extends PurchaseQuantity {
  const PackagePurchase({required this.packs, required this.label}): super._();
  

 final  int packs;
 final  String label;

/// Create a copy of PurchaseQuantity
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PackagePurchaseCopyWith<PackagePurchase> get copyWith => _$PackagePurchaseCopyWithImpl<PackagePurchase>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PackagePurchase&&(identical(other.packs, packs) || other.packs == packs)&&(identical(other.label, label) || other.label == label));
}


@override
int get hashCode => Object.hash(runtimeType,packs,label);

@override
String toString() {
  return 'PurchaseQuantity.packagePurchase(packs: $packs, label: $label)';
}


}

/// @nodoc
abstract mixin class $PackagePurchaseCopyWith<$Res> implements $PurchaseQuantityCopyWith<$Res> {
  factory $PackagePurchaseCopyWith(PackagePurchase value, $Res Function(PackagePurchase) _then) = _$PackagePurchaseCopyWithImpl;
@useResult
$Res call({
 int packs, String label
});




}
/// @nodoc
class _$PackagePurchaseCopyWithImpl<$Res>
    implements $PackagePurchaseCopyWith<$Res> {
  _$PackagePurchaseCopyWithImpl(this._self, this._then);

  final PackagePurchase _self;
  final $Res Function(PackagePurchase) _then;

/// Create a copy of PurchaseQuantity
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? packs = null,Object? label = null,}) {
  return _then(PackagePurchase(
packs: null == packs ? _self.packs : packs // ignore: cast_nullable_to_non_nullable
as int,label: null == label ? _self.label : label // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

/// @nodoc


class CounterPurchase extends PurchaseQuantity {
  const CounterPurchase({required this.quarterPounds}): super._();
  

 final  int quarterPounds;

/// Create a copy of PurchaseQuantity
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CounterPurchaseCopyWith<CounterPurchase> get copyWith => _$CounterPurchaseCopyWithImpl<CounterPurchase>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CounterPurchase&&(identical(other.quarterPounds, quarterPounds) || other.quarterPounds == quarterPounds));
}


@override
int get hashCode => Object.hash(runtimeType,quarterPounds);

@override
String toString() {
  return 'PurchaseQuantity.counterPurchase(quarterPounds: $quarterPounds)';
}


}

/// @nodoc
abstract mixin class $CounterPurchaseCopyWith<$Res> implements $PurchaseQuantityCopyWith<$Res> {
  factory $CounterPurchaseCopyWith(CounterPurchase value, $Res Function(CounterPurchase) _then) = _$CounterPurchaseCopyWithImpl;
@useResult
$Res call({
 int quarterPounds
});




}
/// @nodoc
class _$CounterPurchaseCopyWithImpl<$Res>
    implements $CounterPurchaseCopyWith<$Res> {
  _$CounterPurchaseCopyWithImpl(this._self, this._then);

  final CounterPurchase _self;
  final $Res Function(CounterPurchase) _then;

/// Create a copy of PurchaseQuantity
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? quarterPounds = null,}) {
  return _then(CounterPurchase(
quarterPounds: null == quarterPounds ? _self.quarterPounds : quarterPounds // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

// dart format on
