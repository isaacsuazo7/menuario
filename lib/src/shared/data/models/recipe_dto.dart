import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:menuario/src/shared/data/models/bom_line_dto.dart';
import 'package:menuario/src/shared/data/models/video_link_dto.dart';
import 'package:menuario/src/shared/domain/entities/recipe.dart';
import 'package:menuario/src/shared/domain/value_objects/meal_type.dart';

part 'recipe_dto.freezed.dart';
part 'recipe_dto.g.dart';

/// JSON representation of a [Recipe].
///
/// [Recipe.id] is never stored in the map: it is the Firestore `doc.id`
/// and is injected back via [RecipeDTOX.toEntity].
///
/// [videos] and [enabled] are nullable so an old-shape document written
/// before this rollout — which has neither key — still loads: see
/// [RecipeDTOX.toEntity] for the back-compat defaults (`[]` / `true`),
/// mirroring [IngredientDTO.needType].
@freezed
abstract class RecipeDTO with _$RecipeDTO {
  const factory RecipeDTO({
    required String name,
    String? emoji,
    String? mealType,
    required List<BomLineDTO> bomLines,
    List<VideoLinkDTO>? videos,
    bool? enabled,
  }) = _RecipeDTO;

  const RecipeDTO._();

  factory RecipeDTO.fromJson(Map<String, dynamic> json) =>
      _$RecipeDTOFromJson(json);

  /// Builds a [RecipeDTO] from a [Recipe] entity, dropping its id.
  static RecipeDTO fromEntity(Recipe entity) {
    return RecipeDTO(
      name: entity.name,
      emoji: entity.emoji,
      mealType: entity.mealType?.wire,
      bomLines: entity.bomLines.map(BomLineDTO.fromEntity).toList(),
      videos: entity.videos.map(VideoLinkDTO.fromEntity).toList(),
      enabled: entity.enabled,
    );
  }
}

/// Bidirectional mapper: [RecipeDTO] -> [Recipe].
extension RecipeDTOX on RecipeDTO {
  /// Rebuilds the [Recipe] entity carried by this DTO, injecting [id] (the
  /// Firestore `doc.id`) since it is not part of the stored map. The
  /// ordered [bomLines] list is preserved. A missing [videos] key defaults
  /// to `[]` and a missing [enabled] key defaults to `true` — today's
  /// behavior for every document written before this rollout, unchanged.
  Recipe toEntity({required String id}) {
    return Recipe(
      id: id,
      name: name,
      emoji: emoji,
      mealType: MealType.fromWire(mealType),
      bomLines: bomLines.map((dto) => dto.toEntity()).toList(),
      videos: videos?.map((dto) => dto.toEntity()).toList() ?? const [],
      enabled: enabled ?? true,
    );
  }
}
