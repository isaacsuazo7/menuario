import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:menuario/src/features/shopping/presentation/providers/provisioning_tab_provider.dart';

void main() {
  group('provisioningTabProvider', () {
    test('defaults to despensa', () {
      // Arrange
      final container = ProviderContainer();
      addTearDown(container.dispose);

      // Act & Assert
      expect(container.read(provisioningTabProvider), ProvisioningTab.despensa);
    });

    test('switches to comprar when set', () {
      // Arrange
      final container = ProviderContainer();
      addTearDown(container.dispose);

      // Act
      container
          .read(provisioningTabProvider.notifier)
          .set(ProvisioningTab.comprar);

      // Assert
      expect(container.read(provisioningTabProvider), ProvisioningTab.comprar);
    });
  });
}
