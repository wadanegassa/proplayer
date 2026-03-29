import 'media_album.dart';
import 'media_item.dart';

/// Video paths grouped by photo_manager album, plus flat list.
class LocalVideoScanResult {
  const LocalVideoScanResult({required this.albums, required this.items});

  final List<MediaAlbum> albums;
  final List<MediaItem> items;
}
