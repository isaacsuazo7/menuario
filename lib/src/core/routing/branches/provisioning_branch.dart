import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';
import 'package:menuario/src/core/routing/app_routes.dart';
import 'package:menuario/src/features/provisioning/presentation/provisioning_screen.dart';

final _provisioningNavigatorKey = GlobalKey<NavigatorState>();

/// The "Abastecer" tab branch — hosts [ProvisioningScreen] on its own
/// nested navigator so its state survives switching to other tabs
/// (indexed-stack).
final provisioningBranch = StatefulShellBranch(
  navigatorKey: _provisioningNavigatorKey,
  routes: [
    GoRoute(
      path: ShellRoutes.provisioning,
      name: ShellRoutes.provisioning,
      builder: (context, state) => const ProvisioningScreen(),
    ),
  ],
);
