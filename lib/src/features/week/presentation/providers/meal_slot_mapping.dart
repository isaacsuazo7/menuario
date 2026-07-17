import 'package:menuario/src/shared/shared.dart';

/// Maps a daily [MealSlot] to the [MealType] a plannable [Recipe] must
/// carry to appear in that slot's recipe picker.
///
/// Every [MealSlot] value shares its name with a [MealType] value, so this
/// is a pure name lookup (order-independent). `MealType.aderezo` has no
/// [MealSlot] counterpart, so it can never be produced here — recipes
/// tagged `aderezo` are excluded from every slot's picker by construction.
MealType mealTypeForSlot(MealSlot slot) => MealType.values.byName(slot.name);
