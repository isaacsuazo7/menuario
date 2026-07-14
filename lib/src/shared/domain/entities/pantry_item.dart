import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:menuario/src/shared/domain/value_objects/category.dart';
import 'package:menuario/src/shared/domain/value_objects/presentation.dart';
import 'package:menuario/src/shared/domain/value_objects/quantity.dart';

part 'pantry_item.freezed.dart';

/// A pantry record for one ingredient.
///
/// Mutually exclusive tracking shape, enforced at the type level via this
/// sealed union: [QuantityTrackedPantryItem] carries a numeric stock
/// [Quantity]; [BooleanTrackedPantryItem] carries only a have/don't-have
/// flag and never a numeric field. Which variant applies is driven by the
/// referenced [Ingredient.booleanTracked] flag.
@freezed
sealed class PantryItem with _$PantryItem {
  /// Tracked by numeric stock (e.g. avena, in grams).
  const factory PantryItem.quantityTracked({
    required String ingredientId,
    required Category category,
    required Presentation presentation,
    required Quantity stock,
  }) = QuantityTrackedPantryItem;

  /// Tracked by a simple have/don't-have flag (e.g. Comino, Sal).
  const factory PantryItem.booleanTracked({
    required String ingredientId,
    required Category category,
    required Presentation presentation,
    required bool haveIt,
  }) = BooleanTrackedPantryItem;
}
