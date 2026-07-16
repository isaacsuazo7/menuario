import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:menuario/src/core/theme/spacing.dart';
import 'package:menuario/src/features/today/domain/entities/cook_schedule.dart';
import 'package:menuario/src/features/today/domain/value_objects/cook_target.dart';
import 'package:menuario/src/features/today/presentation/models/day_toggles.dart';
import 'package:menuario/src/features/today/presentation/providers/cook_schedule_provider.dart';
import 'package:menuario/src/shared/shared.dart';

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
/// touch local state until "Guardar" commits the whole schedule in one
/// write via [CookScheduleController.save]. "Restablecer al valor por
/// defecto" resets the local draft to [CookSchedule.seed] — it is not
/// persisted until the user taps "Guardar".
class CookScheduleScreen extends ConsumerStatefulWidget {
  const CookScheduleScreen({super.key});

  @override
  ConsumerState<CookScheduleScreen> createState() => _CookScheduleScreenState();
}

class _CookScheduleScreenState extends ConsumerState<CookScheduleScreen> {
  Map<int, DayToggles>? _draft;
  bool _saving = false;

  Map<int, DayToggles> _togglesFrom(CookSchedule schedule) {
    return {
      for (var weekday = DateTime.monday; weekday <= DateTime.sunday; weekday++)
        weekday: fromTargets(weekday, schedule.targetsFor(weekday)),
    };
  }

  void _handleReset() {
    setState(() => _draft = _togglesFrom(CookSchedule.seed));
  }

  void _handleToggle(int weekday, DayToggles updated) {
    setState(() {
      final draft = _draft;
      if (draft == null) return;
      _draft = {...draft, weekday: updated};
    });
  }

  Future<void> _handleSave() async {
    final draft = _draft;
    if (draft == null) return;

    final byWeekday = <int, List<CookTarget>>{
      for (final entry in draft.entries)
        entry.key: toTargets(entry.key, entry.value),
    };
    final schedule = CookSchedule(byWeekday: byWeekday);

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

    return Scaffold(
      appBar: AppBar(title: const Text('Calendario de cocina')),
      body: AppAsyncValueWidget<CookSchedule>(
        value: scheduleValue,
        onRetry: () => ref.invalidate(cookScheduleProvider),
        builder: (context, schedule) {
          _draft ??= _togglesFrom(schedule);
          return _buildForm(context);
        },
      ),
    );
  }

  Widget _buildForm(BuildContext context) {
    final draft = _draft;
    if (draft == null) return const SizedBox.shrink();

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
            _DayTogglesTile(
              weekday: weekday,
              toggles: draft[weekday]!,
              onChanged: (updated) => _handleToggle(weekday, updated),
            ),
          MenuarioSpacing.gapV16,
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(
                key: const Key('cook-schedule-reset-button'),
                onPressed: _saving ? null : _handleReset,
                child: const Text('Restablecer al valor por defecto'),
              ),
              MenuarioSpacing.gapH8,
              FilledButton(
                key: const Key('cook-schedule-save-button'),
                onPressed: _saving ? null : _handleSave,
                child: const Text('Guardar'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// One weekday row: its label + the 3 [DayToggles] switches, each
/// disabled when its mapped target would be Domingo (never plannable).
class _DayTogglesTile extends StatelessWidget {
  const _DayTogglesTile({
    required this.weekday,
    required this.toggles,
    required this.onChanged,
  });

  final int weekday;
  final DayToggles toggles;
  final ValueChanged<DayToggles> onChanged;

  @override
  Widget build(BuildContext context) {
    // Mirrors DayToggles' own constraints: Sábado has no next eating day
    // (damManana would target Domingo), Domingo has no this-day (cenaHoy/
    // damHoy would target Domingo).
    final hoyEnabled = weekday != DateTime.sunday;
    final mananaEnabled = weekday != DateTime.saturday;

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
              value: toggles.cenaHoy,
              onChanged: hoyEnabled
                  ? (value) => onChanged((
                      cenaHoy: value,
                      damManana: toggles.damManana,
                      damHoy: toggles.damHoy,
                    ))
                  : null,
            ),
            SwitchListTile(
              key: Key('cook-schedule-toggle-$weekday-damManana'),
              contentPadding: EdgeInsets.zero,
              title: const Text('Des/Alm/Mer de mañana'),
              value: toggles.damManana,
              onChanged: mananaEnabled
                  ? (value) => onChanged((
                      cenaHoy: toggles.cenaHoy,
                      damManana: value,
                      damHoy: toggles.damHoy,
                    ))
                  : null,
            ),
            SwitchListTile(
              key: Key('cook-schedule-toggle-$weekday-damHoy'),
              contentPadding: EdgeInsets.zero,
              title: const Text('Des/Alm/Mer de hoy'),
              value: toggles.damHoy,
              onChanged: hoyEnabled
                  ? (value) => onChanged((
                      cenaHoy: toggles.cenaHoy,
                      damManana: toggles.damManana,
                      damHoy: value,
                    ))
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}
