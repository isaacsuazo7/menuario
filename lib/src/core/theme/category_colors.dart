import 'package:flutter/material.dart';

/// Reserved semantic colors for future ingredient/recipe category badges.
///
/// Not yet consumed by any screen in this slice — wired into both
/// [ThemeData] instances so future data screens can read
/// `Theme.of(context).extension<MenuarioCategoryColors>()!`.
@immutable
class MenuarioCategoryColors extends ThemeExtension<MenuarioCategoryColors> {
  const MenuarioCategoryColors({
    required this.proteina,
    required this.vegetal,
    required this.fruta,
    required this.cereal,
    required this.lacteo,
    required this.condimento,
    required this.semilla,
  });

  /// Palette tuned for [Brightness.dark] surfaces.
  factory MenuarioCategoryColors.dark() => const MenuarioCategoryColors(
    proteina: Color(0xFFEF9A9A),
    vegetal: Color(0xFFA5D6A7),
    fruta: Color(0xFFFFCC80),
    cereal: Color(0xFFD7CCC8),
    lacteo: Color(0xFF90CAF9),
    condimento: Color(0xFFFFF59D),
    semilla: Color(0xFFBCAAA4),
  );

  /// Palette tuned for [Brightness.light] surfaces.
  factory MenuarioCategoryColors.light() => const MenuarioCategoryColors(
    proteina: Color(0xFFC62828),
    vegetal: Color(0xFF2E7D32),
    fruta: Color(0xFFEF6C00),
    cereal: Color(0xFF6D4C41),
    lacteo: Color(0xFF1565C0),
    condimento: Color(0xFFF9A825),
    semilla: Color(0xFF4E342E),
  );

  /// Picks the palette matching [brightness].
  factory MenuarioCategoryColors.fromBrightness(Brightness brightness) =>
      brightness == Brightness.dark
      ? MenuarioCategoryColors.dark()
      : MenuarioCategoryColors.light();

  /// Categoría "Proteína".
  final Color proteina;

  /// Categoría "Vegetal".
  final Color vegetal;

  /// Categoría "Fruta".
  final Color fruta;

  /// Categoría "Cereal".
  final Color cereal;

  /// Categoría "Lácteo".
  final Color lacteo;

  /// Categoría "Condimento".
  final Color condimento;

  /// Categoría "Semilla".
  final Color semilla;

  @override
  MenuarioCategoryColors copyWith({
    Color? proteina,
    Color? vegetal,
    Color? fruta,
    Color? cereal,
    Color? lacteo,
    Color? condimento,
    Color? semilla,
  }) {
    return MenuarioCategoryColors(
      proteina: proteina ?? this.proteina,
      vegetal: vegetal ?? this.vegetal,
      fruta: fruta ?? this.fruta,
      cereal: cereal ?? this.cereal,
      lacteo: lacteo ?? this.lacteo,
      condimento: condimento ?? this.condimento,
      semilla: semilla ?? this.semilla,
    );
  }

  @override
  MenuarioCategoryColors lerp(
    ThemeExtension<MenuarioCategoryColors>? other,
    double t,
  ) {
    if (other is! MenuarioCategoryColors) return this;

    return MenuarioCategoryColors(
      proteina: Color.lerp(proteina, other.proteina, t)!,
      vegetal: Color.lerp(vegetal, other.vegetal, t)!,
      fruta: Color.lerp(fruta, other.fruta, t)!,
      cereal: Color.lerp(cereal, other.cereal, t)!,
      lacteo: Color.lerp(lacteo, other.lacteo, t)!,
      condimento: Color.lerp(condimento, other.condimento, t)!,
      semilla: Color.lerp(semilla, other.semilla, t)!,
    );
  }
}
