// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'quantity_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_QuantityDTO _$QuantityDTOFromJson(Map<String, dynamic> json) => _QuantityDTO(
  value: json['value'] as num,
  unitSymbol: json['unitSymbol'] as String,
  unitDimension: json['unitDimension'] as String,
);

Map<String, dynamic> _$QuantityDTOToJson(_QuantityDTO instance) =>
    <String, dynamic>{
      'value': instance.value,
      'unitSymbol': instance.unitSymbol,
      'unitDimension': instance.unitDimension,
    };
