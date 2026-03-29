import 'media_item.dart';

/// A local grouping (e.g. photo_manager audio album / folder name).
class MediaAlbum {
  const MediaAlbum({required this.title, required this.items});

  final String title;
  final List<MediaItem> items;
}
