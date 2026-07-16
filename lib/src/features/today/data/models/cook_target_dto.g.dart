// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'cook_target_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_CookTargetDTO _$CookTargetDTOFromJson(Map<String, dynamic> json) =>
    _CookTargetDTO(
      weekday: (json['weekday'] as num).toInt(),
      targetDay: json['targetDay'] as String,
      slot: json['slot'] as String,
      group: json['group'] as String,
    );

Map<String, dynamic> _$CookTargetDTOToJson(_CookTargetDTO instance) =>
    <String, dynamic>{
      'weekday': instance.weekday,
      'targetDay': instance.targetDay,
      'slot': instance.slot,
      'group': instance.group,
    };
