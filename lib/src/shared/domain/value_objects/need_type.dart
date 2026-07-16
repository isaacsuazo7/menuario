/// How an [Ingredient]'s weekly need is computed for the weekly budget
/// (coverage + shopping auto-calc).
///
/// Replaces the conversionFactor-backfill approach for perishables you buy
/// whole and that spoil: instead of inventing a recipe-unit->stock-unit
/// factor, each ingredient declares HOW its weekly need is derived.
enum NeedType {
  /// Weekly need = the sum of planned-recipe consumption (current
  /// behavior). Default — proteins, grains, milk, yogurt griego.
  recipeDriven,

  /// Weekly need = 1 whole package IF the ingredient is used in at least
  /// one planned recipe this week, else 0 (neutral, no trustworthy
  /// signal). "Comprás uno, dura la semana" — espinaca, escarola/lechuga.
  weeklyFixed,

  /// Excluded from the weekly budget and the shopping auto-calc entirely;
  /// coverage is always neutral (just tracked via tengo/no-tengo stock).
  /// Never appears in "no se pudieron calcular". Fresas, requesón, yogurt
  /// sin sabor.
  optional,
}
