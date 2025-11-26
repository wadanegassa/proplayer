import 'package:photo_manager/photo_manager.dart';
import '../models/media_item.dart';
import 'package:flutter/foundation.dart';

class LocalMediaService {
  Future<List<MediaItem>> scanLocalMusic() async {
    try {
      // Request permissions
      final PermissionState ps = await PhotoManager.requestPermissionExtend();
      debugPrint('📱 Permission state: ${ps.name}');
      
      if (!ps.isAuth) {
        debugPrint('❌ Storage permission not granted');
        return [];
      }

      // Get all audio paths/albums
      final List<AssetPathEntity> albums = await PhotoManager.getAssetPathList(
        type: RequestType.audio,
      );
      
      debugPrint('📁 Found ${albums.length} audio albums/paths');

      if (albums.isEmpty) {
        debugPrint('❌ No audio albums found');
        return [];
      }

      List<MediaItem> items = [];
      
      // Scan through all albums to get more songs
      for (var album in albums) {
        final count = await album.assetCountAsync;
        debugPrint('📂 Album: ${album.name}, Count: $count');
        
        // Get all audios from this album
        final List<AssetEntity> audios = await album.getAssetListRange(
          start: 0,
          end: count, // Get all files
        );
        
        debugPrint('🎵 Processing ${audios.length} audio files from ${album.name}');

        for (var asset in audios) {
          try {
            final file = await asset.file;
            if (file != null) {
              // NOTE: photo_manager doesn't support thumbnails for audio files
              // We skip thumbnail fetching to avoid errors
              items.add(MediaItem(
                id: file.path,
                title: asset.title ?? file.path.split('/').last.replaceAll('.mp3', '').replaceAll('.m4a', ''),
                subtitle: 'Local Audio',
                duration: _formatDuration(asset.duration),
                isVideo: false,
                isLocal: true,
                thumbnailBytes: null, // No thumbnails for audio
              ));
            }
          } catch (e) {
            debugPrint('⚠️ Error processing audio asset: $e');
          }
        }
      }

      debugPrint('✅ Successfully scanned ${items.length} audio files');
      return items;
    } catch (e) {
      debugPrint('❌ Error scanning audio files: $e');
      return [];
    }
  }

  Future<List<MediaItem>> scanLocalVideos() async {
    try {
      final PermissionState ps = await PhotoManager.requestPermissionExtend();
      
      if (!ps.isAuth) {
        debugPrint('❌ Storage permission not granted for videos');
        return [];
      }

      final List<AssetPathEntity> albums = await PhotoManager.getAssetPathList(
        type: RequestType.video,
      );
      
      debugPrint('📁 Found ${albums.length} video albums/paths');

      if (albums.isEmpty) return [];

      List<MediaItem> items = [];
      
      for (var album in albums) {
        final count = await album.assetCountAsync;
        final List<AssetEntity> videos = await album.getAssetListRange(
          start: 0,
          end: count,
        );

        for (var asset in videos) {
          try {
            final file = await asset.file;
            if (file != null) {
              items.add(MediaItem(
                id: file.path,
                title: asset.title ?? file.path.split('/').last,
                subtitle: 'Local Video',
                duration: _formatDuration(asset.duration),
                isVideo: true,
                isLocal: true,
                thumbnailBytes: await asset.thumbnailDataWithSize(
                  const ThumbnailSize(200, 200),
                ),
              ));
            }
          } catch (e) {
            debugPrint('⚠️ Error processing video asset: $e');
          }
        }
      }

      debugPrint('✅ Successfully scanned ${items.length} video files');
      return items;
    } catch (e) {
      debugPrint('❌ Error scanning video files: $e');
      return [];
    }
  }

  String _formatDuration(int seconds) {
    final duration = Duration(seconds: seconds);
    final minutes = duration.inMinutes;
    final remainingSeconds = duration.inSeconds % 60;
    return '$minutes:${remainingSeconds.toString().padLeft(2, '0')}';
  }
}
