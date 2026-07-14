import 'package:flutter/widgets.dart';

/// The root navigator key. Routes that must cover the whole screen — over
/// the bottom-nav shell and drawer (e.g. detail screens) — declare
/// `parentNavigatorKey: rootNavigatorKey` so `go_router` pushes them on
/// this root navigator instead of a branch's nested navigator.
final rootNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'root');
