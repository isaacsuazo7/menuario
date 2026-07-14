import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:menuario/src/shared/domain/value_objects/presentation.dart';

part 'presentation_dto.freezed.dart';
part 'presentation_dto.g.dart';

/// JSON representation of a [Presentation], nested inside the aggregates
/// that carry one (e.g. `PantryItem`).
///
/// A single flat shape covers all three variants via an explicit [type]
/// discriminator (`loose` | `package` | `counter`); [yieldQty]/[label] are
/// only populated for `package`.
@freezed
abstract class PresentationDTO with _$PresentationDTO {
  const factory PresentationDTO({
    required String type,
    num? yieldQty,
    String? label,
  }) = _PresentationDTO;

  const PresentationDTO._();

  factory PresentationDTO.fromJson(Map<String, dynamic> json) =>
      _$PresentationDTOFromJson(json);

  /// Builds a [PresentationDTO] from a [Presentation] entity.
  static PresentationDTO fromEntity(Presentation entity) {
    return switch (entity) {
      PresentationLoose() => const PresentationDTO(type: 'loose'),
      PresentationPackage(:final yieldQty, :final label) => PresentationDTO(
        type: 'package',
        yieldQty: yieldQty,
        label: label,
      ),
      PresentationCounter() => const PresentationDTO(type: 'counter'),
    };
  }
}

/// Bidirectional mapper: [PresentationDTO] -> [Presentation].
extension PresentationDTOX on PresentationDTO {
  /// Rebuilds the [Presentation] entity carried by this DTO.
  Presentation toEntity() {
    return switch (type) {
      'loose' => const Presentation.loose(),
      'package' => Presentation.package(yieldQty: yieldQty!, label: label!),
      'counter' => const Presentation.counter(),
      _ => throw ArgumentError('Unknown Presentation type: "$type".'),
    };
  }
}
