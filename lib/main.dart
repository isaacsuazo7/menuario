import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:menuario/firebase_options.dart';
import 'package:menuario/src/core/core.dart';
import 'package:menuario/src/features/settings/presentation/providers/theme_settings_provider.dart';
import 'package:menuario/src/shared/domain/entities/theme_settings.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await bootstrapFirebase(options: DefaultFirebaseOptions.currentPlatform);

  runApp(const ProviderScope(child: MenuarioApp()));
}

/// The root widget — deliberately separate from [main] so widget tests can
/// pump it directly (via `ProviderScope` overrides) without ever calling
/// `Firebase.initializeApp`.
class MenuarioApp extends ConsumerWidget {
  const MenuarioApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Falls back to the defaults while the settings load (and whenever the
    // load fails, or the user is signed out): the app must always have a
    // theme, so this never gates on `AsyncValue` — hence no
    // `AppAsyncValueWidget` here, which would have nothing to render into.
    final settings =
        ref.watch(themeSettingsProvider).value ?? ThemeSettings.defaults;

    return MaterialApp.router(
      title: 'Menuario',
      theme: MenuarioTheme.light(seed: settings.seed),
      darkTheme: MenuarioTheme.dark(seed: settings.seed),
      themeMode: settings.mode,
      routerConfig: ref.watch(appRouterProvider),
    );
  }
}
