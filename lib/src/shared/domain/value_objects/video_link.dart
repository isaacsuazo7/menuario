import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:menuario/src/shared/domain/value_objects/video_source.dart';

part 'video_link.freezed.dart';

/// A single video reference attached to a [Recipe]: which platform it is
/// on and its url.
@freezed
abstract class VideoLink with _$VideoLink {
  const factory VideoLink({required VideoSource source, required String url}) =
      _VideoLink;
}
