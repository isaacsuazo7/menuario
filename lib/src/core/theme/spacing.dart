import 'package:flutter/widgets.dart';

/// Centralized spacing tokens.
///
/// Prefer these constants over ad-hoc [SizedBox]/[EdgeInsets] literals so
/// gaps and paddings stay consistent across screens.
abstract final class MenuarioSpacing {
  const MenuarioSpacing._();

  static const double xs = 4;
  static const double sm = 8;
  static const double md = 16;
  static const double lg = 24;
  static const double xl = 32;

  /// Horizontal gap of [xs].
  static const gapH4 = SizedBox(width: xs);

  /// Horizontal gap of [sm].
  static const gapH8 = SizedBox(width: sm);

  /// Horizontal gap of [md].
  static const gapH16 = SizedBox(width: md);

  /// Horizontal gap of [lg].
  static const gapH24 = SizedBox(width: lg);

  /// Horizontal gap of [xl].
  static const gapH32 = SizedBox(width: xl);

  /// Vertical gap of [xs].
  static const gapV4 = SizedBox(height: xs);

  /// Vertical gap of [sm].
  static const gapV8 = SizedBox(height: sm);

  /// Vertical gap of [md].
  static const gapV16 = SizedBox(height: md);

  /// Vertical gap of [lg].
  static const gapV24 = SizedBox(height: lg);

  /// Vertical gap of [xl].
  static const gapV32 = SizedBox(height: xl);

  /// All-sides padding of [xs].
  static const paddingAll4 = EdgeInsets.all(xs);

  /// All-sides padding of [sm].
  static const paddingAll8 = EdgeInsets.all(sm);

  /// All-sides padding of [md].
  static const paddingAll16 = EdgeInsets.all(md);

  /// All-sides padding of [lg].
  static const paddingAll24 = EdgeInsets.all(lg);

  /// All-sides padding of [xl].
  static const paddingAll32 = EdgeInsets.all(xl);
}
