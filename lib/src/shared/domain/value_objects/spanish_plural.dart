const _vowels = {'a', 'e', 'i', 'o', 'u'};

const _accents = {'á': 'a', 'é': 'e', 'í': 'i', 'ó': 'o', 'ú': 'u'};

/// Pluraliza [word] en español cuando [count] no es exactamente 1.
String pluralizeEs(String word, num count) {
  if (count == 1) return word;

  // Los labels reales traen la medida pegada ("bolsa 1 L", "pana 500 g"),
  // así que solo el sustantivo inicial se pluraliza.
  final headEnd = word.indexOf(' ');
  if (headEnd != -1) {
    final head = pluralizeEs(word.substring(0, headEnd), count);
    return '$head${word.substring(headEnd)}';
  }

  if (word.isEmpty) return word;

  final last = word[word.length - 1].toLowerCase();
  if (last == 'z') return '${word.substring(0, word.length - 1)}ces';
  if (_vowels.contains(last)) return '${word}s';
  return '${_dropFinalAccent(word)}es';
}

/// Quita la tilde de la última sílaba tónica ("cartón" -> "cartones").
String _dropFinalAccent(String word) {
  if (word.length < 2) return word;

  final index = word.length - 2;
  final char = word[index];
  final plain = _accents[char.toLowerCase()];
  if (plain == null) return word;

  final isUpper = char != char.toLowerCase();
  final replacement = isUpper ? plain.toUpperCase() : plain;
  return word.replaceRange(index, index + 1, replacement);
}
