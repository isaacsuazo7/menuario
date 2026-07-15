import 'package:menuario/src/shared/shared.dart';

/// Maps a daily [MealSlot] to the [MealType] a plannable [Recipe] must
/// carry to appear in that slot's recipe picker.
///
/// The 4 [MealSlot] values and the first 4 [MealType] values share the same
/// names 1:1, so this is a pure name lookup. `MealType.aderezo` has no
/// [MealSlot] counterpart, so it can never be produced here — recipes
/// tagged `aderezo` are excluded from every slot's picker by construction.
MealType mealTypeForSlot(MealSlot slot) => MealType.values.byName(slot.name);
