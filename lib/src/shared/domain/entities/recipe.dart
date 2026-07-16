import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:menuario/src/shared/domain/entities/bom_line.dart';
import 'package:menuario/src/shared/domain/value_objects/meal_type.dart';
import 'package:menuario/src/shared/domain/value_objects/video_link.dart';

part 'recipe.freezed.dart';

/// A recipe as an ordered bill of materials ([bomLines]).
///
/// [enabled] soft-archives a recipe: a disabled recipe stays reopenable
/// (edit/detail) but is excluded from grid, pickers and budget
/// aggregation elsewhere in the app — see `sdd/recipe-crud`.
@freezed
abstract class Recipe with _$Recipe {
  const factory Recipe({
    required String id,
    required String name,
    String? emoji,
    MealType? mealType,
    required List<BomLine> bomLines,
    @Default(<VideoLink>[]) List<VideoLink> videos,
    @Default(true) bool enabled,
  }) = _Recipe;
}
