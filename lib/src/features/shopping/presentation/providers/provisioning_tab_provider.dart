import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Which body `ProvisioningScreen` currently renders.
enum ProvisioningTab {
  /// The existing pantry list, grouped by category.
  despensa,

  /// The derived shopping list.
  comprar,
}

/// Drives `ProvisioningScreen`'s `[Despensa | Comprar]` toggle.
class ProvisioningTabController extends Notifier<ProvisioningTab> {
  @override
  ProvisioningTab build() => ProvisioningTab.despensa;

  /// Switches the active [tab].
  void set(ProvisioningTab tab) => state = tab;
}

/// The provider for [ProvisioningTabController]. Defaults to
/// [ProvisioningTab.despensa] so the pantry list is what a user sees
/// first, matching current behavior.
final provisioningTabProvider =
    NotifierProvider<ProvisioningTabController, ProvisioningTab>(
      ProvisioningTabController.new,
    );
