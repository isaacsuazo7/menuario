import 'package:flutter_test/flutter_test.dart';
import 'package:menuario/src/shared/domain/value_objects/video_link.dart';
import 'package:menuario/src/shared/domain/value_objects/video_source.dart';

void main() {
  group('VideoLink', () {
    test('should carry a source and a url', () {
      // Arrange & Act
      const link = VideoLink(
        source: VideoSource.youtube,
        url: 'https://youtu.be/abc',
      );

      // Assert
      expect(link.source, VideoSource.youtube);
      expect(link.url, 'https://youtu.be/abc');
    });

    test('should be equal to another instance with the same fields', () {
      // Arrange
      const first = VideoLink(
        source: VideoSource.tiktok,
        url: 'https://tiktok.com/@x/video/1',
      );
      const second = VideoLink(
        source: VideoSource.tiktok,
        url: 'https://tiktok.com/@x/video/1',
      );

      // Assert
      expect(first, second);
      expect(first.hashCode, second.hashCode);
    });

    test('should not expose a mutator: copyWith produces a new immutable '
        'instance without altering the original', () {
      // Arrange
      const original = VideoLink(
        source: VideoSource.youtube,
        url: 'https://youtu.be/abc',
      );

      // Act
      final replaced = original.copyWith(url: 'https://youtu.be/xyz');

      // Assert
      expect(original.url, 'https://youtu.be/abc');
      expect(replaced.url, 'https://youtu.be/xyz');
      expect(replaced.source, VideoSource.youtube);
      expect(identical(original, replaced), isFalse);
    });
  });
}
