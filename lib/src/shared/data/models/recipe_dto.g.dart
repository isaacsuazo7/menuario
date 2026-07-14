// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'recipe_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_RecipeDTO _$RecipeDTOFromJson(Map<String, dynamic> json) => _RecipeDTO(
  name: json['name'] as String,
  bomLines: (json['bomLines'] as List<dynamic>)
      .map((e) => BomLineDTO.fromJson(e as Map<String, dynamic>))
      .toList(),
);

Map<String, dynamic> _$RecipeDTOToJson(_RecipeDTO instance) =>
    <String, dynamic>{
      'name': instance.name,
      'bomLines': instance.bomLines.map((e) => e.toJson()).toList(),
    };
