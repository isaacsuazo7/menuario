// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'presentation_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_PresentationDTO _$PresentationDTOFromJson(Map<String, dynamic> json) =>
    _PresentationDTO(
      type: json['type'] as String,
      yieldQty: json['yieldQty'] as num?,
      label: json['label'] as String?,
    );

Map<String, dynamic> _$PresentationDTOToJson(_PresentationDTO instance) =>
    <String, dynamic>{
      'type': instance.type,
      'yieldQty': instance.yieldQty,
      'label': instance.label,
    };
