import 'package:flutter/material.dart';

/// Single tunable seed color for the whole Menuario color scheme.
///
/// Both [MenuarioTheme.dark] and [MenuarioTheme.light] derive their
/// [ColorScheme] from this constant via [ColorScheme.fromSeed], so
/// re-coloring the entire app is a one-line change.
const menuarioSeed = Color(0xFF4F46E5);
