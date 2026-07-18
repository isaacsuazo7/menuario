import 'package:flutter/material.dart';

/// The default seed color for the whole Menuario color scheme.
///
/// [MenuarioTheme.dark] and [MenuarioTheme.light] fall back to this seed
/// whenever no user preference has been resolved yet, so the app looks
/// exactly as it did before theming became configurable.
const menuarioSeed = Color(0xFF4F46E5);

/// A user-selectable seed: the [color] Material 3 derives the whole palette
/// from, plus the Spanish [label] shown in the Apariencia screen.
typedef MenuarioSeedOption = ({String label, Color color});

/// The closed, curated set of seeds the user may pick from.
///
/// Deliberately NOT a free color picker: `ColorScheme.fromSeed` accepts any
/// color and always yields a legible palette, but only a vetted set stays
/// visually coherent across both brightnesses and can be QA'd. [menuarioSeed]
/// leads the list and remains the default.
const menuarioSeedOptions = <MenuarioSeedOption>[
  (label: 'Índigo', color: menuarioSeed),
  (label: 'Esmeralda', color: Color(0xFF059669)),
  (label: 'Cian', color: Color(0xFF0891B2)),
  (label: 'Violeta', color: Color(0xFF7C3AED)),
  (label: 'Rosa', color: Color(0xFFDB2777)),
  (label: 'Ámbar', color: Color(0xFFD97706)),
  (label: 'Terracota', color: Color(0xFFC2410C)),
];

/// Resolves a curated seed from its persisted 32-bit ARGB [value], or `null`
/// when [value] is absent or not one of [menuarioSeedOptions].
///
/// Guards the closed-list invariant at the persistence boundary: a hand-edited
/// or schema-drifted document can carry any int, and anything uncurated must
/// degrade to the default rather than theme the app with an unvetted color.
Color? menuarioSeedFor(int? value) {
  if (value == null) return null;

  for (final option in menuarioSeedOptions) {
    if (option.color.toARGB32() == value) return option.color;
  }

  return null;
}
