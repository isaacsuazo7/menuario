import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:menuario/src/core/routing/widgets/app_drawer.dart';

class _ShellTab {
  const _ShellTab({
    required this.icon,
    required this.label,
    required this.title,
  });

  final IconData icon;

  /// The short bottom-bar label — it must survive four-across on a narrow
  /// phone without ellipsizing.
  final String label;

  /// The [AppBar] title. Kept identical to [label] so the header and the
  /// bottom bar always name the active tab the same way; the field stays
  /// separate so a tab can diverge if one ever needs to.
  final String title;
}

const _shellTabs = [
  _ShellTab(icon: Icons.today, label: 'Hoy', title: 'Hoy'),
  _ShellTab(icon: Icons.calendar_view_week, label: 'Semana', title: 'Semana'),
  _ShellTab(icon: Icons.shopping_cart_outlined, label: 'Stock', title: 'Stock'),
  _ShellTab(icon: Icons.menu_book, label: 'Recetas', title: 'Recetas'),
];

/// Hosts the four-tab [StatefulShellRoute.indexedStack] behind a Material
/// 3 [NavigationBar] and an [AppDrawer].
///
/// Declares its own [AppBar] (title + auto drawer icon) so the drawer is
/// reachable regardless of each tab's own nested [AppBar] — Flutter only
/// wires the automatic hamburger icon into the [AppBar] that belongs to
/// the same [Scaffold] as the `drawer`.
class AppShellScaffold extends StatelessWidget {
  const AppShellScaffold({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context) {
    final currentTab = _shellTabs[navigationShell.currentIndex];

    return Scaffold(
      appBar: AppBar(title: Text(currentTab.title)),
      drawer: const AppDrawer(),
      body: navigationShell,
      bottomNavigationBar: NavigationBar(
        selectedIndex: navigationShell.currentIndex,
        onDestinationSelected: (index) => navigationShell.goBranch(
          index,
          initialLocation: index == navigationShell.currentIndex,
        ),
        destinations: [
          for (final tab in _shellTabs)
            NavigationDestination(icon: Icon(tab.icon), label: tab.label),
        ],
      ),
    );
  }
}
