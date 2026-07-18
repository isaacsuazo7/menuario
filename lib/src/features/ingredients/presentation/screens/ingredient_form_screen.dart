import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:menuario/src/core/theme/spacing.dart';
import 'package:menuario/src/core/theme/typography.dart';
import 'package:menuario/src/features/ingredients/presentation/providers/ingredient_edit_provider.dart';
import 'package:menuario/src/features/ingredients/presentation/providers/ingredient_form_controller.dart';
import 'package:menuario/src/features/ingredients/presentation/providers/ingredient_pantry_edit_provider.dart';
import 'package:menuario/src/features/ingredients/presentation/providers/ingredients_list_provider.dart';
import 'package:menuario/src/features/provisioning/presentation/providers/pantry_controller.dart';
import 'package:menuario/src/shared/presentation/single_emoji_input_formatter.dart';
import 'package:menuario/src/shared/shared.dart';
import 'package:reactive_forms/reactive_forms.dart';

/// Full-screen create/edit form for the ingredient catalog.
///
/// A single "¿Cómo lo medís?" selector drives [MeasurementMode], with
/// per-mode conditional fields (package name/yield/base-unit for `Por
/// paquete`, a [StockLens]-driven default-lens selector doubling as the
/// initial-stock entry lens, and `Factor de conversión` behind a collapsed
/// "Avanzado" section), plus a "Tipo de necesidad" selector driving
/// [NeedType] (Por recetas / 1 por semana / Opcional) for the weekly
/// budget's coverage/shopping calc. Confirm wires atomically to
/// [IngredientCatalogRepository.saveWithPantry] via
/// [IngredientFormController].
class IngredientFormScreen extends ConsumerStatefulWidget {
  const IngredientFormScreen({super.key, this.ingredientId});

  /// The [Ingredient.id] being edited, or `null` when creating.
  final String? ingredientId;

  @override
  ConsumerState<IngredientFormScreen> createState() =>
      _IngredientFormScreenState();
}

class _IngredientFormScreenState extends ConsumerState<IngredientFormScreen> {
  bool _prefilled = false;
  bool _pantryPrefilled = false;

  bool get _isEdit => widget.ingredientId != null;

  /// Builds the [Ingredient] + matching [PantryItem] under one shared id
  /// (minted once on create, reused on edit) and commits both atomically
  /// via [IngredientCatalogRepository.saveWithPantry]. On success, pops
  /// the form and invalidates the read surfaces that must reflect it; on
  /// `Left(Failure)`, shows a `SnackBar` and stays on the form.
  Future<void> _handleConfirm() async {
    final catalogRepository = ref.read(ingredientCatalogRepositoryProvider);
    final id = widget.ingredientId ?? catalogRepository.newId();
    final notifier = ref.read(ingredientFormControllerProvider.notifier);
    final ingredient = notifier.toEntity(id);
    final pantryItem = notifier.toPantryItem(id);

    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);
    // Solo se parchean los providers ya montados: leer su notifier cuando
    // no existen dispararía una carga completa innecesaria. Si no están
    // montados no hay nada que sincronizar — su primera carga ya traerá el
    // ingrediente recién guardado.
    final pantryIsLoaded = ref.exists(pantryControllerProvider);
    final catalogIsLoaded = ref.exists(ingredientsListProvider);

    final result = await catalogRepository.saveWithPantry(
      ingredient: ingredient,
      pantryItem: pantryItem,
    );

    if (!mounted) return;

    result.fold(
      (failure) =>
          messenger.showSnackBar(SnackBar(content: Text(failure.message))),
      (_) {
        // Todo se parchea en sitio en vez de invalidarse: este form es una
        // ruta raíz y sus lectores (catálogo, Despensa, Recetario) viven en
        // ramas del shell que go_router pausa con TickerMode. Con las
        // suscripciones pausadas el elemento queda `isActive == false`, el
        // scheduler no lo reconstruye y el siguiente build de esa rama lo
        // hace a mitad de frame -> setState during build.
        // `ingredientsByIdProvider` deriva de `ingredientsListProvider`,
        // así que este único upsert alcanza a ambos.
        if (catalogIsLoaded) {
          ref
              .read(ingredientsListProvider.notifier)
              .upsertIngredient(ingredient);
        }
        if (pantryIsLoaded) {
          ref
              .read(pantryControllerProvider.notifier)
              .upsertRow(ingredient: ingredient, item: pantryItem);
        }
        navigator.pop(id);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final editValue = widget.ingredientId == null
        ? const AsyncValue<Ingredient?>.data(null)
        : ref.watch(ingredientEditProvider(widget.ingredientId));
    final pantryEditValue = widget.ingredientId == null
        ? const AsyncValue<PantryItem?>.data(null)
        : ref.watch(ingredientPantryEditProvider(widget.ingredientId));
    final form = ref.watch(ingredientFormControllerProvider);

    // Seed the form once for each async source, when available. Deferred
    // via addPostFrameCallback so we never mutate the FormGroup that
    // ReactiveForm is watching mid-build. Registration order (ingredient
    // before pantry) matches post-frame callback execution order, so the
    // pantry prefill always sees the already-prefilled mode/lens override.
    editValue.whenData((ingredient) {
      if (ingredient == null || _prefilled) return;
      _prefilled = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        ref
            .read(ingredientFormControllerProvider.notifier)
            .prefillIngredient(ingredient);
      });
    });

