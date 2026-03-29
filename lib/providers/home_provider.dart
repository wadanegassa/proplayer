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
      _recentlyPlayed = await _historyService.getRecentList();

      if (_randomMix.isEmpty) {
        _randomMix = await _youtubeService.fetchRandomMix();
        if (_randomMix.isEmpty) {
          await Future<void>.delayed(const Duration(milliseconds: 600));
          _randomMix = await _youtubeService.fetchRandomMix();
        }
      }

      if (_localSongs.isEmpty) {
        _localSongs = await _localMediaService.scanLocalMusic();
      }
    } catch (e) {
      debugPrint('Error loading home data: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Pull-to-refresh: reload YouTube mix, local files, and history.
  Future<void> refreshHomeData() async {
    try {
      _recentlyPlayed = await _historyService.getRecentList();
      _randomMix = await _youtubeService.fetchRandomMix();
      if (_randomMix.isEmpty) {
        await Future<void>.delayed(const Duration(milliseconds: 600));
        _randomMix = await _youtubeService.fetchRandomMix();
      }
      _localSongs = await _localMediaService.scanLocalMusic();
    } catch (e) {
      debugPrint('Error refreshing home: $e');
    }
    notifyListeners();
  }

  Future<void> addToHistory(MediaItem item) async {
    await _historyService.addToRecent(item);
    _recentlyPlayed = await _historyService.getRecentList();
    notifyListeners();
  }
}
