import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:menuario/src/shared/data/models/package_spec_dto.dart';
import 'package:menuario/src/shared/domain/entities/ingredient.dart';
import 'package:menuario/src/shared/domain/value_objects/category.dart';
import 'package:menuario/src/shared/domain/value_objects/measurement_kind.dart';
import 'package:menuario/src/shared/domain/value_objects/measurement_mode.dart';

part 'ingredient_dto.freezed.dart';
part 'ingredient_dto.g.dart';

/// JSON representation of an [Ingredient].
///
/// [Ingredient.id] is never stored in the map: it is the Firestore
/// `doc.id` and is injected back via [IngredientDTOX.toEntity].
///
/// [measurementMode]/[package]/[defaultLensLabel] are the flexible-units
/// replacement for [measurementKind]/[booleanTracked]. [fromEntity] always
/// writes both the new fields and the legacy ones (the entity still
/// carries every field), so every document this app version writes is
/// self-describing. [measurementKind]/[booleanTracked] are kept nullable
/// (rather than dropped) so an old-shape document written before this
/// rollout — which has them but no [measurementMode] — still loads; see
/// [IngredientDTOX.toEntity] for the back-compat derivation.
@freezed
abstract class IngredientDTO with _$IngredientDTO {
  const factory IngredientDTO({
    required String name,
    String? emoji,
    required String category,
    String? measurementKind,
    bool? booleanTracked,
    num? conversionFactor,
    String? measurementMode,
    PackageSpecDTO? package,
    String? defaultLensLabel,
  }) = _IngredientDTO;

  const IngredientDTO._();

  factory IngredientDTO.fromJson(Map<String, dynamic> json) =>
      _$IngredientDTOFromJson(json);

  /// Builds an [IngredientDTO] from an [Ingredient] entity, dropping its id.
  static IngredientDTO fromEntity(Ingredient entity) {
    return IngredientDTO(
      name: entity.name,
      emoji: entity.emoji,
      category: entity.category.name,
      measurementKind: entity.measurementKind.name,
      booleanTracked: entity.booleanTracked,
      conversionFactor: entity.conversionFactor,
      measurementMode: entity.measurementMode.name,
      package: entity.package == null
          ? null
          : PackageSpecDTO.fromEntity(entity.package!),
      defaultLensLabel: entity.defaultLensLabel,
    );
  }
}

/// Bidirectional mapper: [IngredientDTO] -> [Ingredient].
extension IngredientDTOX on IngredientDTO {
  /// Rebuilds the [Ingredient] entity carried by this DTO, injecting [id]
  /// (the Firestore `doc.id`) since it is not part of the stored map.
  ///
  /// When [measurementMode] is present (every document this app version
  /// writes), it — and [measurementKind]/[booleanTracked] alongside it —
  /// are used directly. When it is absent (an old-shape document from
  /// before this rollout), the mode is derived from the legacy fields: a
  /// `booleanTracked: true` flag always wins (boolean mode); otherwise
  /// `measurementKind: unit` maps to count and `bulk` maps to mass.
  /// `IngredientDTO` carries no purchase presentation (that lives on
  /// `PantryItemDTO`), so this bridge cannot distinguish packageBase/
  /// packageAbstract from plain mass — that per-ingredient reclassification
  /// is the migration script's job; until it runs, a bulk ingredient reads
  /// as mass, which always loads without crashing.
  Ingredient toEntity({required String id}) {
    final mode = measurementMode != null
        ? MeasurementMode.values.byName(measurementMode!)
        : _deriveMode();
    final kind = measurementKind != null
        ? MeasurementKind.values.byName(measurementKind!)
        : (mode == MeasurementMode.count
              ? MeasurementKind.unit
              : MeasurementKind.bulk);
    final resolvedBooleanTracked =
        booleanTracked ?? (mode == MeasurementMode.boolean);

    return Ingredient(
      id: id,
      name: name,
      emoji: emoji,
      category: Category.values.byName(category),
      measurementKind: kind,
      booleanTracked: resolvedBooleanTracked,
      conversionFactor: conversionFactor,
      measurementMode: mode,
      package: package?.toEntity(),
      defaultLensLabel: defaultLensLabel,
    );
  }

  MeasurementMode _deriveMode() {
    if (booleanTracked == true) {
      return MeasurementMode.boolean;
    }
    final kind = measurementKind != null
        ? MeasurementKind.values.byName(measurementKind!)
        : MeasurementKind.bulk;
    return kind == MeasurementKind.unit
        ? MeasurementMode.count
        : MeasurementMode.mass;
  }
}
