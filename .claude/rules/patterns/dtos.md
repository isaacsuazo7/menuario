---
paths:
  - "**/data/models/**/*.dart"
  - "**/*_dto.dart"
---

# Patrones de DTOs

## Estructura Bidireccional

Cada DTO debe tener mappers en ambas direcciones:
- `fromEntity()`: Entity → DTO (para persistir en Firestore)
- `toEntity()`: DTO → Entity (para consumir desde Firestore)

Los DTOs usan **Freezed + json_serializable**. La serialización `toJson`/`fromJson`
se usa contra los documentos de Firestore (`cloud_firestore`), no contra una API HTTP.

## Ejemplo de Referencia

Referencia real: `lib/src/features/today/data/models/cook_schedule_dto.dart`.

```dart
import 'package:menuario/src/features/today/domain/entities/cook_schedule.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'cook_schedule_dto.freezed.dart';
part 'cook_schedule_dto.g.dart';

@freezed
abstract class CookScheduleDTO with _$CookScheduleDTO {
  const factory CookScheduleDTO({
    required String recipeId,
    required int day,
    required int servings,
    String? notes,
  }) = _CookScheduleDTO;

  // ✅ Constructor privado para extensions
  const CookScheduleDTO._();

  // ✅ Factory fromJson (generado)
  factory CookScheduleDTO.fromJson(Map<String, dynamic> json) =>
      _$CookScheduleDTOFromJson(json);

  // ✅ Entity → DTO (para persistir en Firestore)
  static CookScheduleDTO fromEntity(CookSchedule entity) {
    return CookScheduleDTO(
      recipeId: entity.recipeId,
      day: entity.day,
      servings: entity.servings,
      notes: entity.notes?.isEmpty == true ? null : entity.notes,
    );
  }
}

// ✅ Extension para mapper inverso
extension CookScheduleDTOX on CookScheduleDTO {
  // ✅ DTO → Entity (para consumir desde Firestore)
  CookSchedule toEntity() {
    return CookSchedule(
      recipeId: recipeId,
      day: day,
      servings: servings,
      notes: notes ?? '',
    );
  }
}
```

## Reglas de DTOs

### 1. Nomenclatura
- DTO: `EntityNameDTO` (ej: `CookScheduleDTO`)
- Extension: `EntityNameDTOX` (ej: `CookScheduleDTOX`)

### 2. Constructor privado
**Obligatorio** para poder usar extensions:

```dart
const CookScheduleDTO._();
```

### 3. fromEntity() como static method
Permite crear DTO desde Entity sin instancia:

```dart
final dto = CookScheduleDTO.fromEntity(cookSchedule);
```

### 4. toEntity() como extension method
Permite convertir DTO a Entity:

```dart
final entity = dto.toEntity();
```

### 5. Manejo de campos opcionales

```dart
// Normalizar strings vacíos
notes: entity.notes?.isEmpty == true ? null : entity.notes,

// Campos con valores por defecto al mapear de vuelta
notes: notes ?? '',
```

## Uso en DataSource

```dart
class CookScheduleDataSource {
  final FirebaseFirestore _firestore;
  final String _uid;

  CookScheduleDataSource(this._firestore, this._uid);

  // Persistir en Firestore (Entity → DTO)
  Future<Either<Failure, void>> save(CookSchedule schedule) async {
    final dto = CookScheduleDTO.fromEntity(schedule);
    try {
      await _firestore
          .collection('users/$_uid/cookSchedules')
          .doc(schedule.recipeId)
          .set(dto.toJson());
      return const Right(null);
    } on Exception catch (e, s) {
      return Left(Failure.firestore(exception: e, stackTrace: s));
    }
  }

  // Consumir desde Firestore (DTO → Entity)
  Future<Either<Failure, CookSchedule>> findById(String id) async {
    final snapshot =
        await _firestore.collection('users/$_uid/cookSchedules').doc(id).get();
    final data = snapshot.data();
    if (data == null) return Left(Failure.malformedData());
    return Right(CookScheduleDTO.fromJson(data).toEntity());
  }
}
```

## Checklist de DTOs

- [ ] DTO nombrado como `EntityNameDTO`
- [ ] Extension nombrada como `EntityNameDTOX`
- [ ] Constructor privado `const EntityNameDTO._()`
- [ ] `@freezed` + `part '*.freezed.dart'` + `part '*.g.dart'`
- [ ] `fromJson` factory (generado por json_serializable)
- [ ] `toJson` method (generado por json_serializable)
- [ ] `fromEntity()` static method para Entity → DTO
- [ ] `toEntity()` extension method para DTO → Entity
- [ ] Manejo de campos opcionales con valores por defecto
