import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:menuario/src/shared/domain/value_objects/package_spec.dart';
import 'package:menuario/src/shared/domain/value_objects/unit.dart';

part 'package_spec_dto.freezed.dart';
part 'package_spec_dto.g.dart';

/// JSON representation of a [PackageSpec], nested inside [IngredientDTO]
/// for packageBase/packageAbstract-mode ingredients.
///
/// [baseDimensionSymbol]/[baseDimensionKind] together round-trip
/// [PackageSpec.baseDimension] (a full [Unit] value object, not just a
/// symbol string) without hardcoding a symbol->[Unit] lookup table; both
/// are null for packageAbstract packages, which carry no base dimension.
///
/// [innerLabel]/[innerQty]/[innerCount] round-trip [PackageSpec]'s
/// optional inner nesting level. All three are nullable and absent from
/// every document written before this rollout, so an existing Firestore
/// map simply deserializes them to null — no migration, no crash.
@freezed
abstract class PackageSpecDTO with _$PackageSpecDTO {
  const factory PackageSpecDTO({
    required String label,
    num? yieldQty,
    String? baseDimensionSymbol,
    String? baseDimensionKind,
    String? innerLabel,
    num? innerQty,
    num? innerCount,
  }) = _PackageSpecDTO;

  const PackageSpecDTO._();

  factory PackageSpecDTO.fromJson(Map<String, dynamic> json) =>
      _$PackageSpecDTOFromJson(json);

  /// Builds a [PackageSpecDTO] from a [PackageSpec] entity.
  static PackageSpecDTO fromEntity(PackageSpec entity) {
    return PackageSpecDTO(
      label: entity.label,
      yieldQty: entity.yieldQty,
      baseDimensionSymbol: entity.baseDimension?.symbol,
      baseDimensionKind: entity.baseDimension?.dimension.name,
      innerLabel: entity.innerLabel,
      innerQty: entity.innerQty,
      innerCount: entity.innerCount,
    );
  }
}

/// Bidirectional mapper: [PackageSpecDTO] -> [PackageSpec].
extension PackageSpecDTOX on PackageSpecDTO {
  /// Rebuilds the [PackageSpec] entity carried by this DTO.
  PackageSpec toEntity() {
    return PackageSpec(
      label: label,
      yieldQty: yieldQty,
      baseDimension: baseDimensionSymbol == null
          ? null
          : Unit(
              symbol: baseDimensionSymbol!,
              dimension: UnitDimension.values.byName(baseDimensionKind!),
            ),
      innerLabel: innerLabel,
      innerQty: innerQty,
      innerCount: innerCount,
    );
  }
}
