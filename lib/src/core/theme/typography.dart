import 'package:flutter/material.dart';

/// Centralized text styles.
abstract final class MenuarioTypography {
  const MenuarioTypography._();

  static const h1 = TextStyle(fontSize: 32, fontWeight: FontWeight.w700);
  static const h2 = TextStyle(fontSize: 28, fontWeight: FontWeight.w700);
  static const h3 = TextStyle(fontSize: 24, fontWeight: FontWeight.w600);
  static const h4 = TextStyle(fontSize: 20, fontWeight: FontWeight.w600);
  static const h5 = TextStyle(fontSize: 18, fontWeight: FontWeight.w600);
  static const h6 = TextStyle(fontSize: 16, fontWeight: FontWeight.w600);
  static const body = TextStyle(fontSize: 14, fontWeight: FontWeight.w400);
}

/// Convenience helpers layered on top of [TextStyle].
extension MenuarioTextStyleX on TextStyle {
  /// Returns a bold variant of this style.
  TextStyle get bold => copyWith(fontWeight: FontWeight.bold);

  /// Returns this style tinted with [color].
  TextStyle withColor(Color color) => copyWith(color: color);
}
