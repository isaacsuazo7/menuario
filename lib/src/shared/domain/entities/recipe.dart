import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:menuario/src/shared/domain/entities/bom_line.dart';
import 'package:menuario/src/shared/domain/value_objects/meal_type.dart';

part 'recipe.freezed.dart';

/// A recipe as an ordered bill of materials ([bomLines]).
@freezed
abstract class Recipe with _$Recipe {
  const factory Recipe({
    required String id,
    required String name,
    String? emoji,
    MealType? mealType,
    required List<BomLine> bomLines,
  }) = _Recipe;
}
