import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Ciclo de vida del [PageController] que espeja un tab enum sobre un
/// [PageView], compartido por las pantallas con toggle + swipe.
///
/// La pantalla aporta [initialTabIndex] (leído del provider de tab al
/// montar) y llama a [syncPageToIndex] desde su `ref.listen`, que SIEMPRE
/// vive en el root de `build()` — nunca en `initState`/`listenManual`.
mixin TabPageSync<W extends ConsumerStatefulWidget> on ConsumerState<W> {
  late final PageController pageController;

  /// El índice del tab activo al montar la pantalla.
  int get initialTabIndex;

  @override
  void initState() {
    super.initState();
    pageController = PageController(initialPage: initialTabIndex);
  }

  @override
  void dispose() {
    pageController.dispose();
    super.dispose();
  }

  /// Anima el [PageView] hacia [index] salvo que ya esté ahí — el guard
  /// evita que el ciclo `onPageChanged -> provider -> ref.listen` pelee con
  /// un swipe que ya viene asentando en la misma página.
  void syncPageToIndex(int index) {
    if (!pageController.hasClients) return;
    if (pageController.page?.round() == index) return;
    pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeInOut,
    );
  }
}
