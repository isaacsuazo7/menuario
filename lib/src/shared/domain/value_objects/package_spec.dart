import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:menuario/src/shared/domain/value_objects/spanish_plural.dart';
import 'package:menuario/src/shared/domain/value_objects/unit.dart';

part 'package_spec.freezed.dart';

/// How a packageBase/packageAbstract-mode ingredient is packaged.
///
/// [yieldQty] and [baseDimension] are populated for packageBase packages
/// (e.g. leche bolsa=1 L, huevo cartón=15 u) so the pack lens converts to
/// a real base-unit value. Both are null for packageAbstract packages,
/// which have no known base-unit yield (e.g. lechuga bolsa, requesón
/// pana) and store a decimal package count directly.
///
/// [innerLabel]/[innerQty]/[innerCount] describe the OPTIONAL second
/// nesting level: an outer pack ([label], e.g. `caja`) holding
/// [innerCount] inner packs ([innerLabel], e.g. `bolsa`) of [innerQty]
/// units each — salmas: 1 caja = 8 bolsas × 3 u. They exist so the total
/// units per outer pack is DERIVED ([effectiveYieldQty]) instead of
/// hand-multiplied into [yieldQty], which is where the numbers went wrong.
/// All three are null for a single-level package, which keeps every
/// document written before this rollout behaving exactly as before.
@freezed
abstract class PackageSpec with _$PackageSpec {
  const factory PackageSpec({
    required String label,
    num? yieldQty,
    Unit? baseDimension,
    String? innerLabel,
    num? innerQty,
    num? innerCount,
  }) = _PackageSpec;

  const PackageSpec._();

  /// The total units one OUTER pack yields: the inner level's product when
  /// it is fully described, else the stored single-level [yieldQty].
  ///
  /// Every consumer of "how much does one pack hold" must read this rather
  /// than [yieldQty] — purchases round up to whole outer packs, so a stale
  /// hand-computed [yieldQty] must never win over the described nesting.
  num? get effectiveYieldQty {
    final qty = innerQty;
    final count = innerCount;
    if (qty != null && count != null) return qty * count;
    return yieldQty;
  }

  /// The two-level breakdown (e.g. `'8 bolsas × 3 u'`), or `null` when this
  /// package has no inner level to explain.
  String? get innerBreakdown {
    final qty = innerQty;
    final count = innerCount;
    if (qty == null || count == null) return null;

    final label = innerLabel ?? 'paquete';
    final plural = pluralizeEs(label, count);
    return '${_trim(count)} $plural × ${_trim(qty)} u';
  }

  /// Renders a [num] without a trailing `.0` (counts are whole in practice).
  static String _trim(num value) =>
      value == value.roundToDouble() ? value.round().toString() : '$value';
}
