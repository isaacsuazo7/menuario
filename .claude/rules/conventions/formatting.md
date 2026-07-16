---
paths:
  - "**/*.dart"
---

# Formato de Código

## Reglas Básicas

### Longitud de Línea
- **Máximo 80 caracteres por línea**
- Si es inevitable, usar `// ignore_for_file: lines_longer_than_80_chars` al inicio

### Trailing Commas
**Obligatorias** en todos los argumentos multi-línea:

```dart
// ✅ CORRECTO
FilledButton(
  onPressed: _submit,
  child: const Text('Enviar'),
);

// ❌ INCORRECTO
FilledButton(
  onPressed: _submit,
  child: const Text('Enviar')
);
```

### Constructores Const
Usar `const` siempre que sea posible:

```dart
// ✅ CORRECTO
const gapH16 = SizedBox(height: 16);
const MyWidget({super.key});

// ❌ INCORRECTO
final gapH16 = SizedBox(height: 16);
MyWidget({super.key});
```

## Documentación

### Idioma
- **Comentarios en español**
- Código (nombres de variables, clases) en **inglés**

### Extensión
- **Máximo 1 línea** de documentación
- Solo cuando sea **sumamente necesario**
- Nombres autodescriptivos > comentarios

```dart
// ✅ CORRECTO - Nombre autodescriptivo, sin comentario
Future<List<CookSchedule>> getActiveCookSchedules();

// ❌ INCORRECTO - Comentario innecesario
/// Obtiene los cronogramas de cocina activos
Future<List<CookSchedule>> getSchedules();
```

### Cuándo Documentar
- Lógica de negocio no evidente
- Decisiones arquitectónicas importantes
- Workarounds temporales (con TODO)

## Espaciado

### Imports
Separar por grupos con línea en blanco:

```dart
// Dart/Flutter
import 'dart:async';
import 'package:flutter/material.dart';

// Paquetes externos
import 'package:dartz/dartz.dart' hide Unit;
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Paquetes del proyecto
import 'package:menuario/src/core/core.dart';
import 'package:menuario/src/shared/shared.dart';
```

### Clases
Una línea en blanco entre métodos:

```dart
class MyClass {
  final String name;

  MyClass(this.name);

  void methodA() {
    // ...
  }

  void methodB() {
    // ...
  }
}
```

## Error Handling

### Catch con Tipo
**Siempre** especificar el tipo de excepción:

```dart
// ✅ CORRECTO
} on FailureException catch (e, stackTrace) {
  state = AsyncError(e, stackTrace);
} on Exception catch (e, stackTrace) {
  state = AsyncError(FailureException(Failure(message: e.toString())), stackTrace);
}

// ❌ INCORRECTO
} catch (e) {
  // Catch genérico sin tipo
}
```

## Logging

Usar `log()` de `dart:developer`, nunca `print()`:

```dart
// ✅ CORRECTO
import 'dart:developer';
log('Error loading data: $error');

// ❌ INCORRECTO
print('Error loading data: $error');
```
