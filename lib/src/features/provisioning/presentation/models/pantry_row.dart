import 'package:menuario/src/shared/shared.dart';

/// A [PantryItem] resolved with its matching [Ingredient] display data
/// (name + emoji), ready for the Despensa list to render.
///
/// Plain immutable composite — no `freezed` needed, this never round-trips
/// through JSON or needs deep equality beyond object identity for the UI.
class PantryRow {
  const PantryRow({required this.item, required this.ingredient});

  /// The pantry record (quantity- or boolean-tracked).
  final PantryItem item;

  /// The resolved ingredient (name, emoji) [item] refers to.
  final Ingredient ingredient;
}

/// A fixed-order [Category] bucket of [PantryRow]s for the grouped list.
class PantryCategoryGroup {
  const PantryCategoryGroup({required this.category, required this.rows});

  /// The category every row in [rows] belongs to.
  final Category category;

  /// The pantry rows belonging to [category], in list order.
  final List<PantryRow> rows;
}
