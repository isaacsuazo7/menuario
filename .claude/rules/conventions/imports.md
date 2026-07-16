---
paths:
  - "**/*.dart"
---

# Convenciones de Imports

## Regla Principal

**SIEMPRE usar package imports, NUNCA imports relativos**

```dart
// ✅ CORRECTO - Package import
import 'package:menuario/src/core/core.dart';
import 'package:menuario/src/shared/shared.dart';
import 'package:menuario/src/features/week/presentation/providers/plan_controller.dart';

// ❌ INCORRECTO - Import relativo
import '../../../core/core.dart';
import '../../domain/entities/recipe.dart';
import './widgets/my_widget.dart';
```

Los imports de ruta explícita y granular son normales y aceptados; no todo pasa
por un barrel.

## Orden de Imports

1. **Dart SDK** (`dart:`)
2. **Flutter** (`package:flutter/`)
3. **Paquetes externos** (alfabético)
4. **Paquete del proyecto** (`package:menuario/`)

```dart
// 1. Dart SDK
import 'dart:async';
import 'dart:developer';

// 2. Flutter
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// 3. Paquetes externos (alfabético)
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart' hide Unit;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

// 4. Paquete del proyecto
import 'package:menuario/src/core/core.dart';
import 'package:menuario/src/shared/shared.dart';
import 'package:menuario/src/features/today/presentation/providers/today_meals_provider.dart';
```

Dependencias externas presentes actualmente: `dartz`, `flutter_riverpod`,
`go_router`, `cloud_firestore`, `firebase_auth`, `freezed_annotation`,
`json_annotation`. (`reactive_forms` se incorporará como estándar de forms;
aún no está en pubspec. No se usa `dio`.)

## Barrel Files

Solo existen barrels transversales en `core/` y `shared/`. Úsalos para importar
grupos de utilidades transversales:

```dart
// Barrels que EXISTEN
import 'package:menuario/src/core/core.dart';        // auth, error, firebase, routing, theme
import 'package:menuario/src/core/theme/theme.dart';
import 'package:menuario/src/core/routing/routing.dart';
import 'package:menuario/src/shared/shared.dart';     // shared domain/data + AppAsyncValueWidget
```

## Sin Barrels por Feature

**NO existen barrels por feature.** No hay `today.dart`, `recipes.dart`, ni
equivalentes. Para símbolos de una feature, importa la ruta explícita del archivo:

```dart
// ✅ CORRECTO - ruta explícita al archivo del feature
import 'package:menuario/src/core/theme/spacing.dart';
import 'package:menuario/src/features/week/presentation/providers/plan_controller.dart';

// ❌ INCORRECTO - barrel de feature inexistente
import 'package:menuario/src/features/week/week.dart';
```

## Show/Hide

Usar `show` o `hide` cuando sea necesario evitar conflictos. En particular,
`dartz` se importa `hide Unit` en todo el proyecto:

```dart
import 'package:dartz/dartz.dart' hide Unit;
import 'package:go_router/go_router.dart' show GoRouter;
```

## Imports Condicionales

Para código específico de plataforma:

```dart
import 'stub_implementation.dart'
    if (dart.library.io) 'io_implementation.dart'
    if (dart.library.html) 'web_implementation.dart';
```

## Part/Part Of

Usar solo para archivos generados (Freezed, json_serializable):

```dart
// cook_schedule_dto.dart
part 'cook_schedule_dto.freezed.dart';
part 'cook_schedule_dto.g.dart';
```

**NUNCA** usar `part`/`part of` para dividir código manualmente.
