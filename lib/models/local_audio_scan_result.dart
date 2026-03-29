import 'media_album.dart';
import 'media_item.dart';

class LocalAudioScanResult {
  const LocalAudioScanResult({required this.albums, required this.items});

  final List<MediaAlbum> albums;
  final List<MediaItem> items;
}
