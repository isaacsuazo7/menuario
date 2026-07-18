import 'package:flutter/material.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:menuario/src/core/theme/app_seed.dart';
import 'package:menuario/src/shared/domain/entities/theme_settings.dart';

part 'theme_settings_dto.freezed.dart';
part 'theme_settings_dto.g.dart';

/// JSON representation of [ThemeSettings], stored at the fixed
/// `users/{uid}/settings/theme` document.
///
/// Both fields are nullable and read through tolerant [JsonKey.readValue]
/// helpers so a hand-edited, partially-written or schema-drifted document
/// NEVER throws while decoding: an unreadable value simply becomes `null` and
/// [ThemeSettingsDTOX.toEntity] substitutes the matching default. A wrong
/// theme is a cosmetic annoyance; a decode failure on this document would
/// leave the app with no theme at all.
@freezed
abstract class ThemeSettingsDTO with _$ThemeSettingsDTO {
  const factory ThemeSettingsDTO({
    @JsonKey(readValue: _readString) String? mode,
    @JsonKey(readValue: _readInt) int? seed,
  }) = _ThemeSettingsDTO;

  const ThemeSettingsDTO._();

  factory ThemeSettingsDTO.fromJson(Map<String, dynamic> json) =>
      _$ThemeSettingsDTOFromJson(json);

  /// Builds a [ThemeSettingsDTO] from a [ThemeSettings] entity.
  static ThemeSettingsDTO fromEntity(ThemeSettings entity) {
    return ThemeSettingsDTO(
      mode: entity.mode.name,
      seed: entity.seed.toARGB32(),
    );
  }
}

/// Bidirectional mapper: [ThemeSettingsDTO] -> [ThemeSettings].
extension ThemeSettingsDTOX on ThemeSettingsDTO {
  /// Rebuilds the [ThemeSettings] entity, substituting
  /// [ThemeSettings.defaults] for any absent, unknown or uncurated value.
  ThemeSettings toEntity() {
    return ThemeSettings(
      mode: _modeFor(mode) ?? ThemeSettings.defaults.mode,
      seed: menuarioSeedFor(seed) ?? ThemeSettings.defaults.seed,
    );
  }
}

/// Resolves a [ThemeMode] from its persisted [ThemeMode.name], or `null`
/// when the stored string names no known mode.
ThemeMode? _modeFor(String? name) {
  for (final mode in ThemeMode.values) {
    if (mode.name == name) return mode;
  }

  return null;
}

Object? _readString(Map<dynamic, dynamic> json, String key) {
  final value = json[key];
  return value is String ? value : null;
}

Object? _readInt(Map<dynamic, dynamic> json, String key) {
  final value = json[key];
  return value is int ? value : null;
}
