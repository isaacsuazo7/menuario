import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:menuario/src/shared/domain/value_objects/unit.dart';

part 'package_spec.freezed.dart';

/// How a packageBase/packageAbstract-mode ingredient is packaged.
///
/// [yieldQty] and [baseDimension] are populated for packageBase packages
/// (e.g. leche bolsa=1 L, huevo cartón=15 u) so the pack lens converts to
/// a real base-unit value. Both are null for packageAbstract packages,
/// which have no known base-unit yield (e.g. lechuga bolsa, requesón
/// pana) and store a decimal package count directly.
@freezed
abstract class PackageSpec with _$PackageSpec {
  const factory PackageSpec({
    required String label,
    num? yieldQty,
    Unit? baseDimension,
  }) = _PackageSpec;
}
