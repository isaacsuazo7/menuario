---
paths:
  - "**/error/**/*.dart"
  - "**/*_provider.dart"
---

# Sistema de Manejo de Errores

## Arquitectura de 2 Niveles

menuario usa un modelo de **2 niveles**. No existe `ErrorPresenter` ni
`ErrorType`: no los referencies.

```
Failure  ──►  FailureException  ──►  UI (message)
   ↓                ↓                    ↓
 dominio       providers          AppAsyncValueWidget
 (Either)      (throw)            lee .message
```

- **`Failure`**: error de dominio, viaja dentro de `Either<Failure, T>` (dartz).
- **`FailureException`**: envuelve un `Failure` y se lanza en los providers para
  que el `AsyncValue` lo capture.
- **UI**: `AppAsyncValueWidget` muestra `FailureException.message` en su vista de
  error interna.

## 1. Failure (`lib/src/core/error/failure.dart`)

Representa un error de negocio con información estructurada:

```dart
class Failure {
  final String message;                  // Mensaje principal
  final String? code;                    // Código de dominio (String, NO status HTTP)
  final Exception? exception;            // Excepción original
  final StackTrace? stackTrace;          // Stack trace
  final Map<String, dynamic>? metadata;  // Datos adicionales
}
```

⚠️ **No** existen getters como `errors` / `hasErrors` / `fullMessage` /
`userMessage`, ni factories genéricos `fromException` / `fromErrorResponse`. En
su lugar hay **factories con nombre de dominio**:

```dart
Failure.unknownUnit
Failure.missingConversionFactor
Failure.negativeStock
Failure.invalidDay
Failure.unitMismatch
Failure.mutateBom
Failure.authNoUser
Failure.authCancelled
Failure.firestore
Failure.unauthenticated
Failure.malformedData
```

## 2. FailureException (`lib/src/core/error/failure_exception.dart`)

Envuelve un `Failure` para usarlo con `AsyncValue`:

```dart
class FailureException implements Exception {
  final Failure failure;

  String get message;                 // proxy a failure.message
  String? get code;
  Map<String, dynamic>? get metadata;
  Object? get originalException;
  StackTrace? get stackTrace;
}
```

⚠️ **No** tiene métodos de clasificación (`isNetworkError()`, etc.). Solo expone
la información del `Failure` subyacente.

## Flujo Completo

### 1. DataSource / Repository → `Either<Failure, T>`

`dartz` se importa con `hide Unit` para no chocar con el dominio.

```dart
import 'package:dartz/dartz.dart' hide Unit;

Future<Either<Failure, Recipe>> getRecipe(String id) async {
  try {
    final snapshot = await _collection.doc(id).get();
    if (!snapshot.exists) return Left(Failure.malformedData);
    return Right(RecipeDTO.fromFirestore(snapshot).toEntity());
  } on FirebaseException catch (e, s) {
    return Left(Failure.firestore.copyWith(exception: e, stackTrace: s));
  }
}
```

### 2. Provider → `fold` + `throw FailureException`

```dart
// lib/src/features/.../presentation/providers/recipe_edit_provider.dart
final recipeEditProvider = FutureProvider.family<Recipe?, String?>(
  (ref, id) async {
    if (id == null) return null;
    final repository = ref.watch(recipeRepositoryProvider);
    final result = await repository.getRecipe(id);
    return result.fold(
      (failure) => throw FailureException(failure),
      (recipe) => recipe,
    );
  },
  dependencies: [recipeRepositoryProvider],
);
```

### 3. Widget → `AppAsyncValueWidget`

La UI de error es fija dentro de `AppAsyncValueWidget` (lee
`FailureException.message`). No hay parámetro `error:`:

```dart
AppAsyncValueWidget<Recipe?>(
  value: ref.watch(recipeEditProvider(id)),
  builder: (context, recipe) => RecipeForm(recipe: recipe),
  onRetry: () => ref.invalidate(recipeEditProvider(id)),
)
```

## Submission: patrón de dos catches

Los notifiers de envío capturan primero `FailureException` (ya tipada) y luego
cualquier otra `Exception`, envolviéndola en un `FailureException` genérico.
Referencia real: `lib/src/features/auth/presentation/providers/`
`sign_in_submission_provider.dart`.

```dart
Future<void> submit() async {
  state = const AsyncLoading();
  try {
    await _service.doWork();
    if (!ref.mounted) return;
    state = const AsyncData(null);
  } on FailureException catch (e, s) {
    if (!ref.mounted) return;
    state = AsyncError(e, s);
  } on Exception catch (e, s) {
    if (!ref.mounted) return;
    state = AsyncError(FailureException(Failure(message: e.toString())), s);
  }
}
```

### Mostrar éxito/error en la pantalla

**No existe `observeForDialogs`.** El éxito o error de un submission se observa
mirando el `AsyncValue` del submission en la pantalla, típicamente con
`ref.listen`:

```dart
ref.listen<AsyncValue<void>>(signInSubmissionProvider, (previous, next) {
  next.whenOrNull(
    data: (_) => context.go('/home'),
    error: (error, _) {
      final message =
          error is FailureException ? error.message : error.toString();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );
    },
  );
});
```

## Checklist de Error Handling

- [ ] DataSource / Repository retornan `Either<Failure, T>` (dartz `hide Unit`).
- [ ] Los `Failure` usan factories de dominio (`Failure.firestore`, etc.) cuando aplica.
- [ ] El provider usa `result.fold()` y `throw FailureException()`.
- [ ] Los submission notifiers usan dos catches (`on FailureException` / `on Exception`).
- [ ] La UI usa `AppAsyncValueWidget` (lee `FailureException.message`; sin `error:`).
- [ ] El éxito/error del submission se observa con `ref.listen`, no con un helper.
