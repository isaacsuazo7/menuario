import 'package:flutter/material.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:menuario/src/core/theme/app_seed.dart';

part 'theme_settings.freezed.dart';

/// The account's theme preferences: the [ThemeMode] to apply and the [seed]
/// Material 3 derives the whole palette from.
///
/// Account-scoped and editable (`users/{uid}/settings/theme`); see [defaults]
/// for the settings used when no document exists yet — or while signed out,
/// since the document lives under the user's own subtree.
///
/// Deliberately only these two axes: text colors and the domain color
/// extensions (`MenuarioCategoryColors`, `MenuarioCoverageColors`) stay
/// derived from brightness, never from the seed.
@freezed
abstract class ThemeSettings with _$ThemeSettings {
  const ThemeSettings._();

  const factory ThemeSettings({required ThemeMode mode, required Color seed}) =
      _ThemeSettings;

  /// The pre-customization behavior: dark mode on the [menuarioSeed] palette.
  static const ThemeSettings defaults = ThemeSettings(
    mode: ThemeMode.dark,
    seed: menuarioSeed,
  );
}
