import 'package:flutter/material.dart';

/// A time-of-day greeting: the Spanish [label] plus the Material [icon] that
/// sits beside it.
///
/// The icon is a [IconData] (never an emoji) on purpose: an emoji is a
/// fixed-color glyph that fights the user-selected seed, while an icon is
/// tinted from the [ColorScheme] and follows the palette.
typedef Greeting = ({String label, IconData icon});

/// Resolves the greeting for [time]'s local hour.
///
/// Cutoffs: 05:00–11:59 morning, 12:00–18:59 afternoon, 19:00–04:59 night.
Greeting greetingFor(DateTime time) {
  final hour = time.hour;

  if (hour >= 5 && hour < 12) {
    return (label: 'Buenos días', icon: Icons.wb_sunny_outlined);
  }
  if (hour >= 12 && hour < 19) {
    return (label: 'Buenas tardes', icon: Icons.wb_twilight_outlined);
  }
  return (label: 'Buenas noches', icon: Icons.dark_mode_outlined);
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