    pantryEditValue.whenData((pantryItem) {
      if (pantryItem == null || _pantryPrefilled) return;
      _pantryPrefilled = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        ref
            .read(ingredientFormControllerProvider.notifier)
            .prefillPantry(pantryItem);
      });
    });

    return ReactiveForm(
      formGroup: form,
      child: Scaffold(
        appBar: AppBar(
          title: Text(_isEdit ? 'Editar ingrediente' : 'Nuevo ingrediente'),
        ),
        body: AppAsyncValueWidget<Ingredient?>(
          value: editValue,
          onRetry: () =>
              ref.invalidate(ingredientEditProvider(widget.ingredientId)),
          builder: (context, _) => AppAsyncValueWidget<PantryItem?>(
            value: pantryEditValue,
            onRetry: () => ref.invalidate(
              ingredientPantryEditProvider(widget.ingredientId),
            ),
            builder: (context, _) =>
                _IngredientFormBody(onConfirm: _handleConfirm),
          ),
        ),
      ),
    );
  }
}

/// The form's scrollable body — rebuilds on any [FormGroup] control change
/// via [ReactiveFormConsumer], mirroring the previous `setState`-on-every-
/// keystroke behavior.
class _IngredientFormBody extends ConsumerWidget {
  const _IngredientFormBody({required this.onConfirm});

