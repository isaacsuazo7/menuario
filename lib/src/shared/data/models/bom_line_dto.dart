import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:menuario/src/shared/data/models/quantity_dto.dart';
import 'package:menuario/src/shared/domain/entities/bom_line.dart';

part 'bom_line_dto.freezed.dart';
part 'bom_line_dto.g.dart';

/// JSON representation of a [BomLine], nested inside `RecipeDTO.bomLines`.
///
/// [quantity] is nullable and read through a tolerant [JsonKey.readValue]
/// helper (mirroring `theme_settings_dto.dart`) so an absent, null or
/// schema-drifted value decodes to `null` instead of throwing: an "al
/// gusto" line simply omits the key. Every recipe document written before
/// this field became optional carries a well-formed quantity map and keeps
/// decoding byte-for-byte as it did before — losing a whole recipe to a
/// decode failure is far worse than losing one line's number.
@freezed
abstract class BomLineDTO with _$BomLineDTO {
  const factory BomLineDTO({
    required String recipeId,
    required String ingredientId,
    @JsonKey(readValue: _readQuantity) QuantityDTO? quantity,
  }) = _BomLineDTO;

  const BomLineDTO._();

  factory BomLineDTO.fromJson(Map<String, dynamic> json) =>
      _$BomLineDTOFromJson(json);

  /// Builds a [BomLineDTO] from a [BomLine] entity.
  static BomLineDTO fromEntity(BomLine entity) {
    final quantity = entity.quantity;
    return BomLineDTO(
      recipeId: entity.recipeId,
      ingredientId: entity.ingredientId,
      quantity: quantity == null ? null : QuantityDTO.fromEntity(quantity),
    );
  }
}

/// Bidirectional mapper: [BomLineDTO] -> [BomLine].
extension BomLineDTOX on BomLineDTO {
  /// Rebuilds the [BomLine] entity carried by this DTO, leaving [BomLine
  /// .quantity] `null` for an "al gusto" line.
  BomLine toEntity() {
    final quantity = this.quantity;
    return BomLine(
      recipeId: recipeId,
      ingredientId: ingredientId,
      quantity: quantity?.toEntity(),
    );
  }
}

/// Reads the nested `quantity` map, yielding `null` for anything that is
/// not a well-formed JSON object — an absent key, an explicit null, or a
/// schema-drifted scalar all decode to "no quantity" rather than throwing.
Object? _readQuantity(Map<dynamic, dynamic> json, String key) {
  final value = json[key];
  return value is Map<String, dynamic> ? value : null;
}
