import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:menuario/src/core/auth/auth_providers.dart';

/// Drawer for the authenticated shell.
///
/// Currently offers only sign-out: [AuthService.signOut] emits `null` on
/// the underlying auth stream, which `appRouterProvider`'s gate picks up
/// to redirect back to the sign-in screen.
class AppDrawer extends ConsumerWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Drawer(
      child: SafeArea(
        child: ListTile(
          leading: const Icon(Icons.logout),
          title: const Text('Cerrar sesión'),
          onTap: () {
            Navigator.of(context).pop();
            ref.read(authServiceProvider).signOut();
          },
        ),
      ),
    );
  }
}
