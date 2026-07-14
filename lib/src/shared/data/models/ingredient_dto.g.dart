// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ingredient_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_IngredientDTO _$IngredientDTOFromJson(Map<String, dynamic> json) =>
    _IngredientDTO(
      name: json['name'] as String,
      emoji: json['emoji'] as String?,
      category: json['category'] as String,
      measurementKind: json['measurementKind'] as String,
      booleanTracked: json['booleanTracked'] as bool,
      conversionFactor: json['conversionFactor'] as num?,
    );

Map<String, dynamic> _$IngredientDTOToJson(_IngredientDTO instance) =>
    <String, dynamic>{
      'name': instance.name,
      'emoji': instance.emoji,
      'category': instance.category,
      'measurementKind': instance.measurementKind,
      'booleanTracked': instance.booleanTracked,
      'conversionFactor': instance.conversionFactor,
    };
