import 'package:menuario/src/shared/domain/value_objects/quantity.dart';

/// What a BOM line shows in place of a number when it carries no
/// [Quantity] — the "al gusto" condiments and seeds nobody measures.
const String alGustoLabel = 'Al gusto';

/// The trailing label for one BOM line: its value and unit symbol, or
/// [alGustoLabel] when the line has no quantity.
///
/// Shared by every BOM-rendering surface (recipe detail, Hoy's meal sheet,
/// Semana's recipe sheet) so the three never drift apart on how a
/// quantity-less line reads.
String bomQuantityLabel(Quantity? quantity) {
  if (quantity == null) return alGustoLabel;

  return '${quantity.value} ${quantity.unit.symbol}';
}
