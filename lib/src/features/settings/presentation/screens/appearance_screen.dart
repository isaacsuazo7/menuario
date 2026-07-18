import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:menuario/src/core/error/failure.dart';
import 'package:menuario/src/core/theme/app_seed.dart';
import 'package:menuario/src/core/theme/spacing.dart';
import 'package:menuario/src/core/theme/typography.dart';
import 'package:menuario/src/features/settings/presentation/providers/theme_settings_provider.dart';
import 'package:menuario/src/shared/domain/entities/theme_settings.dart';
import 'package:menuario/src/shared/presentation/widgets/app_async_value_widget.dart';

/// Lets the user tune the only two configurable theme axes: the
/// [ThemeMode] and the seed the Material 3 palette descends from.
///
/// Text colors are deliberately absent — Material 3 derives them from the
/// seed — as are the domain color extensions, which stay brightness-derived
/// so "sin stock" keeps reading as an alarm under every palette.
class AppearanceScreen extends ConsumerWidget {
  const AppearanceScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: const Text('Apariencia')),
      body: AppAsyncValueWidget<ThemeSettings>(
        value: ref.watch(themeSettingsProvider),
        onRetry: () => ref.invalidate(themeSettingsProvider),
        builder: (context, settings) => ListView(
          padding: MenuarioSpacing.paddingAll16,
          children: [
            Text('Tema', style: MenuarioTypography.h5),
            MenuarioSpacing.gapV8,
            _ModeSelector(mode: settings.mode),
            MenuarioSpacing.gapV32,
            Text('Color', style: MenuarioTypography.h5),
            MenuarioSpacing.gapV8,
            Text(
              'Define toda la paleta de la app.',
              style: MenuarioTypography.body.withColor(
                Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
            MenuarioSpacing.gapV16,
            _SeedPicker(selected: settings.seed),
          ],
        ),
      ),
    );
  }
}

/// Reports [failure] to the user, if any. The mutation already rolled the
/// optimistic change back, so the message is all that is left to do.
void _reportFailure(BuildContext context, Failure? failure) {
  if (failure == null || !context.mounted) return;

  ScaffoldMessenger.of(
    context,
  ).showSnackBar(SnackBar(content: Text(failure.message)));
}

/// The light/dark/system switch.
class _ModeSelector extends ConsumerWidget {
  const _ModeSelector({required this.mode});

  final ThemeMode mode;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SegmentedButton<ThemeMode>(
      segments: const [
        ButtonSegment(
          value: ThemeMode.light,
          label: Text('Claro'),
          icon: Icon(Icons.light_mode_outlined),
        ),
        ButtonSegment(
          value: ThemeMode.dark,
          label: Text('Oscuro'),
          icon: Icon(Icons.dark_mode_outlined),
        ),
        ButtonSegment(
          value: ThemeMode.system,
          label: Text('Sistema'),
          icon: Icon(Icons.brightness_auto_outlined),
        ),
      ],
      selected: {mode},
      showSelectedIcon: false,
      onSelectionChanged: (selection) async {
        final failure = await ref
            .read(themeSettingsProvider.notifier)
            .setMode(selection.first);
        if (!context.mounted) return;
        _reportFailure(context, failure);
      },
    );
  }
}

/// The curated seed grid — a closed list, never a free color picker.
class _SeedPicker extends StatelessWidget {
  const _SeedPicker({required this.selected});

  final Color selected;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: MenuarioSpacing.md,
      runSpacing: MenuarioSpacing.md,
      children: [
        for (final option in menuarioSeedOptions)
          _SeedSwatch(option: option, isSelected: option.color == selected),
      ],
    );
  }
}

/// A single tappable seed, labelled so the choice is not color-only.
class _SeedSwatch extends ConsumerWidget {
  const _SeedSwatch({required this.option, required this.isSelected});

  final MenuarioSeedOption option;
  final bool isSelected;

  static const double _diameter = 56;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = Theme.of(context).colorScheme;

    return InkWell(
      key: ValueKey('seed-${option.color.toARGB32()}'),
      borderRadius: BorderRadius.circular(_diameter),
      onTap: () async {
        final failure = await ref
            .read(themeSettingsProvider.notifier)
            .setSeed(option.color);
        if (!context.mounted) return;
        _reportFailure(context, failure);
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: _diameter,
            height: _diameter,
            decoration: BoxDecoration(
              color: option.color,
              shape: BoxShape.circle,
              border: Border.all(
                color: isSelected ? colors.onSurface : colors.outlineVariant,
                width: isSelected ? 3 : 1,
              ),
            ),
            child: isSelected
                ? Icon(
                    Icons.check,
                    // The swatch renders its own seed, not the active
                    // palette, so the tick is contrasted against that color
                    // rather than against `colorScheme`.
                    color:
                        ThemeData.estimateBrightnessForColor(option.color) ==
                            Brightness.dark
                        ? Colors.white
                        : Colors.black,
                  )
                : null,
          ),
          MenuarioSpacing.gapV4,
          SizedBox(
            width: _diameter + MenuarioSpacing.md,
            child: Text(
              option.label,
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: MenuarioTypography.body.withColor(colors.onSurfaceVariant),
            ),
          ),
        ],
      ),
    );
  }
}
