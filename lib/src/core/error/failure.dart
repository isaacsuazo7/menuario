/// Represents a domain-level failure carried end-to-end through
/// `Either<Failure, T>` pipelines.
///
/// This is a trimmed port of EmsulaRH's `Failure`: it keeps the generic
/// shape (message, code, exception, stackTrace, metadata) but drops the
/// networking-specific `fromErrorResponse` factory, since this domain
/// kernel has no HTTP layer.
class Failure {
  final String message;
  final String? code;
  final Exception? exception;
  final StackTrace? stackTrace;
  final Map<String, dynamic>? metadata;

  const Failure({
    required this.message,
    this.code,
    this.exception,
    this.stackTrace,
    this.metadata,
  });

  /// The recipe/stock unit symbol is not recognized by the measurement
  /// engine.
  factory Failure.unknownUnit(String symbol) {
    return Failure(
      message: 'Unidad desconocida: "$symbol".',
      code: 'unknownUnit',
      metadata: {'symbol': symbol},
    );
  }

  /// A `bulk` ingredient has no per-ingredient conversion factor to go
  /// from its recipe unit to its stock unit.
  factory Failure.missingConversionFactor(String ingredientName) {
    return Failure(
      message: 'Falta el factor de conversión para "$ingredientName".',
      code: 'missingConversionFactor',
      metadata: {'ingredientName': ingredientName},
    );
  }

  /// Computed stock or consumption for an ingredient became negative.
  factory Failure.negativeStock(String ingredientName) {
    return Failure(
      message: 'El stock de "$ingredientName" no puede ser negativo.',
      code: 'negativeStock',
      metadata: {'ingredientName': ingredientName},
    );
  }

  /// A `PlanEntry` was given a day outside Lun-Sáb (Dom is rejected).
  factory Failure.invalidDay(String day) {
    return Failure(
      message: 'Día inválido: "$day". Solo se permite de Lun a Sáb.',
      code: 'invalidDay',
      metadata: {'day': day},
    );
  }

  /// An operation attempted to mutate an existing, immutable `BomLine`.
  factory Failure.mutateBom() {
    return const Failure(
      message:
          'No se puede modificar una línea de receta (BomLine) '
          'existente.',
      code: 'mutateBom',
    );
  }

  @override
  String toString() => 'Failure(message: $message, code: $code)';
}
