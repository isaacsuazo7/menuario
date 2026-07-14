import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:menuario/src/shared/domain/value_objects/unit.dart';

part 'quantity.freezed.dart';

/// A numeric [value] tagged with its [Unit], with arithmetic guarded so
/// operations never silently mix incompatible units.
@freezed
abstract class Quantity with _$Quantity {
  const Quantity._();

  const factory Quantity({required num value, required Unit unit}) = _Quantity;

  /// Adds [other] to this quantity.
  ///
  /// Throws an [ArgumentError] when [other] has a different [Unit].
  Quantity operator +(Quantity other) {
    _assertSameUnit(other);
    return Quantity(value: value + other.value, unit: unit);
  }

  /// Subtracts [other] from this quantity.
  ///
  /// Throws an [ArgumentError] when [other] has a different [Unit].
  Quantity operator -(Quantity other) {
    _assertSameUnit(other);
    return Quantity(value: value - other.value, unit: unit);
  }

  /// Scales this quantity's value by [factor], keeping the same [Unit].
  Quantity operator *(num factor) {
    return Quantity(value: value * factor, unit: unit);
  }

  void _assertSameUnit(Quantity other) {
    if (unit != other.unit) {
      throw ArgumentError(
        'Cannot combine quantities with different units: '
        '${unit.symbol} vs ${other.unit.symbol}.',
      );
    }
  }
}
