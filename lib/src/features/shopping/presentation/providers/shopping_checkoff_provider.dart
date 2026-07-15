import 'package:flutter_riverpod/flutter_riverpod.dart';

/// The Comprar view's ephemeral, session-only tick state: ingredient ids
/// the user has crossed off while shopping, never persisted.
///
/// `autoDispose` (not kept alive) by design: leaving Comprar — toggling to
/// Despensa or navigating away — drops the last listener, disposing this
/// provider so ticks reset and the next visit starts fresh, per the
/// Ephemeral Check-off requirement.
class ShoppingCheckoff extends Notifier<Set<String>> {
  @override
  Set<String> build() => const <String>{};

  /// Adds [ingredientId] to the ticked set, or removes it if already
  /// ticked.
  void toggle(String ingredientId) {
    state = state.contains(ingredientId)
        ? {
            for (final id in state)
              if (id != ingredientId) id,
          }
        : {...state, ingredientId};
  }
}

/// The provider for [ShoppingCheckoff], shared by every Comprar row and
/// any header/summary widget that needs the current tick count.
final shoppingCheckoffProvider =
    NotifierProvider.autoDispose<ShoppingCheckoff, Set<String>>(
      ShoppingCheckoff.new,
    );
