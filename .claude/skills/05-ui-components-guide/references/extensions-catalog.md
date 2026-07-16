# Extensions Catalog (menuario)

En menuario existe **UNA sola** extensión de UI relevante: `MenuarioTextStyleX`.

---

## MenuarioTextStyleX (la única extensión)

`extension MenuarioTextStyleX on TextStyle` (`lib/src/core/theme/typography.dart`).

Miembros:
- `.bold` — getter, devuelve el estilo con `FontWeight.bold`.
- `.withColor(Color)` — devuelve el estilo con el color aplicado.

```dart
Text('Fuerte', style: MenuarioTypography.body.bold)
Text('Color',  style: MenuarioTypography.h3.withColor(Theme.of(context).colorScheme.error))
Text('Ambos',  style: MenuarioTypography.h4.bold.withColor(scheme.primary))
```

> Se aplica sobre un `TextStyle` (`MenuarioTypography.*`), NO sobre un `Text`.
> NO hay `.semibold`, `.medium`, `.regular`, `.xs`, `.sm`, `.base`, `.lg`, `.center`,
> `.ellipsis`, ni `.withOpacity`.

## Estilos de tipografía (no son extensiones, son estáticos)

Recordatorio: los tamaños son `static const TextStyle` en `MenuarioTypography`, no
extensiones sobre `Text`:

```dart
Text('H1', style: MenuarioTypography.h1)   // 32 / w700
Text('H2', style: MenuarioTypography.h2)   // 28 / w700
Text('H3', style: MenuarioTypography.h3)   // 24 / w600
Text('H4', style: MenuarioTypography.h4)   // 20 / w600
Text('H5', style: MenuarioTypography.h5)   // 18 / w600
Text('H6', style: MenuarioTypography.h6)   // 16 / w600
Text('Body', style: MenuarioTypography.body) // 14 / w400
```

## Acceso a colores de dominio (theme extensions de ThemeData)

No son extensiones de Dart sobre tipos de UI, sino `ThemeExtension` registradas en el
tema. Se leen con `Theme.of(context).extension<...>()`:

```dart
final catColors = Theme.of(context).extension<MenuarioCategoryColors>()!;
final color = catColors.colorFor(category);            // + {fallback}

final covColors = Theme.of(context).extension<MenuarioCoverageColors>()!;
final color = covColors.colorFor(coverageStatus);      // cubierto/justo/falta/neutral
```

Definidas en `lib/src/core/theme/category_colors.dart` y `coverage_colors.dart`.

---

> Regla general: si dudas si una extensión existe en menuario, trátala como inexistente.
> Las únicas seguras son `MenuarioTextStyleX` (`.bold`, `.withColor`) y las theme
> extensions de color (`MenuarioCategoryColors`, `MenuarioCoverageColors`).
