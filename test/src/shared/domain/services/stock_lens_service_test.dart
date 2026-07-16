import 'package:flutter_test/flutter_test.dart';
import 'package:menuario/src/shared/domain/entities/ingredient.dart';
import 'package:menuario/src/shared/domain/services/stock_lens_service.dart';
import 'package:menuario/src/shared/domain/value_objects/category.dart';
import 'package:menuario/src/shared/domain/value_objects/mass.dart';
import 'package:menuario/src/shared/domain/value_objects/measurement_kind.dart';
import 'package:menuario/src/shared/domain/value_objects/measurement_mode.dart';
import 'package:menuario/src/shared/domain/value_objects/package_spec.dart';
import 'package:menuario/src/shared/domain/value_objects/quantity.dart';
import 'package:menuario/src/shared/domain/value_objects/unit.dart';

void main() {
  const service = StockLensService();

  const mass = Ingredient(
    id: 'ingredient-carne',
    name: 'Carne molida',
    category: Category.proteina,
    measurementKind: MeasurementKind.bulk,
    booleanTracked: false,
    measurementMode: MeasurementMode.mass,
  );

  const count = Ingredient(
    id: 'ingredient-kiwi',
    name: 'Kiwi',
    category: Category.fruta,
    measurementKind: MeasurementKind.unit,
    booleanTracked: false,
    measurementMode: MeasurementMode.count,
  );

  const leche = Ingredient(
    id: 'ingredient-leche',
    name: 'Leche',
    category: Category.lacteo,
    measurementKind: MeasurementKind.bulk,
    booleanTracked: false,
    measurementMode: MeasurementMode.packageBase,
    package: PackageSpec(
      label: 'bolsas',
      yieldQty: 1,
      baseDimension: Unit.liter,
    ),
  );

  const carton = Ingredient(
    id: 'ingredient-huevo',
    name: 'Huevo',
    category: Category.proteina,
    measurementKind: MeasurementKind.unit,
    booleanTracked: false,
    measurementMode: MeasurementMode.packageBase,
    package: PackageSpec(
      label: 'cartón',
      yieldQty: 15,
      baseDimension: Unit.count,
    ),
  );

  const lechuga = Ingredient(
    id: 'ingredient-lechuga',
    name: 'Lechuga',
    category: Category.vegetal,
    measurementKind: MeasurementKind.bulk,
    booleanTracked: false,
    measurementMode: MeasurementMode.packageAbstract,
    package: PackageSpec(label: 'bolsa'),
  );

  const requeson = Ingredient(
    id: 'ingredient-requeson',
    name: 'Requesón',
    category: Category.lacteo,
    measurementKind: MeasurementKind.bulk,
    booleanTracked: false,
    measurementMode: MeasurementMode.packageAbstract,
    package: PackageSpec(label: 'pana'),
  );

  const boolean = Ingredient(
    id: 'ingredient-sal',
    name: 'Sal',
    category: Category.condimento,
    measurementKind: MeasurementKind.bulk,
    booleanTracked: true,
    measurementMode: MeasurementMode.boolean,
  );

  group('StockLensService', () {
    group('lensesFor', () {
      test('mass mode offers g and lb, both decimal', () {
        // Act
        final lenses = service.lensesFor(mass);

        // Assert
        expect(lenses, hasLength(2));
        expect(lenses[0].label, 'g');
        expect(lenses[0].canonicalPerUnit, 1);
        expect(lenses[0].allowsDecimal, isTrue);
        expect(lenses[1].label, 'lb');
        expect(lenses[1].canonicalPerUnit, Mass.gramsPerPound);
        expect(lenses[1].allowsDecimal, isTrue);
      });

      test('count mode offers a single integer-only lens u', () {
        // Act
        final lenses = service.lensesFor(count);

        // Assert
        expect(lenses, hasLength(1));
        expect(lenses.single.label, 'u');
        expect(lenses.single.canonicalPerUnit, 1);
        expect(lenses.single.allowsDecimal, isFalse);
      });

      test('packageBase mode offers the pack lens (yieldQty) and the '
          'base-dimension lens (leche bolsa=1L, base L)', () {
        // Act
        final lenses = service.lensesFor(leche);

        // Assert
        expect(lenses, hasLength(2));
        expect(lenses[0].label, 'bolsas');
        expect(lenses[0].canonicalPerUnit, 1);
        expect(lenses[0].allowsDecimal, isTrue);
        expect(lenses[1].label, 'L');
        expect(lenses[1].canonicalPerUnit, 1);
        expect(lenses[1].allowsDecimal, isTrue);
      });

      test('packageBase mode with a count base dimension (huevo cartón, '
          'yieldQty 15, base u)', () {
        // Act
        final lenses = service.lensesFor(carton);

        // Assert
        expect(lenses, hasLength(2));
        expect(lenses[0].label, 'cartón');
        expect(lenses[0].canonicalPerUnit, 15);
        expect(lenses[1].label, 'u');
        expect(lenses[1].canonicalPerUnit, 1);
      });

      test('packageAbstract mode offers a single decimal package lens '
          '(lechuga bolsa)', () {
        // Act
        final lenses = service.lensesFor(lechuga);

        // Assert
        expect(lenses, hasLength(1));
        expect(lenses.single.label, 'bolsa');
        expect(lenses.single.canonicalPerUnit, 1);
        expect(lenses.single.allowsDecimal, isTrue);
      });

      test('boolean mode offers no lenses', () {
        // Act
        final lenses = service.lensesFor(boolean);

        // Assert
        expect(lenses, isEmpty);
      });
    });

    group('defaultLensFor', () {
      test('mass mode defaults to lb', () {
        // Act & Assert
        expect(service.defaultLensFor(mass).label, 'lb');
      });

      test('count mode defaults to u', () {
        // Act & Assert
        expect(service.defaultLensFor(count).label, 'u');
      });

      test('packageBase mode defaults to the pack lens (leche -> bolsas)', () {
        // Act & Assert
        expect(service.defaultLensFor(leche).label, 'bolsas');
      });

      test('packageAbstract mode defaults to the pack lens '
          '(lechuga -> bolsa)', () {
        // Act & Assert
        expect(service.defaultLensFor(lechuga).label, 'bolsa');
      });

      test('an explicit defaultLensLabel override wins over the heuristic '
          '(mass overridden to g instead of lb)', () {
        // Arrange
        final overridden = mass.copyWith(defaultLensLabel: 'g');

        // Act & Assert
        expect(service.defaultLensFor(overridden).label, 'g');
      });

      test('the override persists a packageBase pick of the base-unit '
          'lens instead of the pack lens (huevo -> u)', () {
        // Arrange
        final overridden = carton.copyWith(defaultLensLabel: 'u');

        // Act & Assert
        expect(service.defaultLensFor(overridden).label, 'u');
      });

      test('an override that does not match any lens for this mode falls '
          'back to the heuristic', () {
        // Arrange
        final overridden = mass.copyWith(defaultLensLabel: 'bolsa');

        // Act & Assert
        expect(service.defaultLensFor(overridden).label, 'lb');
      });
    });

    group('stockStep', () {
      test('mass mode steps by a quarter of the default lens (lb)', () {
        // Act
        final step = service.stockStep(mass);

        // Assert
        expect(step, closeTo(Mass.gramsPerPound / 4, 1e-9));
      });

      test('count mode steps by exactly 1 whole unit', () {
        // Act & Assert
        expect(service.stockStep(count), 1);
      });

      test('packageBase mode steps by a quarter of the pack lens '
          '(leche -> 0.25 bolsa = 0.25 L)', () {
        // Act & Assert
        expect(service.stockStep(leche), closeTo(0.25, 1e-9));
      });

      test('packageAbstract mode steps by a percent-granular 0.01', () {
        // Act & Assert
        expect(service.stockStep(lechuga), closeTo(0.01, 1e-9));
      });

      test('boolean mode has no numeric step', () {
        // Act & Assert
        expect(service.stockStep(boolean), 0);
      });
    });

    group('canonicalUnitFor', () {
      test('mass mode canonical unit is grams', () {
        // Act & Assert
        expect(service.canonicalUnitFor(mass), Unit.gram);
      });

      test('count mode canonical unit is count', () {
        // Act & Assert
        expect(service.canonicalUnitFor(count), Unit.count);
      });

      test('packageBase mode canonical unit is the package base '
          'dimension (leche -> liter)', () {
        // Act & Assert
        expect(service.canonicalUnitFor(leche), Unit.liter);
      });

      test('packageBase mode with a count base dimension '
          '(huevo -> count)', () {
        // Act & Assert
        expect(service.canonicalUnitFor(carton), Unit.count);
      });

      test('packageAbstract mode canonical unit is the abstract package '
          'unit', () {
        // Act & Assert
        expect(service.canonicalUnitFor(lechuga), Unit.package);
      });
    });

    group('formatStock', () {
      test('exact half renders the glyph (packageAbstract 0.5 -> "½ '
          'bolsa")', () {
        // Arrange
        const stock = Quantity(value: 0.5, unit: Unit.package);

        // Act & Assert
        expect(service.formatStock(lechuga, stock), '½ bolsa');
      });

      test('exact quarter renders the glyph on a base-lens value '
          '(mass g -> "¼ lb")', () {
        // Arrange
        const stock = Quantity(
          value: Mass.gramsPerPound / 4,
          unit: Unit.gram,
        );

        // Act & Assert
        expect(service.formatStock(mass, stock), '¼ lb');
      });

      test('near-clean fraction wins over percent for packageAbstract '
          '(requeson 0.2 -> "⅕ pana")', () {
        // Arrange
        const stock = Quantity(value: 0.2, unit: Unit.package);

        // Act & Assert
        expect(service.formatStock(requeson, stock), '⅕ pana');
      });

      test('a packageAbstract value with no clean-fraction match renders '
          'a percent (0.37 -> "37% pana")', () {
        // Arrange
        const stock = Quantity(value: 0.37, unit: Unit.package);

        // Act & Assert
        expect(service.formatStock(requeson, stock), '37% pana');
      });

      test('a non-package non-fraction decimal renders 2dp '
          '(mass 800 g -> "1.76 lb", pinned)', () {
        // Arrange
        const stock = Quantity(value: 800, unit: Unit.gram);

        // Act & Assert
        expect(service.formatStock(mass, stock), '1.76 lb');
      });

      test('a mixed-number package renders the glyph with the whole '
          'part (leche 3.5 bolsas -> "3½ bolsas", pinned)', () {
        // Arrange
        const stock = Quantity(value: 3.5, unit: Unit.liter);

        // Act & Assert
        expect(service.formatStock(leche, stock), '3½ bolsas');
      });

      test('a packageBase value with no clean-fraction match renders a '
          '2dp decimal, not a percent (huevo 7 u -> "0.47 cartón")', () {
        // Arrange
        const stock = Quantity(value: 7, unit: Unit.count);

        // Act & Assert
        expect(service.formatStock(carton, stock), '0.47 cartón');
      });

      test('typing pounds converts and previews the fraction '
          '(1.75 lb -> 793.8 g canonical, formats "1¾ lb")', () {
        // Arrange
        final lens = service.defaultLensFor(mass);
        final canonical = lens.toCanonical(1.75);
        final stock = Quantity(value: canonical, unit: Unit.gram);

        // Act & Assert
        expect(canonical, closeTo(793.8, 0.05));
        expect(service.formatStock(mass, stock), '1¾ lb');
      });
    });

    group('isEffectivelyZero', () {
      test('a sub-display residual rounds to zero at display precision '
          '(mass 2 g -> "0.00 lb" -> effectively zero)', () {
        // Arrange
        const stock = Quantity(value: 2, unit: Unit.gram);

        // Act & Assert
        expect(service.isEffectivelyZero(mass, stock), isTrue);
      });

      test('a nonzero display is NOT effectively zero (800 g -> '
          '"1.76 lb")', () {
        // Arrange
        const stock = Quantity(value: 800, unit: Unit.gram);

        // Act & Assert
        expect(service.isEffectivelyZero(mass, stock), isFalse);
      });

      test('exact canonical zero is effectively zero', () {
        // Arrange
        const stock = Quantity(value: 0, unit: Unit.gram);

        // Act & Assert
        expect(service.isEffectivelyZero(mass, stock), isTrue);
      });

      test('a count-mode item with a positive whole count is not '
          'effectively zero', () {
        // Arrange
        const stock = Quantity(value: 3, unit: Unit.count);

        // Act & Assert
        expect(service.isEffectivelyZero(count, stock), isFalse);
      });
    });
  });
}
