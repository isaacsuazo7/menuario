import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:menuario/src/shared/data/models/package_spec_dto.dart';
import 'package:menuario/src/shared/domain/entities/ingredient.dart';
import 'package:menuario/src/shared/domain/value_objects/category.dart';
import 'package:menuario/src/shared/domain/value_objects/measurement_kind.dart';
import 'package:menuario/src/shared/domain/value_objects/measurement_mode.dart';
import 'package:menuario/src/shared/domain/value_objects/need_type.dart';

part 'ingredient_dto.freezed.dart';
part 'ingredient_dto.g.dart';

/// JSON representation of an [Ingredient].
///
/// [Ingredient.id] is never stored in the map: it is the Firestore
/// `doc.id` and is injected back via [IngredientDTOX.toEntity].
///
/// [measurementMode]/[package]/[defaultLensLabel] are the flexible-units
/// replacement for the legacy `measurementKind`/`booleanTracked` pair — the
/// [Ingredient] entity no longer carries those fields at all, so
/// [fromEntity] no longer writes them. They are kept here, nullable, ONLY
/// as a read-side fallback: an old-shape document written before this
/// rollout has them but no [measurementMode], and [IngredientDTOX.toEntity]
/// derives the mode from them when [measurementMode] is absent — see
/// [IngredientDTOX._deriveMode].
///
/// [needType] is nullable for the same reason: an old-shape document
/// written before the NeedType rollout has no such key, and
/// [IngredientDTOX.toEntity] defaults it to `NeedType.recipeDriven` —
/// today's behavior, unchanged for every ingredient that never opts into
/// `weeklyFixed`/`optional`.
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
    String? needType,
  }) = _IngredientDTO;

  const IngredientDTO._();

  factory IngredientDTO.fromJson(Map<String, dynamic> json) =>
      _$IngredientDTOFromJson(json);

  /// Builds an [IngredientDTO] from an [Ingredient] entity, dropping its id.
  ///
  /// Never writes `measurementKind`/`booleanTracked` — those are a
  /// read-only back-compat fallback for pre-rollout documents; every
  /// document this app version writes is fully described by
  /// [measurementMode] alone.
  static IngredientDTO fromEntity(Ingredient entity) {
    return IngredientDTO(
      name: entity.name,
      emoji: entity.emoji,
      category: entity.category.name,
      conversionFactor: entity.conversionFactor,
      measurementMode: entity.measurementMode.name,
      package: entity.package == null
          ? null
          : PackageSpecDTO.fromEntity(entity.package!),
      defaultLensLabel: entity.defaultLensLabel,
      needType: entity.needType.name,
    );
  }
}

/// Bidirectional mapper: [IngredientDTO] -> [Ingredient].
extension IngredientDTOX on IngredientDTO {
  /// Rebuilds the [Ingredient] entity carried by this DTO, injecting [id]
  /// (the Firestore `doc.id`) since it is not part of the stored map.
  ///
  /// When [measurementMode] is present (every document this app version
  /// writes), it is used directly. When it is absent (an old-shape
  /// document from before this rollout, which has no [measurementMode]
  /// key), the mode is derived from the legacy `measurementKind`/
  /// `booleanTracked` JSON keys via [_deriveMode]: a `booleanTracked: true`
  /// flag always wins (boolean mode); otherwise `measurementKind: unit`
  /// maps to count and `bulk` maps to mass. `IngredientDTO` carries no
  /// purchase presentation (that lives on `PantryItemDTO`), so this bridge
  /// cannot distinguish packageBase/packageAbstract from plain mass — that
  /// per-ingredient reclassification is the migration script's job; until
  /// it runs, a bulk ingredient reads as mass, which always loads without
  /// crashing.
  Ingredient toEntity({required String id}) {
    final mode = measurementMode != null
        ? MeasurementMode.values.byName(measurementMode!)
        : _deriveMode();

    return Ingredient(
      id: id,
      name: name,
      emoji: emoji,
      category: Category.values.byName(category),
      conversionFactor: conversionFactor,
      measurementMode: mode,
      package: package?.toEntity(),
      defaultLensLabel: defaultLensLabel,
      needType: needType != null
          ? NeedType.values.byName(needType!)
          : NeedType.recipeDriven,
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
