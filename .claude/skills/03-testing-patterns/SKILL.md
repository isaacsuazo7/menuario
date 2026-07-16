---
name: "Writing Comprehensive Tests"
description: "Trigger: writing tests, TDD, coverage, testing a layer in menuario. Unit/widget tests with flutter_test + mocktail + fake_cloud_firestore, ProviderContainer overrides, AsyncValue verification. Strict TDD."
license: Apache-2.0
metadata:
  author: gentleman-programming
  version: "1.0"
---

# Writing Comprehensive Tests

## Descripción

Skill de patrones y estrategias de testing para menuario. Cubre unit tests
(datasources, repositories, providers) y widget tests siguiendo la arquitectura
del proyecto. **TDD estricto está activo**: se escribe primero el test que falla
(RED), luego el mínimo código que lo hace pasar (GREEN), luego se refactoriza.

## Cuándo usar esta skill

- Al escribir tests para nuevo código (primero el test — TDD)
- Al mejorar cobertura de tests existentes
- Para entender cómo testear cada capa
- Durante el ciclo Red-Green-Refactor

## Dependencias de test (reales)

Ya presentes en `pubspec.yaml` (`dev_dependencies`):

- `flutter_test` (SDK)
- `mocktail` — mocks de puertos (repos, datasources, `FirebaseAuth`, `User`)
- `fake_cloud_firestore` — `FakeFirebaseFirestore` en memoria (sin mockear Firestore a mano)
- `mock_exceptions` — inyectar errores de Firestore (`whenCalling(...).thenThrow(...)`)

No se usa `dio` ni mocking HTTP: el borde de datos es Firestore, y se falsea con
`fake_cloud_firestore`.

## Estructura de Tests

El árbol de `test/` es **espejo de `lib/src/`** (nota: no hay `usecases/` porque
no existe esa capa; la mayor parte del `domain`/`data` vive en `shared/`):

```
test/
├── src/
│   ├── core/                     # espejo de lib/src/core/
│   │   ├── auth/
│   │   ├── error/
│   │   ├── firebase/
│   │   ├── routing/
│   │   └── theme/
│   ├── shared/                   # la mayor parte del domain/data
│   │   ├── data/
│   │   │   ├── datasources/
│   │   │   ├── models/           # tests de DTO (round-trip fromJson/toJson, fromEntity/toEntity)
│   │   │   └── repositories/
│   │   └── domain/
│   │       ├── services/         # CoverageCalculator, MeasurementConverter, ...
│   │       └── value_objects/
│   └── features/                 # slices verticales (p. ej. today/)
│       └── today/
│           └── presentation/
│               └── providers/
└── main_test.dart
```

## Tipos de Tests

### 1. Unit Tests - DataSources (fake_cloud_firestore)

Se instancia el datasource con un `FakeFirebaseFirestore` y un `uid` de prueba.
Se verifica round-trip, aislamiento por usuario y mapeo de errores a `Failure`.

```dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart' hide Unit;
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:menuario/src/core/error/failure.dart';
import 'package:menuario/src/shared/data/datasources/recipe_data_source.dart';
import 'package:menuario/src/shared/data/models/recipe_dto.dart';
import 'package:mock_exceptions/mock_exceptions.dart';

void main() {
  group('RecipeDataSourceImpl', () {
    late FakeFirebaseFirestore firestore;

    setUp(() {
      firestore = FakeFirebaseFirestore();
    });

    RecipeDataSourceImpl makeDataSource({String? uid = 'uid-A'}) {
      return RecipeDataSourceImpl(firestore: firestore, uid: uid);
    }

    test('a saved recipe round-trips back with the same fields', () async {
      // Arrange
      final dataSource = makeDataSource();
      const dto = RecipeDTO(name: 'Avena con leche', bomLines: []);

      // Act
      final saveResult = await dataSource.save('recipe-1', dto);
      final getResult = await dataSource.getById('recipe-1');

      // Assert
      expect(saveResult, const Right<Failure, void>(null));
      getResult.fold(
        (failure) => fail('expected Right, got Left($failure)'),
        (readDto) => expect(readDto, dto),
      );
    });

    test('save maps a FirebaseException to Left(Failure)', () async {
      // Arrange
      final dataSource = makeDataSource();
      final doc = firestore.collection('users/uid-A/recipes').doc('x');
      whenCalling(Invocation.method(#set, null)).on(doc).thenThrow(
            FirebaseException(plugin: 'firestore', code: 'permission-denied'),
          );

      // Act
      final result = await dataSource.save(
        'x',
        const RecipeDTO(name: 'x', bomLines: []),
      );

      // Assert
      result.fold(
        (failure) => expect(failure.code, 'permission-denied'),
        (_) => fail('expected Left, got Right'),
      );
    });

    test('save without uid returns Left(Failure.unauthenticated)', () async {
      // Arrange
      final dataSource = makeDataSource(uid: null);

      // Act
      final result = await dataSource.save(
        'recipe-x',
        const RecipeDTO(name: 'x', bomLines: []),
      );

      // Assert
      result.fold(
        (failure) => expect(failure.code, 'unauthenticated'),
        (_) => fail('expected Left, got Right'),
      );
    });
  });
}
```

