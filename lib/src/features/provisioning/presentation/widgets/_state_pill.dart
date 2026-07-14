import 'package:flutter/material.dart';

/// A compact have/don't-have indicator for a Despensa row.
///
/// Public despite the leading-underscore filename: it is shared across the
/// quantity- and boolean-tracked rows within this feature, so it must be
/// importable across files, per the EmsulaRH widget-colocation convention
/// (2+ screens/rows in the same feature -> `presentation/widgets/`).
class StatePill extends StatelessWidget {
  const StatePill({super.key, required this.isPositive});

  /// `true` for stock > 0 / `haveIt`; `false` for stock == 0 / don't-have.
  final bool isPositive;

  @override
  Widget build(BuildContext context) {
    return Text(isPositive ? '🟢 Tengo' : '🔴 No tengo');
  }
}
