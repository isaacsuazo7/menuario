import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:menuario/src/shared/domain/value_objects/quantity.dart';

part 'bom_line.freezed.dart';

/// A single line of a [Recipe]'s bill of materials: how much of one
/// ingredient the recipe needs, in recipe units.
///
/// Immutable by design — no core operation may mutate [quantity] or its
/// unit after creation, protecting an already-planned recipe. `copyWith`
/// always returns a new instance and never alters the original.
@freezed
abstract class BomLine with _$BomLine {
  const factory BomLine({
    required String recipeId,
    required String ingredientId,
    required Quantity quantity,
  }) = _BomLine;
}
