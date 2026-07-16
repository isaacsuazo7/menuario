// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'cook_schedule_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_CookScheduleDTO _$CookScheduleDTOFromJson(Map<String, dynamic> json) =>
    _CookScheduleDTO(
      targets: (json['targets'] as List<dynamic>)
          .map((e) => CookTargetDTO.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$CookScheduleDTOToJson(_CookScheduleDTO instance) =>
    <String, dynamic>{
      'targets': instance.targets.map((e) => e.toJson()).toList(),
    };
