/// How an [Ingredient]'s recipe-unit quantities relate to its stock unit.
///
/// - `unit`: exact/count-tracked — recipe unit equals stock unit, no
///   conversion factor needed (e.g. huevo).
/// - `bulk`: continuous — requires a per-ingredient conversion factor to go
///   from recipe unit (e.g. taza) to stock unit (e.g. g).
enum MeasurementKind { unit, bulk }
