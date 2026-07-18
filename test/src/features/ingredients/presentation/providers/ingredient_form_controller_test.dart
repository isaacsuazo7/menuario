import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:menuario/src/features/ingredients/presentation/providers/ingredient_form_controller.dart';
import 'package:menuario/src/shared/shared.dart';
import 'package:reactive_forms/reactive_forms.dart';

void main() {
  late ProviderContainer container;

  setUp(() {
    container = ProviderContainer();
    addTearDown(container.dispose);
  });

  FormGroup form() => container.read(ingredientFormControllerProvider);

  IngredientFormController notifier() =>
      container.read(ingredientFormControllerProvider.notifier);

  void selectMode(IngredientModeChoice mode) {
    notifier().handleModeChanged(mode);
  }

  void setValues(Map<String, String> values) {
    values.forEach((name, value) {
      form().control(name).value = value;
    });
  }

  group('count mode with purchase packaging', () {
    test('builds the PackageSpec from label + inner pair, keeping the '
        'measurementMode as count', () {
      selectMode(IngredientModeChoice.count);
      setValues({
        'name': 'Salmas',
        'stock': '12',
        'packageLabel': 'caja',
        'packageInnerLabel': 'bolsa',
        'packageInnerQty': '3',
        'packageInnerCount': '8',
      });

      final spec = IngredientFormController.packageSpec(form());

      expect(spec, isNotNull);
      expect(spec!.label, 'caja');
      expect(spec.innerLabel, 'bolsa');
      expect(spec.innerQty, 3);
      expect(spec.innerCount, 8);
      expect(spec.effectiveYieldQty, 24);
      expect(
        IngredientFormController.measurementMode(form()),
        MeasurementMode.count,
      );
    });

    test('builds the PackageSpec from label + a direct total, with no base '
        'dimension and still measurementMode count', () {
      selectMode(IngredientModeChoice.count);
      setValues({
        'name': 'Galletas de arroz',
        'stock': '5',
        'packageLabel': 'caja',
        'packageYield': '20',
      });

      final spec = IngredientFormController.packageSpec(form());

      expect(spec, isNotNull);
      expect(spec!.label, 'caja');
      expect(spec.yieldQty, 20);
      expect(spec.baseDimension, isNull);
      expect(spec.effectiveYieldQty, 20);
      expect(
        IngredientFormController.measurementMode(form()),
        MeasurementMode.count,
      );
    });

    test('toEntity persists count + package together', () {
      selectMode(IngredientModeChoice.count);
      setValues({
        'name': 'Salmas',
        'stock': '12',
        'packageLabel': 'caja',
        'packageInnerLabel': 'bolsa',
        'packageInnerQty': '3',
        'packageInnerCount': '8',
      });

      final ingredient = notifier().toEntity('ing-salmas');

      expect(ingredient.measurementMode, MeasurementMode.count);
      expect(ingredient.package?.label, 'caja');
      expect(ingredient.package?.effectiveYieldQty, 24);
    });

    test('a blank package config yields no PackageSpec and stays '
        'confirmable', () {
      selectMode(IngredientModeChoice.count);
      setValues({'name': 'Huevo', 'stock': '7'});

      expect(IngredientFormController.packageSpec(form()), isNull);
      expect(IngredientFormController.canConfirm(form()), isTrue);
      expect(
        IngredientFormController.measurementMode(form()),
        MeasurementMode.count,
      );
    });

    test('a half-filled inner pair blocks Confirm', () {
      selectMode(IngredientModeChoice.count);
      setValues({
        'name': 'Salmas',
        'stock': '12',
        'packageLabel': 'caja',
        'packageInnerQty': '3',
      });

      expect(IngredientFormController.canConfirm(form()), isFalse);

      form().control('packageInnerCount').value = '8';

      expect(IngredientFormController.canConfirm(form()), isTrue);
    });

    test('package quantities without a package name block Confirm, so they '
        'are never silently dropped', () {
      selectMode(IngredientModeChoice.count);
      setValues({'name': 'Salmas', 'stock': '12', 'packageYield': '24'});

      expect(IngredientFormController.canConfirm(form()), isFalse);

      form().control('packageLabel').value = 'caja';

      expect(IngredientFormController.canConfirm(form()), isTrue);
    });

    test('a non-positive yield blocks Confirm', () {
      selectMode(IngredientModeChoice.count);
      setValues({
        'name': 'Salmas',
        'stock': '12',
        'packageLabel': 'caja',
        'packageYield': '0',
      });

      expect(IngredientFormController.canConfirm(form()), isFalse);
    });

    test('shows the computed total as helper text', () {
      selectMode(IngredientModeChoice.count);
      setValues({
        'name': 'Salmas',
        'packageLabel': 'caja',
        'packageInnerLabel': 'bolsa',
        'packageInnerQty': '3',
        'packageInnerCount': '8',
      });

      expect(
        IngredientFormController.innerPackHelperText(form()),
        '8 bolsas × 3 u = 24 u por caja',
      );
    });

    test('prefills an existing count + package ingredient', () {
      const salmas = Ingredient(
        id: 'ing-salmas',
        name: 'Salmas',
        category: Category.otro,
        measurementMode: MeasurementMode.count,
        package: PackageSpec(
          label: 'caja',
          innerLabel: 'bolsa',
          innerQty: 3,
          innerCount: 8,
        ),
      );

      notifier().prefillIngredient(salmas);

      expect(
        form().control('modeChoice').value,
        IngredientModeChoice.count,
      );
      expect(form().control('packageLabel').value, 'caja');
      expect(form().control('packageInnerLabel').value, 'bolsa');
      expect(form().control('packageInnerQty').value, '3');
      expect(form().control('packageInnerCount').value, '8');
      expect(
        IngredientFormController.packageSpec(form())?.effectiveYieldQty,
        24,
      );
    });

    test('prefills a count package stored as a direct total', () {
      const galletas = Ingredient(
        id: 'ing-galletas',
        name: 'Galletas de arroz',
        category: Category.otro,
        measurementMode: MeasurementMode.count,
        package: PackageSpec(label: 'caja', yieldQty: 20),
      );

      notifier().prefillIngredient(galletas);

      expect(form().control('packageLabel').value, 'caja');
      expect(form().control('packageYield').value, '20');
      expect(
        IngredientFormController.packageSpec(form())?.effectiveYieldQty,
        20,
      );
    });
  });

  group('package mode is unchanged', () {
    test('a complete yield + base unit still derives packageBase', () {
      selectMode(IngredientModeChoice.package);
      setValues({
        'name': 'Leche',
        'stock': '2',
        'conversionFactor': '1',
        'packageLabel': 'bolsa',
        'packageYield': '1',
      });
      form().control('packageBaseUnit').value = Unit.liter;

      final spec = IngredientFormController.packageSpec(form());

      expect(spec?.yieldQty, 1);
      expect(spec?.baseDimension, Unit.liter);
      expect(
        IngredientFormController.measurementMode(form()),
        MeasurementMode.packageBase,
      );
      expect(IngredientFormController.canConfirm(form()), isTrue);
    });

    test('a label with no yield still derives packageAbstract', () {
      selectMode(IngredientModeChoice.package);
      setValues({
        'name': 'Lechuga',
        'stock': '1',
        'conversionFactor': '1',
        'packageLabel': 'bolsa',
      });

      final spec = IngredientFormController.packageSpec(form());

      expect(spec?.label, 'bolsa');
      expect(spec?.yieldQty, isNull);
      expect(
        IngredientFormController.measurementMode(form()),
        MeasurementMode.packageAbstract,
      );
    });

    test('a yield without a base unit still blocks Confirm', () {
      selectMode(IngredientModeChoice.package);
      setValues({
        'name': 'Leche',
        'stock': '2',
        'conversionFactor': '1',
        'packageLabel': 'bolsa',
        'packageYield': '1',
      });

      expect(IngredientFormController.canConfirm(form()), isFalse);
    });

    test('an empty package label still blocks Confirm', () {
      selectMode(IngredientModeChoice.package);
      setValues({'name': 'Leche', 'stock': '2', 'conversionFactor': '1'});

      expect(IngredientFormController.canConfirm(form()), isFalse);
    });

    test('a half-filled inner pair still blocks Confirm', () {
      selectMode(IngredientModeChoice.package);
      setValues({
        'name': 'Leche',
        'stock': '2',
        'conversionFactor': '1',
        'packageLabel': 'caja',
        'packageInnerCount': '8',
      });

      expect(IngredientFormController.canConfirm(form()), isFalse);
    });
  });

  group('other modes never build a package', () {
    test('mass mode ignores package fields', () {
      selectMode(IngredientModeChoice.mass);
      setValues({'packageLabel': 'caja', 'packageYield': '24'});

      expect(IngredientFormController.packageSpec(form()), isNull);
      expect(
        IngredientFormController.measurementMode(form()),
        MeasurementMode.mass,
      );
    });

    test('boolean mode ignores package fields', () {
      selectMode(IngredientModeChoice.boolean);
      setValues({'name': 'Comino', 'packageLabel': 'caja'});

      expect(IngredientFormController.packageSpec(form()), isNull);
      expect(
        IngredientFormController.measurementMode(form()),
        MeasurementMode.boolean,
      );
      expect(IngredientFormController.canConfirm(form()), isTrue);
    });
  });
}