### 2. Unit Tests - Repositories

El repositorio se prueba contra su datasource **real** apoyado en
`FakeFirebaseFirestore` (no se mockea el datasource): así se cubre el mapeo
DTO ⇄ Entity de punta a punta.

```dart
group('RecipeRepositoryImpl', () {
  late FakeFirebaseFirestore firestore;
  late RecipeDataSource dataSource;
  late RecipeRepositoryImpl repository;

  setUp(() {
    firestore = FakeFirebaseFirestore();
    dataSource = RecipeDataSourceImpl(firestore: firestore, uid: 'uid-A');
    repository = RecipeRepositoryImpl(dataSource: dataSource);
  });

  test('save then getById round-trips the Recipe entity', () async {
    // Arrange
    const recipe = Recipe(id: 'recipe-1', name: 'Avena', bomLines: []);

    // Act
    final saveResult = await repository.save(recipe);
    final getResult = await repository.getById('recipe-1');

    // Assert
    expect(saveResult, const Right<Failure, void>(null));
    getResult.fold(
      (failure) => fail('expected Right, got Left($failure)'),
      (readRecipe) => expect(readRecipe, recipe),
    );
  });

  test('getById returns Left(Failure) for malformed data', () async {
    // Arrange: guardamos un DTO con una unidad desconocida
    const dto = RecipeDTO(
      name: 'Receta corrupta',
      bomLines: [
        BomLineDTO(
          recipeId: 'recipe-1',
          ingredientId: 'ingredient-1',
          quantity: QuantityDTO(
            value: 1,
            unitSymbol: 'g',
            unitDimension: 'unknownDimension',
          ),
        ),
      ],
    );
    await dataSource.save('recipe-1', dto);

    // Act
    final result = await repository.getById('recipe-1');

    // Assert
    result.fold(
      (failure) => expect(failure.code, 'malformedData'),
      (_) => fail('expected Left, got Right'),
    );
  });
});
```

Cuando SÍ interesa aislar el repositorio de su datasource (p. ej. verificar
delegación), se mockea el puerto con mocktail:

```dart
class MockRecipeDataSource extends Mock implements RecipeDataSource {}
```

### 3. Unit Tests - Providers (ProviderContainer + overrides)

Se usa un `ProviderContainer` con overrides. Para probar la cadena DI se
sobreescriben los providers de borde — `firebaseFirestoreProvider`,
`currentUidProvider` — y/o los repository providers directamente.

```dart
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:menuario/src/core/auth/auth_providers.dart';
import 'package:menuario/src/core/firebase/firebase_providers.dart';

void main() {
  late FakeFirebaseFirestore firestore;

  setUp(() {
    firestore = FakeFirebaseFirestore();
  });

  ProviderContainer makeContainer() {
    final container = ProviderContainer(
      overrides: [
        firebaseFirestoreProvider.overrideWithValue(firestore),
        currentUidProvider.overrideWithValue('uid-A'),
      ],
    );
    addTearDown(container.dispose);
    return container;
  }

  test('recipeListProvider expone las recetas del usuario', () async {
    // Arrange
    final container = makeContainer();
    await firestore
        .collection('users/uid-A/recipes')
        .doc('recipe-1')
        .set({'name': 'Avena', 'bomLines': <Map<String, dynamic>>[]});

    // Act
    final recipes = await container.read(recipeListProvider.future);

    // Assert
    expect(recipes, hasLength(1));
  });
}
```

Para probar un provider aislándolo de la capa de datos, se sobreescribe
directamente el repository provider con un mock:

```dart
class MockRecipeRepository extends Mock implements RecipeRepository {}

final container = ProviderContainer(
  overrides: [
    recipeRepositoryProvider.overrideWithValue(mockRepository),
  ],
);
addTearDown(container.dispose);
```

