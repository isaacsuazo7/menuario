// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'pantry_item.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$PantryItem {

 String get ingredientId; Category get category; Presentation get presentation;
/// Create a copy of PantryItem
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PantryItemCopyWith<PantryItem> get copyWith => _$PantryItemCopyWithImpl<PantryItem>(this as PantryItem, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PantryItem&&(identical(other.ingredientId, ingredientId) || other.ingredientId == ingredientId)&&(identical(other.category, category) || other.category == category)&&(identical(other.presentation, presentation) || other.presentation == presentation));
}


@override
int get hashCode => Object.hash(runtimeType,ingredientId,category,presentation);

@override
String toString() {
  return 'PantryItem(ingredientId: $ingredientId, category: $category, presentation: $presentation)';
}


}

/// @nodoc
abstract mixin class $PantryItemCopyWith<$Res>  {
  factory $PantryItemCopyWith(PantryItem value, $Res Function(PantryItem) _then) = _$PantryItemCopyWithImpl;
@useResult
$Res call({
 String ingredientId, Category category, Presentation presentation
});


$PresentationCopyWith<$Res> get presentation;

}
/// @nodoc
class _$PantryItemCopyWithImpl<$Res>
    implements $PantryItemCopyWith<$Res> {
  _$PantryItemCopyWithImpl(this._self, this._then);

  final PantryItem _self;
  final $Res Function(PantryItem) _then;

/// Create a copy of PantryItem
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? ingredientId = null,Object? category = null,Object? presentation = null,}) {
  return _then(_self.copyWith(
ingredientId: null == ingredientId ? _self.ingredientId : ingredientId // ignore: cast_nullable_to_non_nullable
as String,category: null == category ? _self.category : category // ignore: cast_nullable_to_non_nullable
as Category,presentation: null == presentation ? _self.presentation : presentation // ignore: cast_nullable_to_non_nullable
as Presentation,
  ));
}
/// Create a copy of PantryItem
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$PresentationCopyWith<$Res> get presentation {
  
  return $PresentationCopyWith<$Res>(_self.presentation, (value) {
    return _then(_self.copyWith(presentation: value));
  });
}
}


/// Adds pattern-matching-related methods to [PantryItem].
extension PantryItemPatterns on PantryItem {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( QuantityTrackedPantryItem value)?  quantityTracked,TResult Function( BooleanTrackedPantryItem value)?  booleanTracked,required TResult orElse(),}){
final _that = this;
switch (_that) {
case QuantityTrackedPantryItem() when quantityTracked != null:
return quantityTracked(_that);case BooleanTrackedPantryItem() when booleanTracked != null:
return booleanTracked(_that);case _:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( QuantityTrackedPantryItem value)  quantityTracked,required TResult Function( BooleanTrackedPantryItem value)  booleanTracked,}){
final _that = this;
switch (_that) {
case QuantityTrackedPantryItem():
return quantityTracked(_that);case BooleanTrackedPantryItem():
return booleanTracked(_that);}
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( QuantityTrackedPantryItem value)?  quantityTracked,TResult? Function( BooleanTrackedPantryItem value)?  booleanTracked,}){
final _that = this;
switch (_that) {
case QuantityTrackedPantryItem() when quantityTracked != null:
return quantityTracked(_that);case BooleanTrackedPantryItem() when booleanTracked != null:
return booleanTracked(_that);case _:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function( String ingredientId,  Category category,  Presentation presentation,  Quantity stock)?  quantityTracked,TResult Function( String ingredientId,  Category category,  Presentation presentation,  bool haveIt)?  booleanTracked,required TResult orElse(),}) {final _that = this;
switch (_that) {
case QuantityTrackedPantryItem() when quantityTracked != null:
return quantityTracked(_that.ingredientId,_that.category,_that.presentation,_that.stock);case BooleanTrackedPantryItem() when booleanTracked != null:
return booleanTracked(_that.ingredientId,_that.category,_that.presentation,_that.haveIt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function( String ingredientId,  Category category,  Presentation presentation,  Quantity stock)  quantityTracked,required TResult Function( String ingredientId,  Category category,  Presentation presentation,  bool haveIt)  booleanTracked,}) {final _that = this;
switch (_that) {
case QuantityTrackedPantryItem():
return quantityTracked(_that.ingredientId,_that.category,_that.presentation,_that.stock);case BooleanTrackedPantryItem():
return booleanTracked(_that.ingredientId,_that.category,_that.presentation,_that.haveIt);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function( String ingredientId,  Category category,  Presentation presentation,  Quantity stock)?  quantityTracked,TResult? Function( String ingredientId,  Category category,  Presentation presentation,  bool haveIt)?  booleanTracked,}) {final _that = this;
switch (_that) {
case QuantityTrackedPantryItem() when quantityTracked != null:
return quantityTracked(_that.ingredientId,_that.category,_that.presentation,_that.stock);case BooleanTrackedPantryItem() when booleanTracked != null:
return booleanTracked(_that.ingredientId,_that.category,_that.presentation,_that.haveIt);case _:
  return null;

}
}

}

/// @nodoc


class QuantityTrackedPantryItem implements PantryItem {
  const QuantityTrackedPantryItem({required this.ingredientId, required this.category, required this.presentation, required this.stock});
  

@override final  String ingredientId;
@override final  Category category;
@override final  Presentation presentation;
 final  Quantity stock;

/// Create a copy of PantryItem
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$QuantityTrackedPantryItemCopyWith<QuantityTrackedPantryItem> get copyWith => _$QuantityTrackedPantryItemCopyWithImpl<QuantityTrackedPantryItem>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is QuantityTrackedPantryItem&&(identical(other.ingredientId, ingredientId) || other.ingredientId == ingredientId)&&(identical(other.category, category) || other.category == category)&&(identical(other.presentation, presentation) || other.presentation == presentation)&&(identical(other.stock, stock) || other.stock == stock));
}


