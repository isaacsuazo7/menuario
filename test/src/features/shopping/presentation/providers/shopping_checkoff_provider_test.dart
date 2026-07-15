import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:menuario/src/features/shopping/presentation/providers/shopping_checkoff_provider.dart';

void main() {
  group('shoppingCheckoffProvider', () {
    test('starts empty', () {
      // Arrange
      final container = ProviderContainer();
      addTearDown(container.dispose);

      // Act & Assert
      expect(container.read(shoppingCheckoffProvider), isEmpty);
    });

    test('toggle adds an ingredient id not yet checked', () {
      // Arrange
      final container = ProviderContainer();
      addTearDown(container.dispose);
      // Keep the autoDispose provider alive across the toggle call.
      final sub = container.listen(shoppingCheckoffProvider, (_, _) {});
      addTearDown(sub.close);

      // Act
      container.read(shoppingCheckoffProvider.notifier).toggle('ing-avena');

      // Assert
      expect(container.read(shoppingCheckoffProvider), {'ing-avena'});
    });

    test('toggle removes an already-checked ingredient id', () {
      // Arrange
      final container = ProviderContainer();
      addTearDown(container.dispose);
      final sub = container.listen(shoppingCheckoffProvider, (_, _) {});
      addTearDown(sub.close);
      container.read(shoppingCheckoffProvider.notifier).toggle('ing-avena');

      // Act
      container.read(shoppingCheckoffProvider.notifier).toggle('ing-avena');

      // Assert
      expect(container.read(shoppingCheckoffProvider), isEmpty);
    });

    test(
      'autoDispose resets ticked state once the last listener is removed',
      () async {
        // Arrange
        final container = ProviderContainer();
        addTearDown(container.dispose);
        final sub = container.listen(shoppingCheckoffProvider, (_, _) {});
        container.read(shoppingCheckoffProvider.notifier).toggle('ing-avena');
        expect(container.read(shoppingCheckoffProvider), {'ing-avena'});

        // Act — dropping the only listener disposes the autoDispose
        // provider; reading it again rebuilds fresh state.
        sub.close();
        await Future<void>.delayed(Duration.zero);

        // Assert
        expect(container.read(shoppingCheckoffProvider), isEmpty);
      },
    );
  });
}
