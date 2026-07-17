import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:menuario/src/core/theme/spacing.dart';
import 'package:menuario/src/features/today/domain/entities/cook_schedule.dart';
import 'package:menuario/src/features/today/presentation/providers/cook_schedule_form_controller.dart';
import 'package:menuario/src/features/today/presentation/providers/cook_schedule_provider.dart';
import 'package:menuario/src/shared/shared.dart';
import 'package:reactive_forms/reactive_forms.dart';

/// Spanish day names, indexed by `DateTime.weekday` (1..7).
const _dayLabels = {
  DateTime.monday: 'Lunes',
  DateTime.tuesday: 'Martes',
  DateTime.wednesday: 'Miércoles',
  DateTime.thursday: 'Jueves',
  DateTime.friday: 'Viernes',
  DateTime.saturday: 'Sábado',
  DateTime.sunday: 'Domingo',
};

/// Full-screen editor for the account's batch-cook schedule: one row per
/// source weekday (Lun-Dom), each offering up to 3 toggles ("Cena de
/// hoy", "D/A/M de mañana", "D/A/M de hoy"). Disables any toggle whose
/// mapping would target Domingo (never a valid `targetDay`).
///
/// Draft+single-Save idiom (mirrors `IngredientFormScreen`): edits only
/// touch the [cookScheduleFormControllerProvider] draft until "Guardar"
/// commits the whole schedule in one write via
/// [CookScheduleController.save]. "Restablecer al valor por defecto"
/// resets the local draft to [CookSchedule.seed] — it is not persisted
/// until the user taps "Guardar". `_saving` stays local `setState`
/// (rather than a submission provider's `AsyncValue`): unlike the
/// catalog/recipe CRUD screens, this editor is bound 1:1 to
/// [cookScheduleProvider]'s own `save`, which already returns a
/// `Future<Failure?>` directly — there is no separate submission
/// provider to `ref.listen` here.
class CookScheduleScreen extends ConsumerStatefulWidget {
  const CookScheduleScreen({super.key});

  @override
  ConsumerState<CookScheduleScreen> createState() =>
      _CookScheduleScreenState();
}

class _CookScheduleScreenState extends ConsumerState<CookScheduleScreen> {
  bool _prefilled = false;
  bool _saving = false;

  void _handleReset() {
    ref.read(cookScheduleFormControllerProvider.notifier).reset();
  }

  Future<void> _handleSave() async {
    final schedule = ref
        .read(cookScheduleFormControllerProvider.notifier)
        .toEntity();

    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);

    setState(() => _saving = true);
    final failure = await ref
        .read(cookScheduleProvider.notifier)
        .save(schedule);
    if (!mounted) return;
    setState(() => _saving = false);

    if (failure != null) {
      messenger.showSnackBar(SnackBar(content: Text(failure.message)));
    } else {
      navigator.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final scheduleValue = ref.watch(cookScheduleProvider);
    final form = ref.watch(cookScheduleFormControllerProvider);

    // Seed the draft once, when the active schedule is available. Works
    // whether the value is already cached (immediate) or arrives async
    // (build re-runs on the Loading -> Data transition). Deferred via
    // addPostFrameCallback so we never mutate the FormGroup that
    // ReactiveForm is watching mid-build.
    scheduleValue.whenData((schedule) {
      if (_prefilled) return;
      _prefilled = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        ref.read(cookScheduleFormControllerProvider.notifier).prefill(schedule);
      });
    });

    return ReactiveForm(
      formGroup: form,
      child: Scaffold(
        appBar: AppBar(title: const Text('Calendario de cocina')),
        body: AppAsyncValueWidget<CookSchedule>(
          value: scheduleValue,
          onRetry: () => ref.invalidate(cookScheduleProvider),
          builder: (context, _) => _CookScheduleFormBody(
            saving: _saving,
            onReset: _handleReset,
            onSave: _handleSave,
          ),
        ),
      ),
    );
  }
}

/// The form's scrollable body — rebuilds on any [FormGroup] control change
/// via [ReactiveFormConsumer].
class _CookScheduleFormBody extends StatelessWidget {
  const _CookScheduleFormBody({
    required this.saving,
    required this.onReset,
    required this.onSave,
  });

  final bool saving;
  final VoidCallback onReset;
  final Future<void> Function() onSave;

  @override
  Widget build(BuildContext context) {
    return ReactiveFormConsumer(
      builder: (context, form, child) {
        return SingleChildScrollView(
          padding: MenuarioSpacing.paddingAll16,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              for (
                var weekday = DateTime.monday;
                weekday <= DateTime.sunday;
                weekday++
              )
                _DayTogglesTile(weekday: weekday, form: form),
              MenuarioSpacing.gapV16,
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    key: const Key('cook-schedule-reset-button'),
                    onPressed: saving ? null : onReset,
                    child: const Text('Restablecer al valor por defecto'),
                  ),
                  MenuarioSpacing.gapH8,
                  FilledButton(
                    key: const Key('cook-schedule-save-button'),
                    onPressed: saving ? null : () => onSave(),
                    child: const Text('Guardar'),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}

/// One weekday row: its label + the 3 toggle switches, each disabled when
/// its mapped target would be Domingo (never plannable).
class _DayTogglesTile extends ConsumerWidget {
  const _DayTogglesTile({required this.weekday, required this.form});

  final int weekday;
  final FormGroup form;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Mirrors DayToggles' own constraints: Sábado has no next eating day
    // (damManana would target Domingo), Domingo has no this-day (cenaHoy/
    // damHoy would target Domingo).
    final hoyEnabled = weekday != DateTime.sunday;
    final mananaEnabled = weekday != DateTime.saturday;
    final notifier = ref.read(cookScheduleFormControllerProvider.notifier);

    bool valueOf(String toggle) =>
        form.control('$weekday-$toggle').value as bool? ?? false;

    return Card(
      child: Padding(
        padding: MenuarioSpacing.paddingAll16,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _dayLabels[weekday]!,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            SwitchListTile(
              key: Key('cook-schedule-toggle-$weekday-cenaHoy'),
              contentPadding: EdgeInsets.zero,
              title: const Text('Cena de hoy'),
              value: valueOf('cenaHoy'),
              onChanged: hoyEnabled
                  ? (value) => notifier.setToggle(weekday, 'cenaHoy', value)
                  : null,
            ),
            SwitchListTile(
              key: Key('cook-schedule-toggle-$weekday-damManana'),
              contentPadding: EdgeInsets.zero,
              title: const Text('Des/Alm/Mer de mañana'),
              value: valueOf('damManana'),
              onChanged: mananaEnabled
                  ? (value) => notifier.setToggle(weekday, 'damManana', value)
                  : null,
            ),
            SwitchListTile(
              key: Key('cook-schedule-toggle-$weekday-damHoy'),
              contentPadding: EdgeInsets.zero,
              title: const Text('Des/Alm/Mer de hoy'),
              value: valueOf('damHoy'),
              onChanged: hoyEnabled
                  ? (value) => notifier.setToggle(weekday, 'damHoy', value)
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}
