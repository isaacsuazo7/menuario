// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pantry_item_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

QuantityTrackedPantryItemDTO _$QuantityTrackedPantryItemDTOFromJson(
  Map<String, dynamic> json,
) => QuantityTrackedPantryItemDTO(
  category: json['category'] as String,
  stock: QuantityDTO.fromJson(json['stock'] as Map<String, dynamic>),
  $type: json['type'] as String?,
);

Map<String, dynamic> _$QuantityTrackedPantryItemDTOToJson(
  QuantityTrackedPantryItemDTO instance,
) => <String, dynamic>{
  'category': instance.category,
  'stock': instance.stock.toJson(),
  'type': instance.$type,
};

BooleanTrackedPantryItemDTO _$BooleanTrackedPantryItemDTOFromJson(
  Map<String, dynamic> json,
) => BooleanTrackedPantryItemDTO(
  category: json['category'] as String,
  haveIt: json['haveIt'] as bool,
  $type: json['type'] as String?,
);

Map<String, dynamic> _$BooleanTrackedPantryItemDTOToJson(
  BooleanTrackedPantryItemDTO instance,
) => <String, dynamic>{
  'category': instance.category,
  'haveIt': instance.haveIt,
  'type': instance.$type,
};
