import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import '../models/media_item.dart';
import '../services/history_service.dart';
import '../services/youtube_service.dart';
import '../services/local_media_service.dart';

class HomeProvider with ChangeNotifier {
  final HistoryService _historyService = HistoryService();
  final YouTubeService _youtubeService = YouTubeService();
  final LocalMediaService _localMediaService = LocalMediaService();

  List<MediaItem> _recentlyPlayed = [];
  List<MediaItem> _randomMix = [];
  List<MediaItem> _localSongs = [];
  bool _isLoading = false;

  List<MediaItem> get recentlyPlayed => _recentlyPlayed;
  List<MediaItem> get randomMix => _randomMix;
  List<MediaItem> get localSongs => _localSongs;
  bool get isLoading => _isLoading;

  Future<void> loadHomeData() async {
    _isLoading = true;
    notifyListeners();

    try {
      // Load history
      _recentlyPlayed = await _historyService.getRecentList();

      // Load random mix if empty
      if (_randomMix.isEmpty) {
        _randomMix = await _youtubeService.fetchRandomMix();
      }

      // Load local songs
      if (_localSongs.isEmpty) {
        // Request permission first (assuming permission is handled in main.dart or splash)
        // For now, just try to fetch
        _localSongs = await _localMediaService.scanLocalMusic();
      }

    } catch (e) {
      debugPrint('Error loading home data: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addToHistory(MediaItem item) async {
    await _historyService.addToRecent(item);
    _recentlyPlayed = await _historyService.getRecentList();
    notifyListeners();
  }
}
