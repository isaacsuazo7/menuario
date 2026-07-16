/// Derives short avatar initials from a user's identity.
///
/// Uses the first letter of the first two words of [displayName] (e.g.
/// "Isaac Suazo" → "IS", "Isaac" → "I"). When no usable name is present it
/// falls back to the first letter of [email], and finally to `?` so the
/// avatar never renders blank or "null". The result is always uppercased.
String userInitials({String? displayName, String? email}) {
  final name = displayName?.trim() ?? '';
  if (name.isNotEmpty) {
    final words = name.split(RegExp(r'\s+')).where((w) => w.isNotEmpty);
    final letters = words.take(2).map((w) => w[0]).join();
    return letters.toUpperCase();
  }

  final mail = email?.trim() ?? '';
  if (mail.isNotEmpty) {
    return mail[0].toUpperCase();
  }

  return '?';
}
