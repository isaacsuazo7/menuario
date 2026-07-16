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
      measurementKind: json['measurementKind'] as String?,
      booleanTracked: json['booleanTracked'] as bool?,
      conversionFactor: json['conversionFactor'] as num?,
      measurementMode: json['measurementMode'] as String?,
      package: json['package'] == null
          ? null
          : PackageSpecDTO.fromJson(json['package'] as Map<String, dynamic>),
      defaultLensLabel: json['defaultLensLabel'] as String?,
      needType: json['needType'] as String?,
    );

Map<String, dynamic> _$IngredientDTOToJson(_IngredientDTO instance) =>
    <String, dynamic>{
      'name': instance.name,
      'emoji': instance.emoji,
      'category': instance.category,
      'measurementKind': instance.measurementKind,
      'booleanTracked': instance.booleanTracked,
      'conversionFactor': instance.conversionFactor,
      'measurementMode': instance.measurementMode,
      'package': instance.package?.toJson(),
      'defaultLensLabel': instance.defaultLensLabel,
      'needType': instance.needType,
    };
