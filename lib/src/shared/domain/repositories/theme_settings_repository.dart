import 'package:dartz/dartz.dart' hide Unit;
import 'package:menuario/src/core/error/failure.dart';
import 'package:menuario/src/shared/domain/entities/theme_settings.dart';

/// Persistence port for the account's [ThemeSettings].
///
/// Single-document semantics: at most one [ThemeSettings] is ever stored per
/// account. [getActive] returns it (or `Right(null)` when the user has never
/// customized their theme), and [save] always fully **overwrites** it — no
/// history, no merge.
abstract class ThemeSettingsRepository {
  /// Returns the saved [ThemeSettings], or `Right(null)` when the user has
  /// not customized their theme yet.
  Future<Either<Failure, ThemeSettings?>> getActive();

  /// Persists [settings], overwriting whatever was previously saved.
  Future<Either<Failure, void>> save(ThemeSettings settings);
}
