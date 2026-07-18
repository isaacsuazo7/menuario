import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:menuario/src/core/auth/auth_providers.dart';
import 'package:menuario/src/core/error/failure.dart';
import 'package:menuario/src/core/error/failure_exception.dart';
import 'package:menuario/src/shared/data/repositories/theme_settings_repository_impl.dart';
import 'package:menuario/src/shared/domain/entities/theme_settings.dart';

/// Owns the account's [ThemeSettings] and their optimistic persistence.
///
/// An `AsyncNotifier` (not a plain `FutureProvider`) because [setMode] and
/// [setSeed] need MUTABLE state to repaint the app before Firestore
/// acknowledges the write — mirrors `CookScheduleController`.
final themeSettingsProvider =
    AsyncNotifierProvider<ThemeSettingsController, ThemeSettings>(
      ThemeSettingsController.new,
      dependencies: [themeSettingsRepositoryProvider, currentUidProvider],
      // Disables Riverpod's default automatic-retry-with-backoff so a load
      // failure surfaces as `AsyncError` immediately — see the matching
      // note on `cookScheduleProvider`.
      retry: (retryCount, error) => null,
    );

/// Loads the saved [ThemeSettings] — falling back to
/// [ThemeSettings.defaults] while signed out or when nothing has been saved
/// — and exposes optimistic [setMode]/[setSeed] mutations with functional
/// rollback on failure.
class ThemeSettingsController extends AsyncNotifier<ThemeSettings> {
  @override
  Future<ThemeSettings> build() async {
    // The settings document lives under `users/{uid}/`, so it is
    // unreachable while signed out. Resolving to the defaults here — rather
    // than letting the datasource answer `Failure.unauthenticated` — keeps
    // the sign-in screen themed instead of error-gated, and avoids
    // constructing the Firestore-backed repository at all.
    if (ref.watch(currentUidProvider) == null) {
      return ThemeSettings.defaults;
    }

    final repository = ref.watch(themeSettingsRepositoryProvider);
    final result = await repository.getActive();

    return result.fold(
      (failure) => throw FailureException(failure),
      (settings) => settings ?? ThemeSettings.defaults,
    );
  }

  /// Applies and persists [mode], keeping the current seed.
  Future<Failure?> setMode(ThemeMode mode) {
    final current = state.value ?? ThemeSettings.defaults;
    return _persist(current.copyWith(mode: mode));
  }

  /// Applies and persists [seed], keeping the current mode.
  ///
  /// [seed] is expected to come from `menuarioSeedOptions`: anything outside
  /// that curated list resolves back to the default on the next read.
  Future<Failure?> setSeed(Color seed) {
    final current = state.value ?? ThemeSettings.defaults;
    return _persist(current.copyWith(seed: seed));
  }

  /// Applies [settings] to [state] optimistically, then persists them. On
  /// failure, reverts to the pre-edit snapshot and returns the [Failure]; on
  /// success, returns `null`.
  Future<Failure?> _persist(ThemeSettings settings) async {
    final snapshot = state.value;
    state = AsyncData(settings);

    final repository = ref.read(themeSettingsRepositoryProvider);
    final result = await repository.save(settings);

    if (!ref.mounted) return null;

    return result.fold((failure) {
      // Only this mutation's own optimistic write may be rolled back. Two
      // rapid taps overlap their saves, and if the later one resolves first
      // an unconditional revert would discard an already-persisted value —
      // so a state that no longer holds `settings` means a newer mutation
      // superseded this one and now owns the state.
      if (snapshot != null && state.value == settings) {
        state = AsyncData(snapshot);
      }
      return failure;
    }, (_) => null);
  }
}
