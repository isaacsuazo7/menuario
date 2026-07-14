import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:menuario/src/shared/data/models/bom_line_dto.dart';
import 'package:menuario/src/shared/domain/entities/recipe.dart';

part 'recipe_dto.freezed.dart';
part 'recipe_dto.g.dart';

/// JSON representation of a [Recipe].
///
/// [Recipe.id] is never stored in the map: it is the Firestore `doc.id`
/// and is injected back via [RecipeDTOX.toEntity].
@freezed
abstract class RecipeDTO with _$RecipeDTO {
  const factory RecipeDTO({
    required String name,
    required List<BomLineDTO> bomLines,
  }) = _RecipeDTO;

  const RecipeDTO._();

  factory RecipeDTO.fromJson(Map<String, dynamic> json) =>
      _$RecipeDTOFromJson(json);

  /// Builds a [RecipeDTO] from a [Recipe] entity, dropping its id.
  static RecipeDTO fromEntity(Recipe entity) {
    return RecipeDTO(
      name: entity.name,
      bomLines: entity.bomLines.map(BomLineDTO.fromEntity).toList(),
    );
  }
}

/// Bidirectional mapper: [RecipeDTO] -> [Recipe].
extension RecipeDTOX on RecipeDTO {
  /// Rebuilds the [Recipe] entity carried by this DTO, injecting [id] (the
  /// Firestore `doc.id`) since it is not part of the stored map. The
  /// ordered [bomLines] list is preserved.
  Recipe toEntity({required String id}) {
    return Recipe(
      id: id,
      name: name,
      bomLines: bomLines.map((dto) => dto.toEntity()).toList(),
    );
  }
}
