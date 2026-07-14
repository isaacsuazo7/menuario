// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'week_plan_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_WeekPlanDTO _$WeekPlanDTOFromJson(Map<String, dynamic> json) => _WeekPlanDTO(
  entries: (json['entries'] as List<dynamic>)
      .map((e) => PlanEntryDTO.fromJson(e as Map<String, dynamic>))
      .toList(),
);

Map<String, dynamic> _$WeekPlanDTOToJson(_WeekPlanDTO instance) =>
    <String, dynamic>{
      'entries': instance.entries.map((e) => e.toJson()).toList(),
    };