> Regla clave: como **todo provider declara `dependencies`**, sus dependencias
> son sobreescribibles en tests. Esa es la razón de ser de `dependencies:` en
> menuario.

### 4. Verificación de estados AsyncValue

Los providers/submissions lanzan `FailureException` para que `AsyncValue`
capture el error. Se verifican las transiciones `loading → data/error`.

```dart
test('el submission pasa de loading a success', () async {
  // Arrange
  final container = makeContainer();
  final notifier = container.read(signInSubmissionProvider.notifier);

  // Estado inicial
  expect(container.read(signInSubmissionProvider), const AsyncData<void>(null));

  // Act
  final future = notifier.submit(/* ... */);
  expect(container.read(signInSubmissionProvider).isLoading, isTrue);
  await future;

  // Assert
  final state = container.read(signInSubmissionProvider);
  expect(state.hasValue, isTrue);
  expect(state.hasError, isFalse);
});

test('un fallo del repositorio deja el submission en AsyncError', () async {
  // Arrange
  when(() => mockRepository.save(any()))
      .thenAnswer((_) async => Left(Failure.firestore(code: 'unavailable')));
  final container = makeContainer();
  final notifier = container.read(submissionProvider.notifier);

  // Act
  await notifier.submit(/* ... */);

  // Assert
  final state = container.read(submissionProvider);
  expect(state.hasError, isTrue);
  expect(state.error, isA<FailureException>());
});
```

### 5. Widget Tests - Screens

Se monta la screen dentro de `UncontrolledProviderScope` con un
`ProviderContainer` de overrides. Se usan widgets Material crudos
(`FilledButton`, `TextField`, `AppAsyncValueWidget`) 

```dart
testWidgets('RecipeFormScreen muestra el formulario', (tester) async {
  final container = ProviderContainer(
    overrides: [
      firebaseFirestoreProvider.overrideWithValue(FakeFirebaseFirestore()),
      currentUidProvider.overrideWithValue('uid-A'),
    ],
  );
  addTearDown(container.dispose);

  await tester.pumpWidget(
    UncontrolledProviderScope(
      container: container,
      child: const MaterialApp(home: RecipeFormScreen()),
    ),
  );

  expect(find.byType(TextField), findsWidgets);
  expect(find.byType(FilledButton), findsOneWidget);
});
```

## Mocking con Mocktail

Se mockean **puertos** (repositorios, datasources, `FirebaseAuth`, `User`), no
clases concretas de infraestructura de Firestore (para eso está
`fake_cloud_firestore`).

```dart
import 'package:mocktail/mocktail.dart';

class MockRecipeRepository extends Mock implements RecipeRepository {}
class MockRecipeDataSource extends Mock implements RecipeDataSource {}

setUp(() {
  mockRepository = MockRecipeRepository();
  registerFallbackValue(
    const Recipe(id: '', name: '', bomLines: []),
  );
});

// Stub
when(() => mockRepository.save(any()))
    .thenAnswer((_) async => const Right<Failure, void>(null));

// Verify
verify(() => mockRepository.save(any())).called(1);
```

## Ciclo TDD

1. **RED** — escribe el test que describe el comportamiento; falla.
2. **GREEN** — implementa el mínimo para que pase.
3. **REFACTOR** — limpia sin cambiar comportamiento; los tests siguen verdes.

```bash
# Ejecutar toda la suite
fvm flutter test

# Un archivo
fvm flutter test test/src/shared/data/repositories/recipe_repository_impl_test.dart

# Un test por nombre
fvm flutter test --name "round-trips"
```

## Checklist de Testing

- [ ] DataSource: round-trip save/getById/list contra `FakeFirebaseFirestore`
- [ ] DataSource: mapeo de `FirebaseException` a `Failure` (con `mock_exceptions`)
- [ ] DataSource: caso `uid == null` → `Failure.unauthenticated`
- [ ] DataSource: aislamiento por usuario (datos de uid-A no visibles para uid-B)
- [ ] Repository: mapeo DTO ⇄ Entity y propagación de `Left(Failure)`
- [ ] Repository: `malformedData` en lugar de lanzar excepción
- [ ] DTO: round-trip `fromJson`/`toJson` y `fromEntity`/`toEntity`
- [ ] Domain Service: casos de negocio (sin usecases)
- [ ] Provider: `ProviderContainer` con overrides de `firebaseFirestoreProvider`/`currentUidProvider` o del repository
- [ ] Estados de `AsyncValue` (loading, data, error con `FailureException`)
- [ ] Widget test para screens principales (widgets Material crudos)