@override
int get hashCode => Object.hash(runtimeType,ingredientId,category,presentation,stock);

@override
String toString() {
  return 'PantryItem.quantityTracked(ingredientId: $ingredientId, category: $category, presentation: $presentation, stock: $stock)';
}


}

/// @nodoc
abstract mixin class $QuantityTrackedPantryItemCopyWith<$Res> implements $PantryItemCopyWith<$Res> {
  factory $QuantityTrackedPantryItemCopyWith(QuantityTrackedPantryItem value, $Res Function(QuantityTrackedPantryItem) _then) = _$QuantityTrackedPantryItemCopyWithImpl;
@override @useResult
$Res call({
 String ingredientId, Category category, Presentation presentation, Quantity stock
});


@override $PresentationCopyWith<$Res> get presentation;$QuantityCopyWith<$Res> get stock;

}
/// @nodoc
class _$QuantityTrackedPantryItemCopyWithImpl<$Res>
    implements $QuantityTrackedPantryItemCopyWith<$Res> {
  _$QuantityTrackedPantryItemCopyWithImpl(this._self, this._then);

  final QuantityTrackedPantryItem _self;
  final $Res Function(QuantityTrackedPantryItem) _then;

/// Create a copy of PantryItem
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? ingredientId = null,Object? category = null,Object? presentation = null,Object? stock = null,}) {
  return _then(QuantityTrackedPantryItem(
ingredientId: null == ingredientId ? _self.ingredientId : ingredientId // ignore: cast_nullable_to_non_nullable
as String,category: null == category ? _self.category : category // ignore: cast_nullable_to_non_nullable
as Category,presentation: null == presentation ? _self.presentation : presentation // ignore: cast_nullable_to_non_nullable
as Presentation,stock: null == stock ? _self.stock : stock // ignore: cast_nullable_to_non_nullable
as Quantity,
  ));
}

/// Create a copy of PantryItem
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$PresentationCopyWith<$Res> get presentation {
  
  return $PresentationCopyWith<$Res>(_self.presentation, (value) {
    return _then(_self.copyWith(presentation: value));
  });
}/// Create a copy of PantryItem
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$QuantityCopyWith<$Res> get stock {
  
  return $QuantityCopyWith<$Res>(_self.stock, (value) {
    return _then(_self.copyWith(stock: value));
  });
}
}

/// @nodoc


class BooleanTrackedPantryItem implements PantryItem {
  const BooleanTrackedPantryItem({required this.ingredientId, required this.category, required this.presentation, required this.haveIt});
  

@override final  String ingredientId;
@override final  Category category;
@override final  Presentation presentation;
 final  bool haveIt;

/// Create a copy of PantryItem
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$BooleanTrackedPantryItemCopyWith<BooleanTrackedPantryItem> get copyWith => _$BooleanTrackedPantryItemCopyWithImpl<BooleanTrackedPantryItem>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is BooleanTrackedPantryItem&&(identical(other.ingredientId, ingredientId) || other.ingredientId == ingredientId)&&(identical(other.category, category) || other.category == category)&&(identical(other.presentation, presentation) || other.presentation == presentation)&&(identical(other.haveIt, haveIt) || other.haveIt == haveIt));
}


@override
int get hashCode => Object.hash(runtimeType,ingredientId,category,presentation,haveIt);

@override
String toString() {
  return 'PantryItem.booleanTracked(ingredientId: $ingredientId, category: $category, presentation: $presentation, haveIt: $haveIt)';
}


}

/// @nodoc
abstract mixin class $BooleanTrackedPantryItemCopyWith<$Res> implements $PantryItemCopyWith<$Res> {
  factory $BooleanTrackedPantryItemCopyWith(BooleanTrackedPantryItem value, $Res Function(BooleanTrackedPantryItem) _then) = _$BooleanTrackedPantryItemCopyWithImpl;
@override @useResult
$Res call({
 String ingredientId, Category category, Presentation presentation, bool haveIt
});


@override $PresentationCopyWith<$Res> get presentation;

}
/// @nodoc
class _$BooleanTrackedPantryItemCopyWithImpl<$Res>
    implements $BooleanTrackedPantryItemCopyWith<$Res> {
  _$BooleanTrackedPantryItemCopyWithImpl(this._self, this._then);

  final BooleanTrackedPantryItem _self;
  final $Res Function(BooleanTrackedPantryItem) _then;

/// Create a copy of PantryItem
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? ingredientId = null,Object? category = null,Object? presentation = null,Object? haveIt = null,}) {
  return _then(BooleanTrackedPantryItem(
ingredientId: null == ingredientId ? _self.ingredientId : ingredientId // ignore: cast_nullable_to_non_nullable
as String,category: null == category ? _self.category : category // ignore: cast_nullable_to_non_nullable
as Category,presentation: null == presentation ? _self.presentation : presentation // ignore: cast_nullable_to_non_nullable
as Presentation,haveIt: null == haveIt ? _self.haveIt : haveIt // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

/// Create a copy of PantryItem
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$PresentationCopyWith<$Res> get presentation {
  
  return $PresentationCopyWith<$Res>(_self.presentation, (value) {
    return _then(_self.copyWith(presentation: value));
  });
}
}

// dart format on
