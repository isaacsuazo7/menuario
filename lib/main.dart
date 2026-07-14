import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:menuario/firebase_options.dart';
import 'package:menuario/src/core/core.dart';

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
    return MaterialApp.router(
      title: 'Menuario',
      theme: MenuarioTheme.light,
      darkTheme: MenuarioTheme.dark,
      themeMode: ThemeMode.dark,
      routerConfig: ref.watch(appRouterProvider),
    );
  }
}
