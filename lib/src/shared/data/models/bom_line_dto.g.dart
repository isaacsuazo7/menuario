// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'bom_line_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_BomLineDTO _$BomLineDTOFromJson(Map<String, dynamic> json) => _BomLineDTO(
  recipeId: json['recipeId'] as String,
  ingredientId: json['ingredientId'] as String,
  quantity: _readQuantity(json, 'quantity') == null
      ? null
      : QuantityDTO.fromJson(
          _readQuantity(json, 'quantity') as Map<String, dynamic>,
        ),
);

Map<String, dynamic> _$BomLineDTOToJson(_BomLineDTO instance) =>
    <String, dynamic>{
      'recipeId': instance.recipeId,
      'ingredientId': instance.ingredientId,
      'quantity': instance.quantity?.toJson(),
    };
