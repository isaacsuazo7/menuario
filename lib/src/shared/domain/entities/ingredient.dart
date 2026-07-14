import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:menuario/src/shared/domain/value_objects/category.dart';
import 'package:menuario/src/shared/domain/value_objects/measurement_kind.dart';

part 'ingredient.freezed.dart';

/// An ingredient master record: identity, category, how it is tracked and
/// how to convert its recipe-unit quantities into its stock unit.
///
/// [conversionFactor] is the per-ingredient recipe-unit → stock-unit
/// multiplier (e.g. 85 g/taza for avena). It only applies to
/// [MeasurementKind.bulk] ingredients; [MeasurementKind.unit] ingredients
/// need none, since their recipe unit already equals their stock unit.
/// Seeded values are loaded later at pantry data-entry time.
@freezed
abstract class Ingredient with _$Ingredient {
  const factory Ingredient({
    required String id,
    required String name,
    String? emoji,
    required Category category,
    required MeasurementKind measurementKind,
    required bool booleanTracked,
    num? conversionFactor,
  }) = _Ingredient;
}
