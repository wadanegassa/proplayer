import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:photo_manager/photo_manager.dart';

import '../models/local_audio_scan_result.dart';
import '../models/local_video_scan_result.dart';
import '../models/media_album.dart';
import '../models/media_item.dart';

class LocalMediaService {
  /// Static: [HomeProvider] and [LibraryProvider] each construct their own service instance.
  static Future<void> _mutex = Future<void>.value();

  Future<T> _runExclusive<T>(Future<T> Function() op) async {
    final previous = _mutex;
    final completer = Completer<void>();
    _mutex = completer.future;
    try {
      await previous;
      return await op();
    } finally {
      completer.complete();
    }
  }

  void _log(String message) {
    if (kDebugMode) debugPrint(message);
  }

  /// Albums plus flat list (same ordering as legacy scan: all tracks from all paths).
  Future<LocalAudioScanResult> scanLocalAudioDetailed() async {
    return _runExclusive(() async {
    try {
      final PermissionState ps = await PhotoManager.requestPermissionExtend();
      _log('📱 Permission state: ${ps.name}');

      if (!ps.isAuth) {
        _log('❌ Storage permission not granted');
        return const LocalAudioScanResult(albums: [], items: []);
      }

      final List<AssetPathEntity> paths = await PhotoManager.getAssetPathList(
        type: RequestType.audio,
      );

      _log('📁 Found ${paths.length} audio albums/paths');

      if (paths.isEmpty) {
        _log('❌ No audio albums found');
        return const LocalAudioScanResult(albums: [], items: []);
      }

      final List<MediaAlbum> albums = [];
      final List<MediaItem> flat = [];

      for (var path in paths) {
        final count = await path.assetCountAsync;
        _log('📂 Album: ${path.name}, Count: $count');

        final List<AssetEntity> audios = await path.getAssetListRange(
          start: 0,
          end: count,
        );

        _log('🎵 Processing ${audios.length} audio files from ${path.name}');

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
            _log('⚠️ Error processing audio asset: $e');
          }
        }
        if (albumItems.isNotEmpty) {
          albums.add(MediaAlbum(title: path.name, items: albumItems));
        }
      }

      _log('✅ Successfully scanned ${flat.length} audio files in ${albums.length} folders');
      return LocalAudioScanResult(albums: albums, items: flat);
    } catch (e) {
      _log('❌ Error scanning audio files: $e');
      return const LocalAudioScanResult(albums: [], items: []);
    }
    });
  }

  Future<List<MediaItem>> scanLocalMusic() async {
    final r = await scanLocalAudioDetailed();
    return r.items;
  }

  /// Video albums (folders) plus flat list, same pattern as audio.
  Future<LocalVideoScanResult> scanLocalVideoDetailed() async {
    return _runExclusive(() async {
    try {
      final PermissionState ps = await PhotoManager.requestPermissionExtend();

      if (!ps.isAuth) {
        _log('❌ Storage permission not granted for videos');
        return const LocalVideoScanResult(albums: [], items: []);
      }

      final List<AssetPathEntity> paths = await PhotoManager.getAssetPathList(
        type: RequestType.video,
      );

      _log('📁 Found ${paths.length} video albums/paths');

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
            _log('⚠️ Error processing video asset: $e');
          }
        }
        if (albumItems.isNotEmpty) {
          albums.add(MediaAlbum(title: path.name, items: albumItems));
        }
      }

      _log('✅ Successfully scanned ${flat.length} videos in ${albums.length} folders');
      return LocalVideoScanResult(albums: albums, items: flat);
    } catch (e) {
      _log('❌ Error scanning video files: $e');
      return const LocalVideoScanResult(albums: [], items: []);
    }
    });
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
