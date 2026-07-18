import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

/// Limita un campo de texto a UN solo grafema (cluster), de modo que un
/// emoji compuesto por varias unidades de código (p. ej. una secuencia ZWJ)
/// cuente como un único carácter en lugar de truncarse a la mitad.
class SingleEmojiInputFormatter extends TextInputFormatter {
  const SingleEmojiInputFormatter();

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final characters = newValue.text.characters;
    if (characters.length <= 1) return newValue;

    final first = characters.first;
    return TextEditingValue(
      text: first,
      selection: TextSelection.collapsed(offset: first.length),
    );
  }
}
