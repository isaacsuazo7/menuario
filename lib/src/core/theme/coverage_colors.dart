import 'package:flutter/material.dart';
import 'package:menuario/src/shared/domain/value_objects/coverage_status.dart';

/// The Despensa row's tri-state weekly-budget coverage colors — the single
/// source of truth for [CoverageStatus] tinting, superseding the old
/// binary effective-zero tile tint.
///
/// Mirrors [MenuarioCategoryColors]'s dark/light-factory pattern; wired
/// into both [ThemeData] instances so `_quantity_pantry_row.dart` can read
/// `Theme.of(context).extension<MenuarioCoverageColors>()!`.
@immutable
class MenuarioCoverageColors extends ThemeExtension<MenuarioCoverageColors> {
  const MenuarioCoverageColors({
    required this.cubierto,
    required this.justo,
    required this.falta,
    required this.neutral,
  });

  /// Palette tuned for [Brightness.dark] surfaces.
  factory MenuarioCoverageColors.dark() => const MenuarioCoverageColors(
    cubierto: Color(0xFFA5D6A7),
    justo: Color(0xFFFFE082),
    falta: Color(0xFFEF9A9A),
    neutral: Color(0x00000000),
  );

  /// Palette tuned for [Brightness.light] surfaces.
  factory MenuarioCoverageColors.light() => const MenuarioCoverageColors(
    cubierto: Color(0xFF2E7D32),
    justo: Color(0xFFF9A825),
    falta: Color(0xFFC62828),
    neutral: Color(0x00000000),
  );

  /// Picks the palette matching [brightness].
  factory MenuarioCoverageColors.fromBrightness(Brightness brightness) =>
      brightness == Brightness.dark
      ? MenuarioCoverageColors.dark()
      : MenuarioCoverageColors.light();

  /// 🟢 Stock covers the whole weekly need.
  final Color cubierto;

  /// 🟡 Stock is short of the weekly need, but not effectively zero.
  final Color justo;

  /// 🔴 Stock is effectively zero with a real weekly need.
  final Color falta;

  /// No coverage tint — not planned this week, or no trustworthy signal.
  /// Fully transparent: [CoverageStatus.neutral] renders with no tile
  /// tint, same as an ingredient this palette never applies to.
  final Color neutral;

  /// Resolves the display color for [status].
  Color colorFor(CoverageStatus status) {
    return switch (status) {
      CoverageStatus.cubierto => cubierto,
      CoverageStatus.justo => justo,
      CoverageStatus.falta => falta,
      CoverageStatus.neutral => neutral,
    };
  }

  @override
  MenuarioCoverageColors copyWith({
    Color? cubierto,
    Color? justo,
    Color? falta,
    Color? neutral,
  }) {
    return MenuarioCoverageColors(
      cubierto: cubierto ?? this.cubierto,
      justo: justo ?? this.justo,
      falta: falta ?? this.falta,
      neutral: neutral ?? this.neutral,
    );
  }

  @override
  MenuarioCoverageColors lerp(
    ThemeExtension<MenuarioCoverageColors>? other,
    double t,
  ) {
    if (other is! MenuarioCoverageColors) return this;

    return MenuarioCoverageColors(
      cubierto: Color.lerp(cubierto, other.cubierto, t)!,
      justo: Color.lerp(justo, other.justo, t)!,
      falta: Color.lerp(falta, other.falta, t)!,
      neutral: Color.lerp(neutral, other.neutral, t)!,
    );
  }
}
