import 'package:flutter/material.dart';
import 'package:menuario/src/core/theme/app_seed.dart';
import 'package:menuario/src/core/theme/category_colors.dart';
import 'package:menuario/src/core/theme/coverage_colors.dart';

/// Centralized Material 3 theme definitions for Menuario.
///
/// Both [dark] and [light] derive their [ColorScheme] from the same
/// [menuarioSeed], keeping re-coloring the whole app a one-line change.
abstract final class MenuarioTheme {
  const MenuarioTheme._();

  /// The default theme — dark by design (app-shell design D2).
  static ThemeData get dark => _build(brightness: Brightness.dark);

  /// The light counterpart, reachable via [ThemeMode] switching.
  static ThemeData get light => _build(brightness: Brightness.light);

  static ThemeData _build({required Brightness brightness}) {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: menuarioSeed,
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
