// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'package_spec_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_PackageSpecDTO _$PackageSpecDTOFromJson(Map<String, dynamic> json) =>
    _PackageSpecDTO(
      label: json['label'] as String,
      yieldQty: json['yieldQty'] as num?,
      baseDimensionSymbol: json['baseDimensionSymbol'] as String?,
      baseDimensionKind: json['baseDimensionKind'] as String?,
      innerLabel: json['innerLabel'] as String?,
      innerQty: json['innerQty'] as num?,
      innerCount: json['innerCount'] as num?,
    );

Map<String, dynamic> _$PackageSpecDTOToJson(_PackageSpecDTO instance) =>
    <String, dynamic>{
      'label': instance.label,
      'yieldQty': instance.yieldQty,
      'baseDimensionSymbol': instance.baseDimensionSymbol,
      'baseDimensionKind': instance.baseDimensionKind,
      'innerLabel': instance.innerLabel,
      'innerQty': instance.innerQty,
      'innerCount': instance.innerCount,
    };
