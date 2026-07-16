import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Which body `TodayScreen` currently renders.
enum TodayTab {
  /// The batch-cook schedule ("Cocinar").
  cocinar,

  /// Today's planned meals ("Comer").
  comer,
}

/// Drives `TodayScreen`'s `[Cocinar | Comer]` toggle.
class TodayTabController extends Notifier<TodayTab> {
  @override
  TodayTab build() => TodayTab.cocinar;

  /// Switches the active [tab].
  void set(TodayTab tab) => state = tab;
}

/// The provider for [TodayTabController]. Defaults to [TodayTab.cocinar] so
/// the batch-cook routine is what a user sees first.
final todayTabProvider = NotifierProvider<TodayTabController, TodayTab>(
  TodayTabController.new,
);
