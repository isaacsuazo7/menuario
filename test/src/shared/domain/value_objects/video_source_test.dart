import 'package:flutter_test/flutter_test.dart';
import 'package:menuario/src/shared/domain/value_objects/video_source.dart';

void main() {
  group('VideoSource', () {
    test('should expose exactly the three recipe video sources', () {
      // Act & Assert
      expect(VideoSource.values, [
        VideoSource.youtube,
        VideoSource.tiktok,
        VideoSource.otro,
      ]);
    });

    group('label', () {
      test('should render the display label for each video source', () {
        // Act & Assert
        expect(VideoSource.youtube.label, 'YouTube');
        expect(VideoSource.tiktok.label, 'TikTok');
        expect(VideoSource.otro.label, 'Otro');
      });
    });

    group('wire', () {
      test('should render the lowercase wire string for each video source', () {
        // Act & Assert
        expect(VideoSource.youtube.wire, 'youtube');
        expect(VideoSource.tiktok.wire, 'tiktok');
        expect(VideoSource.otro.wire, 'otro');
      });
    });

    group('fromWire', () {
      test('should map every valid wire string to its video source', () {
        // Act & Assert
        expect(VideoSource.fromWire('youtube'), VideoSource.youtube);
        expect(VideoSource.fromWire('tiktok'), VideoSource.tiktok);
        expect(VideoSource.fromWire('otro'), VideoSource.otro);
      });

      test('should default to otro for an unknown wire string', () {
        // Act & Assert
        expect(VideoSource.fromWire('desconocido'), VideoSource.otro);
      });

      test('should default to otro for a null wire string', () {
        // Act & Assert
        expect(VideoSource.fromWire(null), VideoSource.otro);
      });
    });
  });
}
