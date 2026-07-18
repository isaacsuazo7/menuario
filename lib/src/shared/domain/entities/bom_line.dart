import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:menuario/src/shared/domain/value_objects/quantity.dart';

part 'bom_line.freezed.dart';

/// A single line of a [Recipe]'s bill of materials: which ingredient the
/// recipe needs and, when it is measurable, how much of it in recipe units.
///
/// [quantity] is OPTIONAL — a `null` quantity is the "al gusto" line a
/// boolean-tracked ingredient carries (cilantro, miel, orégano): the recipe
/// genuinely uses it, but nobody weighs it, so there is no number and no
/// unit to record. Such a line is deliberately invisible to every numeric
/// path (weekly consumption, coverage, unit conversion) — those callers
/// MUST skip it rather than treat it as a zero need. Its purchase signal
/// comes from the pantry's `haveIt` flag instead.
///
/// Immutable by design — no core operation may mutate [quantity] or its
/// unit after creation, protecting an already-planned recipe. `copyWith`
/// always returns a new instance and never alters the original.
@freezed
abstract class BomLine with _$BomLine {
  const factory BomLine({
    required String recipeId,
    required String ingredientId,
    Quantity? quantity,
  }) = _BomLine;
}
