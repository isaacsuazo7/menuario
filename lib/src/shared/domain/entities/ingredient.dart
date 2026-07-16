import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:menuario/src/shared/domain/value_objects/category.dart';
import 'package:menuario/src/shared/domain/value_objects/measurement_kind.dart';
import 'package:menuario/src/shared/domain/value_objects/measurement_mode.dart';
import 'package:menuario/src/shared/domain/value_objects/need_type.dart';
import 'package:menuario/src/shared/domain/value_objects/package_spec.dart';

part 'ingredient.freezed.dart';

/// An ingredient master record: identity, category, how it is tracked and
/// how to convert its recipe-unit quantities into its stock unit.
///
/// [conversionFactor] is the per-ingredient recipe-unit → stock-unit
/// multiplier (e.g. 85 g/taza for avena). It only applies to
/// [MeasurementKind.bulk] ingredients; [MeasurementKind.unit] ingredients
/// need none, since their recipe unit already equals their stock unit.
/// Seeded values are loaded later at pantry data-entry time.
///
/// [measurementMode], [package] and [defaultLensLabel] are the flexible-
/// units replacement for the [measurementKind]/[booleanTracked] pair,
/// added additively here (default `mass`, `package`/`defaultLensLabel`
/// nullable) so every existing call site keeps compiling; the legacy
/// fields are dropped and DTOs updated in a later PR once consumers move
/// over. [measurementMode] drives `StockLensService`'s lens set,
/// canonical unit and formatter; [package] describes a packageBase/
/// packageAbstract ingredient's pack (label, yield, base dimension);
/// [defaultLensLabel] overrides the mode's default-lens heuristic
/// (e.g. forcing `g` instead of `lb`), persisted per ingredient.
///
/// [needType] classifies HOW this ingredient's weekly need is computed for
/// the weekly budget (coverage + shopping auto-calc): [NeedType.recipeDriven]
/// (default) sums planned-recipe consumption; [NeedType.weeklyFixed] needs
/// exactly 1 whole package when planned this week, else 0; [NeedType.optional]
/// is excluded from the weekly budget entirely. Replaces the
/// conversionFactor-backfill approach for perishables you buy whole and
/// that spoil (espinaca, lechuga, fresas, requesón, yogurt sin sabor).
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
    @Default(MeasurementMode.mass) MeasurementMode measurementMode,
    PackageSpec? package,
    String? defaultLensLabel,
    @Default(NeedType.recipeDriven) NeedType needType,
  }) = _Ingredient;
}
