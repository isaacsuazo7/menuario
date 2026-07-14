import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:menuario/src/shared/domain/value_objects/quantity.dart';
import 'package:menuario/src/shared/domain/value_objects/unit.dart';

part 'quantity_dto.freezed.dart';
part 'quantity_dto.g.dart';

/// JSON representation of a [Quantity], nested inside the aggregates that
/// carry one (e.g. `BomLine`, `PantryItem`).
@freezed
abstract class QuantityDTO with _$QuantityDTO {
  const factory QuantityDTO({
    required num value,
    required String unitSymbol,
    required String unitDimension,
  }) = _QuantityDTO;

  const QuantityDTO._();

  factory QuantityDTO.fromJson(Map<String, dynamic> json) =>
      _$QuantityDTOFromJson(json);

  /// Builds a [QuantityDTO] from a [Quantity] entity.
  static QuantityDTO fromEntity(Quantity entity) {
    return QuantityDTO(
      value: entity.value,
      unitSymbol: entity.unit.symbol,
      unitDimension: entity.unit.dimension.name,
    );
  }
}

/// Bidirectional mapper: [QuantityDTO] -> [Quantity].
extension QuantityDTOX on QuantityDTO {
  /// Rebuilds the [Quantity] entity carried by this DTO.
  Quantity toEntity() {
    return Quantity(
      value: value,
      unit: Unit(
        symbol: unitSymbol,
        dimension: UnitDimension.values.byName(unitDimension),
      ),
    );
  }
}
