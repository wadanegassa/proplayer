class MediaModel {
  final String id;
  final String title;
  final Duration duration;
  final String? path;
  final bool isVideo;

  MediaModel({
    required this.id,
    required this.title,
    required this.duration,
    this.path,
    this.isVideo = false,
  });
}
