/// Extracts the first word of [displayName] for the "Bienvenido {first}"
/// greeting.
///
/// Returns an empty string when [displayName] is `null`, empty, or
/// whitespace-only — the caller (`TodayHeader`) then falls back to a bare
/// greeting instead of surfacing a null/empty-name fragment.
String firstNameFrom(String? displayName) {
  final trimmed = displayName?.trim();
  if (trimmed == null || trimmed.isEmpty) return '';
  return trimmed.split(RegExp(r'\s+')).first;
}

const _spanishWeekdays = [
  'Lunes',
  'Martes',
  'Miércoles',
  'Jueves',
  'Viernes',
  'Sábado',
  'Domingo',
];

const _spanishMonths = [
  'enero',
  'febrero',
  'marzo',
  'abril',
  'mayo',
  'junio',
  'julio',
  'agosto',
  'septiembre',
  'octubre',
  'noviembre',
  'diciembre',
];

/// Formats [date] as a Spanish long date, e.g. "Martes 15 de julio".
///
/// Hand-rolled instead of `intl`'s `DateFormat` — `intl` is NOT a
/// `pubspec.yaml` dependency, and this app only ever needs this one format.
String spanishLongDate(DateTime date) {
  final weekday = _spanishWeekdays[date.weekday - 1];
  final month = _spanishMonths[date.month - 1];
  return '$weekday ${date.day} de $month';
}
