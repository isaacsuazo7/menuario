import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:menuario/src/shared/domain/entities/ingredient.dart';
import 'package:menuario/src/shared/domain/value_objects/category.dart';
import 'package:menuario/src/shared/domain/value_objects/measurement_kind.dart';

part 'ingredient_dto.freezed.dart';
part 'ingredient_dto.g.dart';

/// JSON representation of an [Ingredient].
///
/// [Ingredient.id] is never stored in the map: it is the Firestore
/// `doc.id` and is injected back via [IngredientDTOX.toEntity].
@freezed
abstract class IngredientDTO with _$IngredientDTO {
  const factory IngredientDTO({
    required String name,
    required String category,
    required String measurementKind,
    required bool booleanTracked,
    num? conversionFactor,
  }) = _IngredientDTO;

  const IngredientDTO._();

  factory IngredientDTO.fromJson(Map<String, dynamic> json) =>
      _$IngredientDTOFromJson(json);

  /// Builds an [IngredientDTO] from an [Ingredient] entity, dropping its id.
  static IngredientDTO fromEntity(Ingredient entity) {
    return IngredientDTO(
      name: entity.name,
      category: entity.category.name,
      measurementKind: entity.measurementKind.name,
      booleanTracked: entity.booleanTracked,
      conversionFactor: entity.conversionFactor,
    );
  }
}

/// Bidirectional mapper: [IngredientDTO] -> [Ingredient].
extension IngredientDTOX on IngredientDTO {
  /// Rebuilds the [Ingredient] entity carried by this DTO, injecting [id]
  /// (the Firestore `doc.id`) since it is not part of the stored map.
  Ingredient toEntity({required String id}) {
    return Ingredient(
      id: id,
      name: name,
      category: Category.values.byName(category),
      measurementKind: MeasurementKind.values.byName(measurementKind),
      booleanTracked: booleanTracked,
      conversionFactor: conversionFactor,
    );
  }
}
