import 'package:flutter_test/flutter_test.dart';
import 'package:menuario/src/shared/data/models/video_link_dto.dart';
import 'package:menuario/src/shared/domain/value_objects/video_link.dart';
import 'package:menuario/src/shared/domain/value_objects/video_source.dart';

void main() {
  group('VideoLinkDTO round-trip', () {
    test('survives fromEntity->toJson->fromJson->toEntity', () {
      // Arrange
      const entity = VideoLink(
        source: VideoSource.youtube,
        url: 'https://youtu.be/abc',
      );

      // Act
      final json = VideoLinkDTO.fromEntity(entity).toJson();
      final result = VideoLinkDTO.fromJson(json).toEntity();

      // Assert
      expect(result, entity);
      expect(json['source'], 'youtube');
      expect(json['url'], 'https://youtu.be/abc');
    });

    test('a tiktok video round-trips exactly', () {
      // Arrange
      const entity = VideoLink(
        source: VideoSource.tiktok,
        url: 'https://tiktok.com/@x/video/1',
      );

      // Act
      final json = VideoLinkDTO.fromEntity(entity).toJson();
      final result = VideoLinkDTO.fromJson(json).toEntity();

      // Assert
      expect(result, entity);
    });

    test('an unknown source wire value degrades to otro on toEntity', () {
      // Arrange
      const dto = VideoLinkDTO(source: 'bogus', url: 'https://example.com');

      // Act
      final result = dto.toEntity();

      // Assert
      expect(result.source, VideoSource.otro);
      expect(result.url, 'https://example.com');
    });
  });
}
