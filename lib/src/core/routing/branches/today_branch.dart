import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';
import 'package:menuario/src/core/routing/app_routes.dart';
import 'package:menuario/src/features/today/presentation/today_screen.dart';

final _todayNavigatorKey = GlobalKey<NavigatorState>();

/// The "Hoy" tab branch — hosts [TodayScreen] on its own nested navigator
/// so its state survives switching to other tabs (indexed-stack).
final todayBranch = StatefulShellBranch(
  navigatorKey: _todayNavigatorKey,
  routes: [
    GoRoute(
      path: ShellRoutes.today,
      name: ShellRoutes.today,
      builder: (context, state) => const TodayScreen(),
    ),
  ],
);
