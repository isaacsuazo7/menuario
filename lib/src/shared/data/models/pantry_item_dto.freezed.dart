// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'pantry_item_dto.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
PantryItemDTO _$PantryItemDTOFromJson(
  Map<String, dynamic> json
) {
        switch (json['type']) {
                  case 'quantityTracked':
          return QuantityTrackedPantryItemDTO.fromJson(
            json
          );
                case 'booleanTracked':
          return BooleanTrackedPantryItemDTO.fromJson(
            json
          );
        
          default:
            throw CheckedFromJsonException(
  json,
  'type',
  'PantryItemDTO',
  'Invalid union type "${json['type']}"!'
);
        }
      
}

/// @nodoc
mixin _$PantryItemDTO {

 String get category;
/// Create a copy of PantryItemDTO
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PantryItemDTOCopyWith<PantryItemDTO> get copyWith => _$PantryItemDTOCopyWithImpl<PantryItemDTO>(this as PantryItemDTO, _$identity);

  /// Serializes this PantryItemDTO to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PantryItemDTO&&(identical(other.category, category) || other.category == category));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,category);

@override
String toString() {
  return 'PantryItemDTO(category: $category)';
}


}

/// @nodoc
abstract mixin class $PantryItemDTOCopyWith<$Res>  {
  factory $PantryItemDTOCopyWith(PantryItemDTO value, $Res Function(PantryItemDTO) _then) = _$PantryItemDTOCopyWithImpl;
@useResult
$Res call({
 String category
});




}
/// @nodoc
class _$PantryItemDTOCopyWithImpl<$Res>
    implements $PantryItemDTOCopyWith<$Res> {
  _$PantryItemDTOCopyWithImpl(this._self, this._then);

  final PantryItemDTO _self;
  final $Res Function(PantryItemDTO) _then;

/// Create a copy of PantryItemDTO
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? category = null,}) {
  return _then(_self.copyWith(
category: null == category ? _self.category : category // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [PantryItemDTO].
extension PantryItemDTOPatterns on PantryItemDTO {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( QuantityTrackedPantryItemDTO value)?  quantityTracked,TResult Function( BooleanTrackedPantryItemDTO value)?  booleanTracked,required TResult orElse(),}){
final _that = this;
switch (_that) {
case QuantityTrackedPantryItemDTO() when quantityTracked != null:
return quantityTracked(_that);case BooleanTrackedPantryItemDTO() when booleanTracked != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( QuantityTrackedPantryItemDTO value)  quantityTracked,required TResult Function( BooleanTrackedPantryItemDTO value)  booleanTracked,}){
final _that = this;
switch (_that) {
case QuantityTrackedPantryItemDTO():
return quantityTracked(_that);case BooleanTrackedPantryItemDTO():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( QuantityTrackedPantryItemDTO value)?  quantityTracked,TResult? Function( BooleanTrackedPantryItemDTO value)?  booleanTracked,}){
final _that = this;
switch (_that) {
case QuantityTrackedPantryItemDTO() when quantityTracked != null:
return quantityTracked(_that);case BooleanTrackedPantryItemDTO() when booleanTracked != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function( String category,  QuantityDTO stock)?  quantityTracked,TResult Function( String category,  bool haveIt)?  booleanTracked,required TResult orElse(),}) {final _that = this;
switch (_that) {
case QuantityTrackedPantryItemDTO() when quantityTracked != null:
return quantityTracked(_that.category,_that.stock);case BooleanTrackedPantryItemDTO() when booleanTracked != null:
return booleanTracked(_that.category,_that.haveIt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function( String category,  QuantityDTO stock)  quantityTracked,required TResult Function( String category,  bool haveIt)  booleanTracked,}) {final _that = this;
switch (_that) {
case QuantityTrackedPantryItemDTO():
return quantityTracked(_that.category,_that.stock);case BooleanTrackedPantryItemDTO():
return booleanTracked(_that.category,_that.haveIt);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function( String category,  QuantityDTO stock)?  quantityTracked,TResult? Function( String category,  bool haveIt)?  booleanTracked,}) {final _that = this;
switch (_that) {
case QuantityTrackedPantryItemDTO() when quantityTracked != null:
return quantityTracked(_that.category,_that.stock);case BooleanTrackedPantryItemDTO() when booleanTracked != null:
return booleanTracked(_that.category,_that.haveIt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class QuantityTrackedPantryItemDTO implements PantryItemDTO {
  const QuantityTrackedPantryItemDTO({required this.category, required this.stock, final  String? $type}): $type = $type ?? 'quantityTracked';
  factory QuantityTrackedPantryItemDTO.fromJson(Map<String, dynamic> json) => _$QuantityTrackedPantryItemDTOFromJson(json);

@override final  String category;
 final  QuantityDTO stock;

@JsonKey(name: 'type')
final String $type;


/// Create a copy of PantryItemDTO
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$QuantityTrackedPantryItemDTOCopyWith<QuantityTrackedPantryItemDTO> get copyWith => _$QuantityTrackedPantryItemDTOCopyWithImpl<QuantityTrackedPantryItemDTO>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$QuantityTrackedPantryItemDTOToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is QuantityTrackedPantryItemDTO&&(identical(other.category, category) || other.category == category)&&(identical(other.stock, stock) || other.stock == stock));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,category,stock);

@override
String toString() {
  return 'PantryItemDTO.quantityTracked(category: $category, stock: $stock)';
}


}

/// @nodoc
abstract mixin class $QuantityTrackedPantryItemDTOCopyWith<$Res> implements $PantryItemDTOCopyWith<$Res> {
  factory $QuantityTrackedPantryItemDTOCopyWith(QuantityTrackedPantryItemDTO value, $Res Function(QuantityTrackedPantryItemDTO) _then) = _$QuantityTrackedPantryItemDTOCopyWithImpl;
@override @useResult
$Res call({
 String category, QuantityDTO stock
});


$QuantityDTOCopyWith<$Res> get stock;

}
/// @nodoc
class _$QuantityTrackedPantryItemDTOCopyWithImpl<$Res>
    implements $QuantityTrackedPantryItemDTOCopyWith<$Res> {
  _$QuantityTrackedPantryItemDTOCopyWithImpl(this._self, this._then);

  final QuantityTrackedPantryItemDTO _self;
  final $Res Function(QuantityTrackedPantryItemDTO) _then;

/// Create a copy of PantryItemDTO
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? category = null,Object? stock = null,}) {
  return _then(QuantityTrackedPantryItemDTO(
category: null == category ? _self.category : category // ignore: cast_nullable_to_non_nullable
as String,stock: null == stock ? _self.stock : stock // ignore: cast_nullable_to_non_nullable
as QuantityDTO,
  ));
}

/// Create a copy of PantryItemDTO
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$QuantityDTOCopyWith<$Res> get stock {
  
  return $QuantityDTOCopyWith<$Res>(_self.stock, (value) {
    return _then(_self.copyWith(stock: value));
  });
}
}

/// @nodoc
@JsonSerializable()

class BooleanTrackedPantryItemDTO implements PantryItemDTO {
  const BooleanTrackedPantryItemDTO({required this.category, required this.haveIt, final  String? $type}): $type = $type ?? 'booleanTracked';
  factory BooleanTrackedPantryItemDTO.fromJson(Map<String, dynamic> json) => _$BooleanTrackedPantryItemDTOFromJson(json);

@override final  String category;
 final  bool haveIt;

@JsonKey(name: 'type')
final String $type;


/// Create a copy of PantryItemDTO
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$BooleanTrackedPantryItemDTOCopyWith<BooleanTrackedPantryItemDTO> get copyWith => _$BooleanTrackedPantryItemDTOCopyWithImpl<BooleanTrackedPantryItemDTO>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$BooleanTrackedPantryItemDTOToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is BooleanTrackedPantryItemDTO&&(identical(other.category, category) || other.category == category)&&(identical(other.haveIt, haveIt) || other.haveIt == haveIt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,category,haveIt);

@override
String toString() {
  return 'PantryItemDTO.booleanTracked(category: $category, haveIt: $haveIt)';
}


}

/// @nodoc
abstract mixin class $BooleanTrackedPantryItemDTOCopyWith<$Res> implements $PantryItemDTOCopyWith<$Res> {
  factory $BooleanTrackedPantryItemDTOCopyWith(BooleanTrackedPantryItemDTO value, $Res Function(BooleanTrackedPantryItemDTO) _then) = _$BooleanTrackedPantryItemDTOCopyWithImpl;
@override @useResult
$Res call({
 String category, bool haveIt
});




}
/// @nodoc
class _$BooleanTrackedPantryItemDTOCopyWithImpl<$Res>
    implements $BooleanTrackedPantryItemDTOCopyWith<$Res> {
  _$BooleanTrackedPantryItemDTOCopyWithImpl(this._self, this._then);

  final BooleanTrackedPantryItemDTO _self;
  final $Res Function(BooleanTrackedPantryItemDTO) _then;

/// Create a copy of PantryItemDTO
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? category = null,Object? haveIt = null,}) {
  return _then(BooleanTrackedPantryItemDTO(
category: null == category ? _self.category : category // ignore: cast_nullable_to_non_nullable
as String,haveIt: null == haveIt ? _self.haveIt : haveIt // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

// dart format on
