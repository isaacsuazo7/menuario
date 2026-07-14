# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project state

`menuario` is a Flutter application at its initial scaffold stage. `lib/main.dart` is still the default counter demo, the only non-SDK dependency is `cupertino_icons`, and only the Android platform is configured. There is no custom architecture, state management, or feature code yet — treat this as a greenfield project where structure decisions are still open.

## Commands

- Install/refresh dependencies: `flutter pub get`
- Run the app (device/emulator must be attached): `flutter run`
- Static analysis / lint: `flutter analyze`
- Format: `dart format .`
- Run all tests: `flutter test`
- Run a single test file: `flutter test test/widget_test.dart`
- Run a single test by name: `flutter test test/widget_test.dart --name "<substring>"`
- Build a release APK: `flutter build apk`

Requires the Flutter SDK on a Dart `^3.12.2` toolchain (see `pubspec.yaml`).

## Conventions

- Linting is driven by `flutter_lints` via `analysis_options.yaml`. Add or disable rules there rather than sprinkling `// ignore:` across files.
- Only Android is set up. Adding iOS/web/desktop requires running `flutter create --platforms=<...> .` before platform code will exist.
