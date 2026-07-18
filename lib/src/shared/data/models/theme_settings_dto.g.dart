// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'theme_settings_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_ThemeSettingsDTO _$ThemeSettingsDTOFromJson(Map<String, dynamic> json) =>
    _ThemeSettingsDTO(
      mode: _readString(json, 'mode') as String?,
      seed: (_readInt(json, 'seed') as num?)?.toInt(),
    );

Map<String, dynamic> _$ThemeSettingsDTOToJson(_ThemeSettingsDTO instance) =>
    <String, dynamic>{'mode': instance.mode, 'seed': instance.seed};
