import 'package:flutter/foundation.dart';
import '../models/media_item.dart';
import '../services/local_media_service.dart';

class LibraryProvider with ChangeNotifier {
  final LocalMediaService _localMediaService = LocalMediaService();

  List<MediaItem> _audioFiles = [];
  List<MediaItem> _videoFiles = [];
  bool _isScanning = false;
  String? _error;

  List<MediaItem> get audioFiles => _audioFiles;
  List<MediaItem> get videoFiles => _videoFiles;
  bool get isScanning => _isScanning;
  String? get error => _error;

  Future<void> scanMedia() async {
    _isScanning = true;
    _error = null;
    notifyListeners();

    try {
      debugPrint('🔍 Starting media scan...');
      
      // Scan audio and video files
      _audioFiles = await _localMediaService.scanLocalMusic();
      _videoFiles = await _localMediaService.scanLocalVideos();
      
      debugPrint('✅ Scan complete: ${_audioFiles.length} audio, ${_videoFiles.length} video');
      
      if (_audioFiles.isEmpty && _videoFiles.isEmpty) {
        _error = 'No media files found. Make sure you have granted storage permission.';
      }
    } catch (e) {
      debugPrint('❌ Error scanning media: $e');
      _error = 'Failed to scan media: $e';
    } finally {
      _isScanning = false;
      notifyListeners();
    }
  }

  Future<void> refreshMedia() async {
    await scanMedia();
  }
}
