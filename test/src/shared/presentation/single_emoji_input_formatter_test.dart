import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:menuario/src/shared/presentation/single_emoji_input_formatter.dart';

void main() {
  group('SingleEmojiInputFormatter', () {
    const formatter = SingleEmojiInputFormatter();

    TextEditingValue format(String text) => formatter.formatEditUpdate(
      TextEditingValue.empty,
      TextEditingValue(
        text: text,
        selection: TextSelection.collapsed(offset: text.length),
      ),
    );

    test('should truncate multiple emojis to the first grapheme', () {
      // Act
      final result = format('😀🎉🔥');

      // Assert
      expect(result.text, '😀');
      expect(result.selection.baseOffset, '😀'.length);
    });

    test('should keep a single multi-code-unit emoji intact', () {
      // Arrange — a ZWJ family sequence is one grapheme, many code units.
      const family = '👨‍👩‍👧‍👦';

      // Act
      final result = format(family);

      // Assert
      expect(result.text, family);
    });

    test('should leave empty input empty', () {
      // Act
      final result = format('');

      // Assert
      expect(result.text, '');
    });
  });
}
