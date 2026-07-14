import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:menuario/src/shared/data/models/presentation_dto.dart';
import 'package:menuario/src/shared/data/models/quantity_dto.dart';
import 'package:menuario/src/shared/domain/entities/pantry_item.dart';
import 'package:menuario/src/shared/domain/value_objects/category.dart';

part 'pantry_item_dto.freezed.dart';
part 'pantry_item_dto.g.dart';

/// JSON representation of a [PantryItem].
///
/// Mirrors the domain sealed union with an explicit `type` discriminator
/// (`quantityTracked` | `booleanTracked`) instead of relying on freezed's
/// default `runtimeType` key. [PantryItem.ingredientId] is never stored in
/// the map: it is the Firestore `doc.id` and is injected back via
/// [PantryItemDTOX.toEntity].
@Freezed(unionKey: 'type')
sealed class PantryItemDTO with _$PantryItemDTO {
  /// Tracked by numeric stock (mirrors [PantryItem.quantityTracked]).
  const factory PantryItemDTO.quantityTracked({
    required String category,
    required PresentationDTO presentation,
    required QuantityDTO stock,
  }) = QuantityTrackedPantryItemDTO;

  /// Tracked by a have/don't-have flag (mirrors
  /// [PantryItem.booleanTracked]).
  const factory PantryItemDTO.booleanTracked({
    required String category,
    required PresentationDTO presentation,
    required bool haveIt,
  }) = BooleanTrackedPantryItemDTO;

  factory PantryItemDTO.fromJson(Map<String, dynamic> json) =>
      _$PantryItemDTOFromJson(json);

  /// Builds a [PantryItemDTO] from a [PantryItem] entity, dropping its
  /// [PantryItem.ingredientId].
  static PantryItemDTO fromEntity(PantryItem entity) {
    return switch (entity) {
      QuantityTrackedPantryItem(
        :final category,
        :final presentation,
        :final stock,
      ) =>
        PantryItemDTO.quantityTracked(
          category: category.name,
          presentation: PresentationDTO.fromEntity(presentation),
          stock: QuantityDTO.fromEntity(stock),
        ),
      BooleanTrackedPantryItem(
        :final category,
        :final presentation,
        :final haveIt,
      ) =>
        PantryItemDTO.booleanTracked(
          category: category.name,
          presentation: PresentationDTO.fromEntity(presentation),
          haveIt: haveIt,
        ),
    };
  }
}

/// Bidirectional mapper: [PantryItemDTO] -> [PantryItem].
extension PantryItemDTOX on PantryItemDTO {
  /// Rebuilds the [PantryItem] entity carried by this DTO, injecting
  /// [ingredientId] (the Firestore `doc.id`) since it is not part of the
  /// stored map.
  PantryItem toEntity({required String ingredientId}) {
    return switch (this) {
      QuantityTrackedPantryItemDTO(
        :final category,
        :final presentation,
        :final stock,
      ) =>
        PantryItem.quantityTracked(
          ingredientId: ingredientId,
          category: Category.values.byName(category),
          presentation: presentation.toEntity(),
          stock: stock.toEntity(),
        ),
      BooleanTrackedPantryItemDTO(
        :final category,
        :final presentation,
        :final haveIt,
      ) =>
        PantryItem.booleanTracked(
          ingredientId: ingredientId,
          category: Category.values.byName(category),
          presentation: presentation.toEntity(),
          haveIt: haveIt,
        ),
    };
  }
}
