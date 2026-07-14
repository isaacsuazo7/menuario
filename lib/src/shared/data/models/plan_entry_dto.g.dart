// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'plan_entry_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_PlanEntryDTO _$PlanEntryDTOFromJson(Map<String, dynamic> json) =>
    _PlanEntryDTO(
      day: json['day'] as String,
      mealSlot: json['mealSlot'] as String,
      recipeId: json['recipeId'] as String,
      cooked: json['cooked'] as bool,
    );

Map<String, dynamic> _$PlanEntryDTOToJson(_PlanEntryDTO instance) =>
    <String, dynamic>{
      'day': instance.day,
      'mealSlot': instance.mealSlot,
      'recipeId': instance.recipeId,
      'cooked': instance.cooked,
    };
