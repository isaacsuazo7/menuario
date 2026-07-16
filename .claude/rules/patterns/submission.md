---
paths:
  - "**/providers/**/*submission*.dart"
  - "**/*_submission_provider.dart"
---

# Patrones de Submission Providers

## Propósito

Los submission providers manejan operaciones de mutación (crear, actualizar,
eliminar) con:
- Estado de carga y error mediante `AsyncValue<void>`
- Manejo correcto de `Failure` / `FailureException`
- Invalidación de listas/providers relacionados tras el éxito

## Ejemplo de Referencia

Referencia real:
`lib/src/features/auth/presentation/providers/sign_in_submission_provider.dart`

```dart
import 'package:menuario/src/core/core.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final signInSubmissionProvider =
    NotifierProvider.autoDispose<
      SignInSubmissionNotifier,
      AsyncValue<void>
    >(
      SignInSubmissionNotifier.new,
      dependencies: [
        authServiceProvider, // ✅ Servicio que ejecuta la operación
      ],
    );

class SignInSubmissionNotifier extends AutoDisposeNotifier<AsyncValue<void>> {
  @override
  AsyncValue<void> build() => const AsyncData(null);

  Future<void> signInWithGoogle() async {
    // 1. Estado de carga
    state = const AsyncLoading();

    try {
      // 2. Ejecutar operación contra el servicio/repositorio (Either<Failure, T>)
      final result = await ref.read(authServiceProvider).signInWithGoogle();

      // 3. Guard: verificar si el provider sigue montado tras el await
      if (!ref.mounted) return;

      // 4. Manejar resultado con fold
      result.fold(
        (failure) => throw FailureException(failure),
        (_) => state = const AsyncData(null),
      );
    } on FailureException catch (e, stackTrace) {
      // 5. Error de negocio (Failure ya envuelto)
      state = AsyncError(e, stackTrace);
    } on Exception catch (e, stackTrace) {
      // 6. Error inesperado → envolver en FailureException
      state = AsyncError(
        FailureException(Failure(message: e.toString())),
        stackTrace,
      );
    }
  }
}
```

## Estructura del Provider

### 1. Tipo de Provider
```dart
NotifierProvider.autoDispose<NotifierClass, AsyncValue<void>>
```

- `autoDispose`: Se limpia cuando no hay listeners
- `AsyncValue<void>`: Para operaciones sin retorno de datos

### 2. Dependencies
Declarar TODAS las dependencias (recuerda: menuario **no tiene UseCase**, se
depende directamente de los providers de repositorio o servicio):
- Repository/servicio que ejecuta la operación
- Providers de datos necesarios
- Providers a invalidar después del éxito

### 3. Estado Inicial
```dart
@override
AsyncValue<void> build() => const AsyncData(null);
```

### 4. Flujo de la Operación

```dart
Future<void> submit(Data data) async {
  state = const AsyncLoading();           // Loading

  try {
    final result = await ref.read(xxxRepositoryProvider).save(data);

    if (!ref.mounted) return;             // Guard después de await

    result.fold(
      (failure) => throw FailureException(failure),  // Error de negocio
      (_) {
        state = const AsyncData(null);               // Éxito
        ref.invalidate(relatedProvider);             // Refrescar datos
      },
    );
  } on FailureException catch (e, stackTrace) {
    state = AsyncError(e, stackTrace);               // Error conocido
  } on Exception catch (e, stackTrace) {
    state = AsyncError(                              // Error inesperado
      FailureException(Failure(message: e.toString())),
      stackTrace,
    );
  }
}
```

### 5. ref.mounted Guard

Después de cada `await`, verificar que el provider sigue montado antes de
modificar `state`:

```dart
final result = await ref.read(xxxRepositoryProvider).save(data);

// ✅ OBLIGATORIO después de cada await
if (!ref.mounted) return;

result.fold(...);
```

Esto previene errores cuando el usuario navega fuera del screen mientras la
operación está en curso.

## Uso en Screen

menuario **no tiene** `observeForDialogs` (no existe). El éxito/error de un
submission se observa vigilando el `AsyncValue` del provider en el screen, con
`ref.listen` para efectos puntuales (SnackBar/diálogo/navegación):

```dart
@override
Widget build(BuildContext context) {
  // Efecto puntual: reacciona a cambios de estado del submission
  ref.listen<AsyncValue<void>>(signInSubmissionProvider, (previous, next) {
    next.whenOrNull(
      error: (error, _) => ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text((error as FailureException).message)),
      ),
      data: (_) {
        if (previous is AsyncLoading) context.go(AppRoutes.home);
      },
    );
  });

  final submissionState = ref.watch(signInSubmissionProvider);

  return FilledButton(
    onPressed: submissionState.isLoading
        ? null
        : () => ref.read(signInSubmissionProvider.notifier).signInWithGoogle(),
    child: submissionState.isLoading
        ? const CircularProgressIndicator()
        : const Text('Entrar con Google'),
  );
}
```

## Checklist de Submission Providers

- [ ] `NotifierProvider.autoDispose<Notifier, AsyncValue<void>>`
- [ ] `extends AutoDisposeNotifier<AsyncValue<void>>`
- [ ] `build()` retorna `const AsyncData(null)`
- [ ] `AsyncValue<void>` como tipo de estado
- [ ] Dependencies declaradas (repository/servicio + providers a invalidar)
- [ ] `AsyncLoading` antes de la operación
- [ ] `if (!ref.mounted) return;` después de cada `await`
- [ ] `result.fold()` para manejar `Either<Failure, T>`
- [ ] `throw FailureException(failure)` para errores de negocio
- [ ] Catch separado: primero `on FailureException`, luego `on Exception`
- [ ] `ref.invalidate(...)` del provider relacionado después del éxito
- [ ] En el screen: `ref.listen(submissionProvider, ...)` (NO `observeForDialogs`)
