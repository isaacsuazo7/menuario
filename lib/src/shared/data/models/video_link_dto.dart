import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:menuario/src/shared/domain/value_objects/video_link.dart';
import 'package:menuario/src/shared/domain/value_objects/video_source.dart';

part 'video_link_dto.freezed.dart';
part 'video_link_dto.g.dart';

/// JSON representation of a [VideoLink], nested inside `RecipeDTO.videos`.
@freezed
abstract class VideoLinkDTO with _$VideoLinkDTO {
  const factory VideoLinkDTO({required String source, required String url}) =
      _VideoLinkDTO;

  const VideoLinkDTO._();

  factory VideoLinkDTO.fromJson(Map<String, dynamic> json) =>
      _$VideoLinkDTOFromJson(json);

  /// Builds a [VideoLinkDTO] from a [VideoLink] entity.
  static VideoLinkDTO fromEntity(VideoLink entity) {
    return VideoLinkDTO(source: entity.source.wire, url: entity.url);
  }
}

/// Bidirectional mapper: [VideoLinkDTO] -> [VideoLink].
extension VideoLinkDTOX on VideoLinkDTO {
  /// Rebuilds the [VideoLink] entity carried by this DTO. An unrecognized
  /// or missing [source] degrades to [VideoSource.otro] via
  /// [VideoSource.fromWire] — the url stays usable either way.
  VideoLink toEntity() {
    return VideoLink(source: VideoSource.fromWire(source), url: url);
  }
}
