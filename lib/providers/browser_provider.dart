import 'package:flutter/material.dart';
import '../models/media_item.dart';
import '../services/youtube_service.dart';

enum BrowserState { idle, loading, loaded, error }

class BrowserProvider extends ChangeNotifier {
  final YouTubeService _youtubeService = YouTubeService();

  List<MediaItem> _videos = [];
  String _selectedCategory = '';
  BrowserState _state = BrowserState.idle;

  List<MediaItem> get videos => _videos;
  String get selectedCategory => _selectedCategory;
  BrowserState get state => _state;

  void resetToDefault() {
    _state = BrowserState.idle;
    _selectedCategory = '';
    _videos = [];
    notifyListeners();
  }

  Future<void> fetchCategory(String category) async {
    _selectedCategory = category;
    _state = BrowserState.loading;
    notifyListeners();

    try {
      if (category.startsWith('Search: ')) {
        final query = category.substring(8).replaceAll('"', '');
        _videos = await _youtubeService.searchVideos(query);
      } else {
        switch (category) {
          case 'Amharic Gospel':
            _videos = await _youtubeService.fetchAmharicGospel();
            break;
          case 'Afaan Oromo Gospel':
            _videos = await _youtubeService.fetchOromoGospel();
            break;
          case 'English Gospel':
            _videos = await _youtubeService.fetchEnglishGospel();
            break;
          default:
            _videos = [];
        }
      }
      _state = BrowserState.loaded;
    } catch (e) {
      debugPrint('Error fetching category: $e');
      _videos = [];
      _state = BrowserState.error;
    } finally {
      notifyListeners();
    }
  }

  Future<void> search(String query) async {
    _selectedCategory = 'Search: "$query"';
    _state = BrowserState.loading;
    notifyListeners();
    try {
      _videos = await _youtubeService.searchVideos(query);
      _state = BrowserState.loaded;
    } catch (e) {
      debugPrint('Error searching: $e');
      _state = BrowserState.error;
    } finally {
      notifyListeners();
    }
  }
}
