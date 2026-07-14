import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:menuario/src/shared/data/models/quantity_dto.dart';
import 'package:menuario/src/shared/domain/entities/bom_line.dart';

part 'bom_line_dto.freezed.dart';
part 'bom_line_dto.g.dart';

/// JSON representation of a [BomLine], nested inside `RecipeDTO.bomLines`.
@freezed
abstract class BomLineDTO with _$BomLineDTO {
  const factory BomLineDTO({
    required String recipeId,
    required String ingredientId,
    required QuantityDTO quantity,
  }) = _BomLineDTO;

  const BomLineDTO._();

  factory BomLineDTO.fromJson(Map<String, dynamic> json) =>
      _$BomLineDTOFromJson(json);

  /// Builds a [BomLineDTO] from a [BomLine] entity.
  static BomLineDTO fromEntity(BomLine entity) {
    return BomLineDTO(
      recipeId: entity.recipeId,
      ingredientId: entity.ingredientId,
      quantity: QuantityDTO.fromEntity(entity.quantity),
    );
  }
}

/// Bidirectional mapper: [BomLineDTO] -> [BomLine].
extension BomLineDTOX on BomLineDTO {
  /// Rebuilds the [BomLine] entity carried by this DTO.
  BomLine toEntity() {
    return BomLine(
      recipeId: recipeId,
      ingredientId: ingredientId,
      quantity: quantity.toEntity(),
    );
  }
}
