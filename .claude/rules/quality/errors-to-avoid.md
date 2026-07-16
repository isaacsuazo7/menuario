---
paths:
  - "**/*.dart"
---

# Anti-patrones Prohibidos

Anti-patrones que NO están cubiertos en los pattern files. Para patrones de providers, forms, widgets y submissions, ver `rules/patterns/`.

## Imports Relativos

```dart
// PROHIBIDO
import '../../../core/core.dart';
import './widgets/my_widget.dart';

// CORRECTO
import 'package:menuario/src/core/core.dart';
import 'package:menuario/src/features/week/presentation/providers/plan_controller.dart';
```

No hay barrels por feature. Se importan rutas explícitas (`package:menuario/src/...`); los únicos barrels disponibles son `core/core.dart`, `core/theme/theme.dart`, `core/routing/routing.dart` y `shared/shared.dart`.

## Catch Genérico Sin Tipo

```dart
// PROHIBIDO
} catch (e) {
  print(e);
}

// CORRECTO
} on FailureException catch (e, stackTrace) {
  state = AsyncError(e, stackTrace);
} on Exception catch (e, stackTrace) {
  state = AsyncError(
    FailureException(Failure(message: e.toString())),
    stackTrace,
  );
}
```

## print() para Logging

```dart
// PROHIBIDO
print('Error: $error');

// CORRECTO
import 'dart:developer';
log('Error: $error');
```

## Container para Sizing

Usar `SizedBox` o las constantes de `MenuarioSpacing` (acceso cualificado).
El eje se nombra por su dirección: `gapH*` = horizontal (ancho), `gapV*` = vertical (alto).

```dart
// PROHIBIDO
Container(height: 16)
Container(width: 8, height: 8)

// CORRECTO
const SizedBox(height: 16)
MenuarioSpacing.gapV16   // separación vertical
MenuarioSpacing.gapH16   // separación horizontal
MenuarioSpacing.gapH8
```

Las constantes de `MenuarioSpacing` ya son `static const`, así que no requieren el prefijo `const` al usarlas.

## Guardar ref.read() en Variables

```dart
// PROHIBIDO — puede quedar stale
final notifier = ref.read(myProvider.notifier);
notifier.doSomething();

// CORRECTO
ref.read(myProvider.notifier).doSomething();
```

## Funciones que Retornan Widgets

```dart
// PROHIBIDO
Widget _buildHeader() {
  return Container(...);
}

// CORRECTO
class _Header extends StatelessWidget {
  const _Header();

  @override
  Widget build(BuildContext context) {
    return Container(...);
  }
}
```

## Cross-references

Para anti-patrones de providers (dependencies, Provider.family): ver `rules/patterns/providers.md`
Para anti-patrones de forms (side effects en build, listeners, ConsumerWidget): ver `rules/patterns/forms.md`
Para anti-patrones de widgets (.when() directo, spacing): ver `rules/patterns/widgets.md`