  final Future<void> Function() onConfirm;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ReactiveFormConsumer(
      builder: (context, form, child) {
        final modeChoice =
            form.control('modeChoice').value as IngredientModeChoice;
        final allowsConversionFactor =
            IngredientFormController.allowsConversionFactor(form);

        return SingleChildScrollView(
          padding: MenuarioSpacing.paddingAll16,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ReactiveTextField<String>(
                key: const Key('ingredient-name-field'),
                formControlName: 'name',
                decoration: const InputDecoration(labelText: 'Nombre'),
              ),
              MenuarioSpacing.gapV16,
              ReactiveTextField<String>(
                key: const Key('ingredient-emoji-field'),
                formControlName: 'emoji',
                inputFormatters: const [SingleEmojiInputFormatter()],
                decoration: const InputDecoration(
                  labelText: 'Emoji (opcional)',
                ),
              ),
              MenuarioSpacing.gapV16,
              DropdownButtonFormField<Category>(
                key: const Key('ingredient-category-field'),
                initialValue: form.control('category').value as Category,
                decoration: const InputDecoration(labelText: 'Categoría'),
                items: [
                  for (final category in Category.values)
                    DropdownMenuItem(
                      value: category,
                      child: Text(category.label),
                    ),
                ],
                onChanged: (value) {
                  if (value != null) {
                    form.control('category').value = value;
                  }
                },
              ),
              MenuarioSpacing.gapV16,
              Text('¿Cómo lo medís?', style: MenuarioTypography.body),
              MenuarioSpacing.gapV8,
              SegmentedButton<IngredientModeChoice>(
                key: const Key('ingredient-mode-field'),
                style: const ButtonStyle(
                  visualDensity: VisualDensity.compact,
                  textStyle: WidgetStatePropertyAll(TextStyle(fontSize: 12)),
                ),
                segments: const [
                  ButtonSegment(
                    value: IngredientModeChoice.mass,
                    icon: Text('⚖️'),
                    label: Text('Por peso'),
                  ),
                  ButtonSegment(
                    value: IngredientModeChoice.count,
                    icon: Text('#️⃣'),
                    label: Text('Por unidad'),
                  ),
                  ButtonSegment(
                    value: IngredientModeChoice.package,
                    icon: Text('📦'),
                    label: Text('Por paquete'),
                  ),
                  ButtonSegment(
                    value: IngredientModeChoice.boolean,
                    icon: Text('✓'),
                    label: Text('Sí-No'),
                  ),
                ],
                selected: {modeChoice},
                showSelectedIcon: false,
                onSelectionChanged: (selection) => ref
                    .read(ingredientFormControllerProvider.notifier)
                    .handleModeChanged(selection.first),
              ),
              MenuarioSpacing.gapV16,
              Text('Tipo de necesidad', style: MenuarioTypography.body),
              MenuarioSpacing.gapV8,
              SegmentedButton<NeedType>(
                key: const Key('ingredient-need-type-field'),
                style: const ButtonStyle(
                  visualDensity: VisualDensity.compact,
                  textStyle: WidgetStatePropertyAll(TextStyle(fontSize: 12)),
                ),
                segments: const [
                  ButtonSegment(
                    value: NeedType.recipeDriven,
                    label: Text('Por recetas'),
                  ),
                  ButtonSegment(
                    value: NeedType.weeklyFixed,
                    label: Text('1 por semana'),
                  ),
                  ButtonSegment(
                    value: NeedType.optional,
                    label: Text('Opcional'),
                  ),
                ],
                selected: {form.control('needType').value as NeedType},
                showSelectedIcon: false,
                onSelectionChanged: (selection) =>
                    form.control('needType').value = selection.first,
              ),
              if (IngredientFormController.allowsPackage(form)) ...[
                MenuarioSpacing.gapV16,
                _PackageSection(form: form, modeChoice: modeChoice),
              ],
              if (allowsConversionFactor) ...[
                MenuarioSpacing.gapV16,
                ExpansionTile(
                  key: const Key('ingredient-advanced-section'),
                  title: const Text('Avanzado'),
                  tilePadding: EdgeInsets.zero,
                  children: [
                    ReactiveTextField<String>(
                      key: const Key('ingredient-conversion-factor-field'),
                      formControlName: 'conversionFactor',
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      decoration: InputDecoration(
                        labelText: 'Factor de conversión',
                        helperText: modeChoice == IngredientModeChoice.count
                            ? 'Opcional — unidades de stock por unidad de '
                                  'receta (ej. taza); 1 = 1 taza equivale a '
                                  '1 unidad'
                            : null,
                      ),
                    ),
                  ],
                ),
              ],
              MenuarioSpacing.gapV16,
              _PantrySection(form: form, modeChoice: modeChoice),
              MenuarioSpacing.gapV24,
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Cancelar'),
                  ),
                  MenuarioSpacing.gapH8,
                  FilledButton(
                    onPressed: form.valid ? () => onConfirm() : null,
                    child: const Text('Confirmar'),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}

/// How the ingredient is PACKAGED for purchase.
///
/// For `Por paquete` the package IS the stock unit, so its name, yield and
/// base unit are required together. For `Por unidad` the ingredient is
/// stocked and consumed in units but may still be BOUGHT by the pack
/// (salmas: 1 caja = 8 bolsas × 3 u) — the whole block is then optional and
/// exists only so purchases round up to whole packs, which is why the base
/// unit is not offered there (the total is already in units).
class _PackageSection extends StatelessWidget {
  const _PackageSection({required this.form, required this.modeChoice});

  final FormGroup form;
  final IngredientModeChoice modeChoice;

  @override
  Widget build(BuildContext context) {
    final isCount = modeChoice == IngredientModeChoice.count;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (isCount) ...[
          Text('Cómo lo comprás (opcional)', style: MenuarioTypography.body),
          MenuarioSpacing.gapV8,
        ],
        ReactiveTextField<String>(
          key: const Key('ingredient-package-label-field'),
          formControlName: 'packageLabel',
          decoration: InputDecoration(
            labelText: isCount
                ? 'Nombre del paquete (ej. caja)'
                : 'Nombre del paquete (ej. bolsa, caja, pana)',
          ),
        ),
        MenuarioSpacing.gapV16,
        ReactiveTextField<String>(
          key: const Key('ingredient-package-yield-field'),
          formControlName: 'packageYield',
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: InputDecoration(
            labelText: isCount
                ? '¿Cuántas unidades trae en total?'
                : '¿Cuánto trae?',
          ),
        ),
        if (!isCount) ...[
          MenuarioSpacing.gapV16,
          DropdownButtonFormField<Unit?>(
            key: const Key('ingredient-package-base-unit-field'),
            initialValue: form.control('packageBaseUnit').value as Unit?,
            decoration: const InputDecoration(labelText: 'Unidad base'),
            items: [
              for (final unit in ingredientBaseUnitOptions)
                DropdownMenuItem(
                  value: unit,
                  child: Text(ingredientBaseUnitLabel(unit)),
                ),
            ],
            onChanged: (value) => form.control('packageBaseUnit').value = value,
          ),
        ],
        MenuarioSpacing.gapV16,
        _InnerPackSection(form: form),
      ],
    );
  }
}

/// The OPTIONAL second packaging level: an outer pack (caja) holding N
/// inner packs (bolsas) of M units each.
///
/// Both quantities are optional — leaving them empty keeps the package
/// single-level, exactly as before. Filling them derives the total units
/// per outer pack and shows it as helper text, so the user never
/// hand-multiplies (which is where their numbers went wrong).
class _InnerPackSection extends StatelessWidget {
  const _InnerPackSection({required this.form});

