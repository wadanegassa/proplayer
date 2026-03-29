import 'package:photo_manager/photo_manager.dart';
import '../models/local_audio_scan_result.dart';
import '../models/local_video_scan_result.dart';
import '../models/media_album.dart';
import '../models/media_item.dart';
import 'package:flutter/foundation.dart';

class LocalMediaService {
  /// Albums plus flat list (same ordering as legacy scan: all tracks from all paths).
  Future<LocalAudioScanResult> scanLocalAudioDetailed() async {
    try {
      final PermissionState ps = await PhotoManager.requestPermissionExtend();
      debugPrint('📱 Permission state: ${ps.name}');

      if (!ps.isAuth) {
        debugPrint('❌ Storage permission not granted');
        return const LocalAudioScanResult(albums: [], items: []);
      }

      final List<AssetPathEntity> paths = await PhotoManager.getAssetPathList(
        type: RequestType.audio,
      );

      debugPrint('📁 Found ${paths.length} audio albums/paths');

      if (paths.isEmpty) {
        debugPrint('❌ No audio albums found');
        return const LocalAudioScanResult(albums: [], items: []);
      }

      final List<MediaAlbum> albums = [];
      final List<MediaItem> flat = [];

      for (var path in paths) {
        final count = await path.assetCountAsync;
        debugPrint('📂 Album: ${path.name}, Count: $count');

        final List<AssetEntity> audios = await path.getAssetListRange(
          start: 0,
          end: count,
        );

        debugPrint('🎵 Processing ${audios.length} audio files from ${path.name}');

        final albumItems = <MediaItem>[];
        for (var asset in audios) {
          try {
            final file = await asset.file;
            if (file != null) {
              final item = MediaItem(
                id: file.path,
                title: asset.title ??
                    file.path.split('/').last.replaceAll('.mp3', '').replaceAll('.m4a', ''),
                subtitle: 'Local Audio',
                duration: _formatDuration(asset.duration),
                isVideo: false,
                isLocal: true,
                thumbnailBytes: null,
              );
              albumItems.add(item);
              flat.add(item);
            }
          } catch (e) {
            debugPrint('⚠️ Error processing audio asset: $e');
          }
        }
        if (albumItems.isNotEmpty) {
          albums.add(MediaAlbum(title: path.name, items: albumItems));
        }
      }

      debugPrint('✅ Successfully scanned ${flat.length} audio files in ${albums.length} folders');
      return LocalAudioScanResult(albums: albums, items: flat);
    } catch (e) {
      debugPrint('❌ Error scanning audio files: $e');
      return const LocalAudioScanResult(albums: [], items: []);
    }
  }

  Future<List<MediaItem>> scanLocalMusic() async {
    final r = await scanLocalAudioDetailed();
    return r.items;
  }

  /// Video albums (folders) plus flat list, same pattern as audio.
  Future<LocalVideoScanResult> scanLocalVideoDetailed() async {
    try {
      final PermissionState ps = await PhotoManager.requestPermissionExtend();

      if (!ps.isAuth) {
        debugPrint('❌ Storage permission not granted for videos');
        return const LocalVideoScanResult(albums: [], items: []);
      }

      final List<AssetPathEntity> paths = await PhotoManager.getAssetPathList(
        type: RequestType.video,
      );

      debugPrint('📁 Found ${paths.length} video albums/paths');

      if (paths.isEmpty) {
        return const LocalVideoScanResult(albums: [], items: []);
      }

      final List<MediaAlbum> albums = [];
      final List<MediaItem> flat = [];

      for (var path in paths) {
        final count = await path.assetCountAsync;
        final List<AssetEntity> videos = await path.getAssetListRange(
          start: 0,
          end: count,
        );

        final albumItems = <MediaItem>[];
        for (var asset in videos) {
          try {
            final file = await asset.file;
            if (file != null) {
              final item = MediaItem(
                id: file.path,
                title: asset.title ?? file.path.split('/').last,
                subtitle: 'Local Video',
                duration: _formatDuration(asset.duration),
                isVideo: true,
                isLocal: true,
                thumbnailBytes: await asset.thumbnailDataWithSize(
                  const ThumbnailSize(200, 200),
                ),
              );
              albumItems.add(item);
              flat.add(item);
            }
          } catch (e) {
            debugPrint('⚠️ Error processing video asset: $e');
          }
        }
        if (albumItems.isNotEmpty) {
          albums.add(MediaAlbum(title: path.name, items: albumItems));
        }
      }

      debugPrint('✅ Successfully scanned ${flat.length} videos in ${albums.length} folders');
      return LocalVideoScanResult(albums: albums, items: flat);
    } catch (e) {
      debugPrint('❌ Error scanning video files: $e');
      return const LocalVideoScanResult(albums: [], items: []);
    }
  }

  Future<List<MediaItem>> scanLocalVideos() async {
    final r = await scanLocalVideoDetailed();
    return r.items;
  }

  String _formatDuration(int seconds) {
    final duration = Duration(seconds: seconds);
    final minutes = duration.inMinutes;
    final remainingSeconds = duration.inSeconds % 60;
    return '$minutes:${remainingSeconds.toString().padLeft(2, '0')}';
  }
}
