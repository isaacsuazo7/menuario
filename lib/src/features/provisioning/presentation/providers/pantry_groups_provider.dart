import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:menuario/src/features/provisioning/presentation/models/pantry_row.dart';
import 'package:menuario/src/features/provisioning/presentation/providers/pantry_controller.dart';
import 'package:menuario/src/shared/shared.dart';

/// [pantryControllerProvider]'s flat row list, bucketed by [Category] in the
/// enum's fixed declaration order. Empty categories are omitted.
final pantryGroupsProvider = Provider<AsyncValue<List<PantryCategoryGroup>>>((
  ref,
) {
  final rowsValue = ref.watch(pantryControllerProvider);

  return rowsValue.whenData((rows) {
    return [
      for (final category in Category.values)
        if (rows.where((row) => row.item.category == category).toList()
            case final categoryRows when categoryRows.isNotEmpty)
          PantryCategoryGroup(category: category, rows: categoryRows),
    ];
  });
}, dependencies: [pantryControllerProvider]);
