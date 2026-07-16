---
paths:
  - "**/providers/**/*.dart"
  - "**/*_provider.dart"
  - "**/*_providers.dart"
---

# Patrones de Providers (CRÍTICO)

## ⚠️ Regla Obligatoria: Dependencies

**TODOS los providers DEBEN declarar explícitamente sus `dependencies`.**

Motivo en menuario: **overridabilidad en tests**. Cada provider declara sus
dependencias para poder sobrescribirlas en un `ProviderContainer` (mockear
Firestore, la autenticación o los repositorios) sin arrastrar el árbol real.
Es un requisito real: 39 providers del proyecto lo declaran.

### Error Sin Dependencies

```dart
// ❌ INCORRECTO - Falla al sobrescribir en tests
final recipeRepositoryProvider = Provider<RecipeRepository>((ref) {
  return RecipeRepositoryImpl(dataSource: ref.watch(recipeDataSourceProvider));
});
// Error: "dependencies were overridden but the provider is not"
```

### Solución Con Dependencies

```dart
// ✅ CORRECTO - Overridable en ProviderContainer
final recipeRepositoryProvider = Provider<RecipeRepository>((ref) {
  return RecipeRepositoryImpl(dataSource: ref.watch(recipeDataSourceProvider));
}, dependencies: [recipeDataSourceProvider]);
```

## Tipos de Providers

| Tipo | Uso | autoDispose | Ejemplo |
|------|-----|-------------|---------|
| **Provider** | Dependencias (DataSources, Repositories) | ❌ | `recipeRepositoryProvider` |
| **NotifierProvider** | Estado mutable (submissions, controllers) | ✅ (según caso) | `signInSubmissionProvider`, `pantryControllerProvider` |
| **AsyncNotifierProvider** | Listas / estado async mutable | ❌ | `recipeListProvider` |
| **FutureProvider.family** | Detalles / edición por ID | ✅ | `recipeEditProvider` |

## Cadena de Dependencies (Firebase)

menuario **no tiene capa de UseCase**. El flujo es
`Widget → Provider → Repository → DataSource → Firestore`. Los providers de UI
dependen directamente del Repository (o de un servicio de dominio en
`shared/domain/services/` cuando aplica lógica de negocio).

```dart
// 1. Raíces transversales (core/firebase, core/auth)
//    firebaseFirestoreProvider  → expone FirebaseFirestore
//    currentUidProvider         → expone el UID autenticado

// 2. DataSource depende de Firestore + UID
final recipeDataSourceProvider = Provider<RecipeDataSource>((ref) {
  return RecipeDataSourceImpl(
    firestore: ref.watch(firebaseFirestoreProvider),
    uid: ref.watch(currentUidProvider),
  );
}, dependencies: [firebaseFirestoreProvider, currentUidProvider]);

// 3. Repository depende del DataSource
final recipeRepositoryProvider = Provider<RecipeRepository>((ref) {
  return RecipeRepositoryImpl(dataSource: ref.watch(recipeDataSourceProvider));
}, dependencies: [recipeDataSourceProvider]);

// 4. Provider de UI depende del Repository (SIN hop de UseCase)
final recipeEditProvider = FutureProvider.family<Recipe?, String?>((ref, id) async {
  final result = await ref.watch(recipeRepositoryProvider).findById(id);
  return result.fold(
    (failure) => throw FailureException(failure),
    (recipe) => recipe,
  );
}, dependencies: [recipeRepositoryProvider], retry: (count, error) => null);
```

La cadena de autenticación sigue el mismo estilo:

```dart
// authServiceProvider  deps [firebaseAuthProvider, googleSignInClientProvider]
//   → authStateProvider   deps [authServiceProvider]
//     → currentUidProvider  deps [authStateProvider]
```

Y la composición entre features también declara sus dependencias:

```dart
// todayMealsProvider deps [planControllerProvider, recipeListProvider, todayProvider]
// pantryControllerProvider deps [pantryRepositoryProvider, ingredientRepositoryProvider]
```

## Reglas de Dependencies

### 1. Siempre declarar
Si usas `ref.watch()` o `ref.read()`, declara dependencies:

```dart
// ✅ CORRECTO
final pantryControllerProvider = Provider<PantryController>((ref) {
  final pantry = ref.watch(pantryRepositoryProvider);
  final ingredients = ref.watch(ingredientRepositoryProvider);
  return PantryController(pantry, ingredients);
}, dependencies: [pantryRepositoryProvider, ingredientRepositoryProvider]);
```

### 2. Provider.family SIEMPRE con dependencies

```dart
// ✅ CORRECTO
final recipeEditProvider = FutureProvider.family<Recipe?, String?>(
  (ref, id) async {
    final result = await ref.watch(recipeRepositoryProvider).findById(id);
    return result.fold((f) => throw FailureException(f), (r) => r);
  },
  dependencies: [recipeRepositoryProvider],
);

// ❌ INCORRECTO - Falta dependencies
final recipeEditProvider = FutureProvider.family<Recipe?, String?>(
  (ref, id) async {
    final result = await ref.watch(recipeRepositoryProvider).findById(id);
    return result.fold((f) => throw FailureException(f), (r) => r);
  },
);
```

### 3. Provider sin ref → `dependencies: const []` explícito

```dart
// ✅ CORRECTO
final nowProvider = Provider<DateTime>(
  (ref) => DateTime.now(),
  dependencies: const [],
);

// ❌ INCORRECTO - Falta dependencies explícito
final nowProvider = Provider<DateTime>((ref) => DateTime.now());
```

### 4. Lista TODAS las dependencias directas

```dart
// ❌ INCORRECTO - Dependencies incompletas
final recipeDataSourceProvider = Provider<RecipeDataSource>((ref) {
  final db = ref.watch(firebaseFirestoreProvider);
  final uid = ref.watch(currentUidProvider);
  return RecipeDataSourceImpl(firestore: db, uid: uid);
}, dependencies: [firebaseFirestoreProvider]); // ❌ Falta currentUidProvider

// ✅ CORRECTO
}, dependencies: [firebaseFirestoreProvider, currentUidProvider]);
```

## Checklist de Dependencies

Antes de crear un provider, verifica:
- [ ] ¿Usa `ref.watch()` o `ref.read()`? → Agregar `dependencies: [providers]`
- [ ] ¿Es Provider.family? → SIEMPRE agregar dependencies
- [ ] ¿No usa ref? → Agregar `dependencies: const []` explícito
- [ ] ¿Tiene múltiples ref.watch? → Listar TODAS las dependencias
- [ ] ¿La cadena termina en un Repository (no en un UseCase)? → menuario no tiene capa de UseCase
