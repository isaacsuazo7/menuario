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

/// Resolves the name to greet, preferring [displayName] and falling back to
/// the email local-part when no display name is available.
///
/// - When [displayName] has a non-empty first word, it wins (see
///   [firstNameFrom]).
/// - Otherwise, when [email] is present, the local part (before `@`) is split
///   on `.`, `_`, and `+` — but NOT `-`, so `dev-claude` stays intact and
///   reads more like a name — and the first token is capitalized
///   (`isaac.suazo@x.com` → `Isaac`, `dev-claude@cit.hn` → `Dev-claude`).
/// - Otherwise returns an empty string, so the caller can show a bare
///   greeting.
String greetingNameFrom({String? displayName, String? email}) {
  final fromDisplayName = firstNameFrom(displayName);
  if (fromDisplayName.isNotEmpty) return fromDisplayName;
  return _nameFromEmail(email);
}

String _nameFromEmail(String? email) {
  final trimmed = email?.trim();
  if (trimmed == null || trimmed.isEmpty) return '';
  final localPart = trimmed.split('@').first;
  final token = localPart.split(RegExp(r'[._+]')).first;
  if (token.isEmpty) return '';
  return token[0].toUpperCase() + token.substring(1).toLowerCase();
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
