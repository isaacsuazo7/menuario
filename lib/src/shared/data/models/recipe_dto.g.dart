// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'recipe_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_RecipeDTO _$RecipeDTOFromJson(Map<String, dynamic> json) => _RecipeDTO(
  name: json['name'] as String,
  emoji: json['emoji'] as String?,
  mealType: json['mealType'] as String?,
  bomLines: (json['bomLines'] as List<dynamic>)
      .map((e) => BomLineDTO.fromJson(e as Map<String, dynamic>))
      .toList(),
  videos: (json['videos'] as List<dynamic>?)
      ?.map((e) => VideoLinkDTO.fromJson(e as Map<String, dynamic>))
      .toList(),
  enabled: json['enabled'] as bool?,
);

Map<String, dynamic> _$RecipeDTOToJson(_RecipeDTO instance) =>
    <String, dynamic>{
      'name': instance.name,
      'emoji': instance.emoji,
      'mealType': instance.mealType,
      'bomLines': instance.bomLines.map((e) => e.toJson()).toList(),
      'videos': instance.videos?.map((e) => e.toJson()).toList(),
      'enabled': instance.enabled,
    };
