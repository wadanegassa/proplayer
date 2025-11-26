import 'package:flutter/material.dart';
import '../models/media_item.dart';

class PlayerProvider extends ChangeNotifier {
  MediaItem? _currentMedia;
  bool _isPlaying = false;

  MediaItem? get currentMedia => _currentMedia;
  bool get isPlaying => _isPlaying;

  void play(MediaItem media) {
    _currentMedia = media;
    _isPlaying = true;
    notifyListeners();
  }

  void pause() {
    _isPlaying = false;
    notifyListeners();
  }

  void stop() {
    _currentMedia = null;
    _isPlaying = false;
    notifyListeners();
  }
}
