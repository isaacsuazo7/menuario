import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';
import 'package:menuario/src/core/routing/app_routes.dart';
import 'package:menuario/src/features/week/presentation/screens/week_screen.dart';

final _weekNavigatorKey = GlobalKey<NavigatorState>();

/// The "Semana" tab branch — hosts [WeekScreen] on its own nested
/// navigator so its state survives switching to other tabs
/// (indexed-stack).
final weekBranch = StatefulShellBranch(
  navigatorKey: _weekNavigatorKey,
  routes: [
    GoRoute(
      path: ShellRoutes.week,
      name: ShellRoutes.week,
      builder: (context, state) => const WeekScreen(),
    ),
  ],
);
