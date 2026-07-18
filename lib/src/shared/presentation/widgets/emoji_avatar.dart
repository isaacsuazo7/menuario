import 'package:flutter/material.dart';

/// A fixed-size rounded tile that anchors an emoji.
///
/// Every emoji in the app renders through this widget so a bare glyph never
/// floats on the surface: the tinted container gives it a consistent optical
/// weight and a predictable footprint, which is what keeps list rows aligned.
///
/// The background comes from `colorScheme.surfaceContainerHighest`, so it
/// re-tints with the user's chosen seed.
class EmojiAvatar extends StatelessWidget {
  const EmojiAvatar({
    super.key,
    required this.emoji,
    this.size = 40,
    this.border,
    this.child,
  });

  /// The emoji to center in the tile.
  final String emoji;

  /// The tile's square side. 40 suits meal rows; ~32 suits denser list rows.
  final double size;

  /// An optional accent ring, e.g. the week planner's slot accent.
  final BoxBorder? border;

  /// Replaces the emoji entirely — for empty-state affordances such as the
  /// planner's `+` icon, which still wants the tile's shape and background.
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(size * 0.3),
        border: border,
      ),
      alignment: Alignment.center,
      child: child ?? Text(emoji, style: TextStyle(fontSize: size * 0.5)),
    );
  }
}