  final FormGroup form;

  @override
  Widget build(BuildContext context) {
    final helperText = IngredientFormController.innerPackHelperText(form);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '¿La caja trae paquetes adentro? (opcional)',
          style: MenuarioTypography.body,
        ),
        MenuarioSpacing.gapV8,
        ReactiveTextField<String>(
          key: const Key('ingredient-package-inner-label-field'),
          formControlName: 'packageInnerLabel',
          decoration: const InputDecoration(
            labelText: 'Nombre del paquete interno (ej. bolsa)',
          ),
        ),
        MenuarioSpacing.gapV16,
        ReactiveTextField<String>(
          key: const Key('ingredient-package-inner-qty-field'),
          formControlName: 'packageInnerQty',
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: const InputDecoration(
            labelText: '¿Cuántas unidades trae cada paquete interno?',
          ),
        ),
        MenuarioSpacing.gapV16,
        ReactiveTextField<String>(
          key: const Key('ingredient-package-inner-count-field'),
          formControlName: 'packageInnerCount',
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: const InputDecoration(
            labelText: '¿Cuántos paquetes internos trae?',
          ),
        ),
        if (helperText != null) ...[
          MenuarioSpacing.gapV8,
          Text(
            helperText,
            style: MenuarioTypography.body.withColor(
              Theme.of(context).colorScheme.primary,
            ),
          ),
        ],
      ],
    );
  }
}

/// The adaptive pantry section: a have/don't-have flag for `Sí-No`, or a
/// default-lens selector + initial-stock entry otherwise.
class _PantrySection extends StatelessWidget {
  const _PantrySection({required this.form, required this.modeChoice});

  final FormGroup form;
  final IngredientModeChoice modeChoice;

  @override
  Widget build(BuildContext context) {
    return modeChoice == IngredientModeChoice.boolean
        ? _HaveFlagSection(form: form)
        : _QuantitySection(form: form);
  }
}

class _HaveFlagSection extends StatelessWidget {
  const _HaveFlagSection({required this.form});

  final FormGroup form;

  @override
  Widget build(BuildContext context) {
    return SegmentedButton<bool>(
      key: const Key('ingredient-have-it-field'),
      segments: const [
        ButtonSegment(value: true, label: Text('Tengo')),
        ButtonSegment(value: false, label: Text('No tengo')),
      ],
      selected: {form.control('haveIt').value as bool? ?? false},
      onSelectionChanged: (selection) =>
          form.control('haveIt').value = selection.first,
    );
  }
}

class _QuantitySection extends ConsumerWidget {
  const _QuantitySection({required this.form});

  final FormGroup form;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final lensList = IngredientFormController.lenses(form);
    final selectedLens = IngredientFormController.selectedLens(form);
    final canonical = IngredientFormController.canonicalStockValue(form);
    final otherLenses = lensList.where((lens) => lens != selectedLens);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (lensList.length > 1) ...[
          Text('Unidad por defecto', style: MenuarioTypography.body),
          MenuarioSpacing.gapV8,
          SegmentedButton<StockLens>(
            key: const Key('ingredient-default-lens-field'),
            segments: [
              for (final lens in lensList)
                ButtonSegment(value: lens, label: Text(lens.label)),
            ],
            selected: {selectedLens!},
            showSelectedIcon: false,
            onSelectionChanged: (selection) => ref
                .read(ingredientFormControllerProvider.notifier)
                .handleLensChanged(selection.first),
          ),
          MenuarioSpacing.gapV16,
        ],
        ReactiveTextField<String>(
          key: const Key('ingredient-stock-field'),
          formControlName: 'stock',
          keyboardType: TextInputType.numberWithOptions(
            decimal: selectedLens?.allowsDecimal ?? true,
          ),
          inputFormatters: [
            if (selectedLens?.allowsDecimal ?? true)
              FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*'))
            else
              FilteringTextInputFormatter.digitsOnly,
          ],
          decoration: InputDecoration(
            labelText: 'Existencia inicial',
            suffixText: selectedLens?.label,
          ),
        ),
        MenuarioSpacing.gapV8,
        if (canonical == null)
          Text('Ingresa una existencia válida', style: MenuarioTypography.body)
        else
          for (final lens in otherLenses)
            Text(
              '= ${formatNatural(lens.fromCanonical(canonical), lens)} '
              '${lens.label}',
              style: MenuarioTypography.body,
            ),
      ],
    );
  }
}
