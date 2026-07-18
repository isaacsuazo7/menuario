import 'package:flutter/material.dart';
import 'package:menuario/src/core/theme/app_seed.dart';
import 'package:menuario/src/core/theme/category_colors.dart';
import 'package:menuario/src/core/theme/coverage_colors.dart';

/// Centralized Material 3 theme definitions for Menuario.
///
/// Both [dark] and [light] derive their [ColorScheme] from the seed they are
/// given, defaulting to [menuarioSeed]. The seed is the user's single color
/// lever: everything else — including every text color — is derived by
/// Material 3, never hand-picked.
abstract final class MenuarioTheme {
  const MenuarioTheme._();

  /// The default theme — dark by design (app-shell design D2).
  static ThemeData dark({Color seed = menuarioSeed}) =>
      _build(brightness: Brightness.dark, seed: seed);

  /// The light counterpart, reachable via [ThemeMode] switching.
  static ThemeData light({Color seed = menuarioSeed}) =>
      _build(brightness: Brightness.light, seed: seed);

  static ThemeData _build({
    required Brightness brightness,
    required Color seed,
  }) {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: seed,
      brightness: brightness,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      extensions: [
        MenuarioCategoryColors.fromBrightness(brightness),
        MenuarioCoverageColors.fromBrightness(brightness),
      ],
    );
  }
}
