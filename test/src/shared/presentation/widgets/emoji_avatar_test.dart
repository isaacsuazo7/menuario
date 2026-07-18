import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:menuario/src/shared/shared.dart';

void main() {
  Future<void> pump(WidgetTester tester, {required Widget child}) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: ThemeData(useMaterial3: true),
        home: Scaffold(body: Center(child: child)),
      ),
    );
  }

  testWidgets('renders the emoji it is given', (tester) async {
    await pump(tester, child: const EmojiAvatar(emoji: '🥣'));

    expect(find.text('🥣'), findsOneWidget);
  });

  testWidgets('renders a rounded tinted background from the color scheme', (
    tester,
  ) async {
    await pump(tester, child: const EmojiAvatar(emoji: '🥣'));

    final context = tester.element(find.byType(EmojiAvatar));
    final container = tester.widget<Container>(
      find.descendant(
        of: find.byType(EmojiAvatar),
        matching: find.byType(Container),
      ),
    );
    final decoration = container.decoration! as BoxDecoration;

    expect(
      decoration.color,
      Theme.of(context).colorScheme.surfaceContainerHighest,
    );
    expect(decoration.borderRadius, isNotNull);
  });

  testWidgets('defaults to a 40pt square', (tester) async {
    await pump(tester, child: const EmojiAvatar(emoji: '🥣'));

    expect(tester.getSize(find.byType(EmojiAvatar)), const Size(40, 40));
  });

  testWidgets('honours an explicit size', (tester) async {
    await pump(tester, child: const EmojiAvatar(emoji: '🥣', size: 32));

    expect(tester.getSize(find.byType(EmojiAvatar)), const Size(32, 32));
  });

  testWidgets('scales the emoji with the avatar size', (tester) async {
    await pump(tester, child: const EmojiAvatar(emoji: '🥣', size: 32));

    final small = tester.widget<Text>(find.text('🥣')).style!.fontSize!;

    await pump(tester, child: const EmojiAvatar(emoji: '🥣', size: 64));

    final large = tester.widget<Text>(find.text('🥣')).style!.fontSize!;
    expect(large, greaterThan(small));
  });

  testWidgets('takes a border when one is given', (tester) async {
    await pump(
      tester,
      child: EmojiAvatar(
        emoji: '🥣',
        border: Border.all(color: const Color(0xFFFF0000)),
      ),
    );

    final container = tester.widget<Container>(
      find.descendant(
        of: find.byType(EmojiAvatar),
        matching: find.byType(Container),
      ),
    );
    expect((container.decoration! as BoxDecoration).border, isNotNull);
  });

  testWidgets('renders a replacement child instead of the emoji', (
    tester,
  ) async {
    await pump(
      tester,
      child: const EmojiAvatar(emoji: '🥣', child: Icon(Icons.add)),
    );

    expect(find.byIcon(Icons.add), findsOneWidget);
    expect(find.text('🥣'), findsNothing);
  });
}
