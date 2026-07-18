import 'package:flutter_test/flutter_test.dart';
import 'package:menuario/src/shared/domain/value_objects/purchase_quantity.dart';

void main() {
  group('PurchaseQuantity', () {
    group('loosePurchase', () {
      test('should carry the exact unit count', () {
        // Arrange & Act
        const purchase = PurchaseQuantity.loosePurchase(units: 6);

        // Assert
        expect(purchase, isA<PurchaseQuantity>());
        expect(purchase, const PurchaseQuantity.loosePurchase(units: 6));
      });

      test('display should render "N unidades"', () {
        // Arrange & Act
        const purchase = PurchaseQuantity.loosePurchase(units: 6);

        // Assert
        expect(purchase.display, '6 unidades');
      });

      test('display should render a single unit in singular', () {
        // Arrange & Act
        const purchase = PurchaseQuantity.loosePurchase(units: 1);

        // Assert
        expect(purchase.display, '1 unidad');
      });

      test('display should render three units in plural', () {
        // Arrange & Act
        const purchase = PurchaseQuantity.loosePurchase(units: 3);

        // Assert
        expect(purchase.display, '3 unidades');
      });

      test('display should render zero units in plural', () {
        // Arrange & Act
        const purchase = PurchaseQuantity.loosePurchase(units: 0);

        // Assert
        expect(purchase.display, '0 unidades');
      });

      test('should reject negative units', () {
        // Act & Assert
        expect(
          () => PurchaseQuantity.loosePurchase(units: -1),
          throwsA(isA<AssertionError>()),
        );
      });
    });

    group('packagePurchase', () {
      test('should carry packs and label', () {
        // Arrange & Act
        const purchase = PackagePurchase(packs: 2, label: 'bolsas');

        // Assert
        expect(purchase, isA<PurchaseQuantity>());
        expect(
          purchase,
          const PurchaseQuantity.packagePurchase(packs: 2, label: 'bolsas'),
        );
      });

      test('display should render "N label"', () {
        // Arrange & Act
        const purchase = PurchaseQuantity.packagePurchase(
          packs: 1,
          label: 'cartón (15 u)',
        );

        // Assert
        expect(purchase.display, '1 cartón (15 u)');
      });

      test('display should keep a single pack in singular', () {
        // Arrange & Act
        const purchase = PurchaseQuantity.packagePurchase(
          packs: 1,
          label: 'caja',
        );

        // Assert
        expect(purchase.display, '1 caja');
      });

      test('display should pluralize the label for several packs', () {
        // Arrange & Act
        const purchase = PurchaseQuantity.packagePurchase(
          packs: 3,
          label: 'bolsa',
        );

        // Assert
        expect(purchase.display, '3 bolsas');
      });

      test('display should pluralize only the head noun of a '
          'compound label', () {
        // Arrange & Act
        const purchase = PurchaseQuantity.packagePurchase(
          packs: 3,
          label: 'bolsa 1 L',
        );

        // Assert
        expect(purchase.display, '3 bolsas 1 L');
      });

      test('should reject negative packs', () {
        // Act & Assert
        expect(
          () => PurchaseQuantity.packagePurchase(packs: -1, label: 'bolsas'),
          throwsA(isA<AssertionError>()),
        );
      });
    });

    group('counterPurchase display (fraction rendering)', () {
      test('1 quarter should render as ¼ lb', () {
        expect(
          const PurchaseQuantity.counterPurchase(quarterPounds: 1).display,
          '¼ lb',
        );
      });

      test('2 quarters should render as ½ lb', () {
        expect(
          const PurchaseQuantity.counterPurchase(quarterPounds: 2).display,
          '½ lb',
        );
      });

      test('3 quarters should render as ¾ lb', () {
        expect(
          const PurchaseQuantity.counterPurchase(quarterPounds: 3).display,
          '¾ lb',
        );
      });

      test('4 quarters should render as a whole 1 lb', () {
        expect(
          const PurchaseQuantity.counterPurchase(quarterPounds: 4).display,
          '1 lb',
        );
      });

      test('11 quarters should render as 2 ¾ lb (pollo 1200 g scenario)', () {
        expect(
          const PurchaseQuantity.counterPurchase(quarterPounds: 11).display,
          '2 ¾ lb',
        );
      });

      test('8 quarters should render as a whole 2 lb', () {
        expect(
          const PurchaseQuantity.counterPurchase(quarterPounds: 8).display,
          '2 lb',
        );
      });

      test('0 quarters should render as 0 lb', () {
        expect(
          const PurchaseQuantity.counterPurchase(quarterPounds: 0).display,
          '0 lb',
        );
      });

      test('should reject negative quarterPounds', () {
        // Act & Assert
        expect(
          () => PurchaseQuantity.counterPurchase(quarterPounds: -1),
          throwsA(isA<AssertionError>()),
        );
      });
    });
  });
}
