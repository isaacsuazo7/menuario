/// The platform a [VideoLink] points to.
///
/// `otro` is both an explicit choice (any platform not in the curated
/// list) and the safe default for [fromWire] when a persisted value is
/// missing or unrecognized — the url itself stays usable either way.
enum VideoSource {
  youtube,
  tiktok,
  otro;

  /// The display label used across the UI.
  String get label => switch (this) {
    VideoSource.youtube => 'YouTube',
    VideoSource.tiktok => 'TikTok',
    VideoSource.otro => 'Otro',
  };

  /// The lowercase string persisted at the data layer.
  String get wire => name;

  /// Maps a persisted wire string back to a [VideoSource].
  ///
  /// Returns [VideoSource.otro] for `null` or any unrecognized value —
  /// unlike [MealType.fromWire], there is no meaningful "no source" state
  /// for a video row, so it degrades to the catch-all instead of null.
  static VideoSource fromWire(String? wire) {
    for (final value in VideoSource.values) {
      if (value.wire == wire) return value;
    }
    return VideoSource.otro;
  }
}
