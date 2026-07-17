import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:menuario/src/features/today/domain/entities/cook_schedule.dart';
import 'package:menuario/src/features/today/domain/value_objects/cook_target.dart';
import 'package:menuario/src/features/today/presentation/models/day_toggles.dart';
import 'package:reactive_forms/reactive_forms.dart';

/// The 3 per-day toggle names this form exposes, in render order.
const cookScheduleToggleNames = ['cenaHoy', 'damManana', 'damHoy'];

String _controlName(int weekday, String toggle) => '$weekday-$toggle';

/// Owns the batch-cook schedule editor's draft [FormGroup] — one
/// `FormControl<bool>` per (weekday, toggle) pair (21 total: 7 weekdays x
/// 3 toggles). Edits only touch this local draft until
/// `CookScheduleScreen` commits it via [toEntity] + the existing
/// `CookScheduleController.save`.
///
/// `dependencies: const []` — the controller reads/writes only its own
/// form state, no other provider.
final cookScheduleFormControllerProvider =
    NotifierProvider.autoDispose<CookScheduleFormController, FormGroup>(
      CookScheduleFormController.new,
      dependencies: const [],
    );

class CookScheduleFormController extends Notifier<FormGroup> {
  @override
  FormGroup build() {
    return FormGroup({
      for (
        var weekday = DateTime.monday;
        weekday <= DateTime.sunday;
        weekday++
      )
        for (final toggle in cookScheduleToggleNames)
          _controlName(weekday, toggle): FormControl<bool>(value: false),
    });
  }

  bool toggleValue(int weekday, String toggle) =>
      state.control(_controlName(weekday, toggle)).value as bool? ?? false;

  void setToggle(int weekday, String toggle, bool value) {
    state.control(_controlName(weekday, toggle)).value = value;
  }

  void _setDayToggles(int weekday, DayToggles toggles) {
    state.control(_controlName(weekday, 'cenaHoy')).value = toggles.cenaHoy;
    state.control(_controlName(weekday, 'damManana')).value =
        toggles.damManana;
    state.control(_controlName(weekday, 'damHoy')).value = toggles.damHoy;
  }

  /// Seeds every weekday's toggles from [schedule], once — mirrors the
  /// previous `_CookScheduleScreenState._togglesFrom` (edit-mode prefill
  /// guard lives in the screen, which calls this only the first time the
  /// schedule loads).
  void prefill(CookSchedule schedule) {
    for (
      var weekday = DateTime.monday;
      weekday <= DateTime.sunday;
      weekday++
    ) {
      _setDayToggles(
        weekday,
        fromTargets(weekday, schedule.targetsFor(weekday)),
      );
    }
  }

  /// Resets the local draft to [CookSchedule.seed] — NOT persisted until
  /// the screen calls `save`.
  void reset() {
    for (
      var weekday = DateTime.monday;
      weekday <= DateTime.sunday;
      weekday++
    ) {
      _setDayToggles(
        weekday,
        fromTargets(weekday, CookSchedule.seed.targetsFor(weekday)),
      );
    }
  }

  /// Builds the [CookSchedule] from the form's current toggle values.
  CookSchedule toEntity() {
    final byWeekday = <int, List<CookTarget>>{
      for (
        var weekday = DateTime.monday;
        weekday <= DateTime.sunday;
        weekday++
      )
        weekday: toTargets(weekday, (
          cenaHoy: toggleValue(weekday, 'cenaHoy'),
          damManana: toggleValue(weekday, 'damManana'),
          damHoy: toggleValue(weekday, 'damHoy'),
        )),
    };
    return CookSchedule(byWeekday: byWeekday);
  }
}
