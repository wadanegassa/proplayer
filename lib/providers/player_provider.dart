import 'package:flutter/material.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:just_audio/just_audio.dart';

class PlayerProvider extends ChangeNotifier {
  final AudioPlayer _audioPlayer = AudioPlayer();
  AssetEntity? _currentSong;
  bool _isPlaying = false;

  AssetEntity? get currentSong => _currentSong;
  bool get isPlaying => _isPlaying;

  Future<void> playSong(AssetEntity song) async {
    _currentSong = song;
    final file = await song.file;
    if (file != null) {
      await _audioPlayer.setFilePath(file.path);
      _audioPlayer.play();
      _isPlaying = true;
      notifyListeners();
    }
  }

  void togglePlayPause() {
    if (_isPlaying) {
      _audioPlayer.pause();
    } else {
      _audioPlayer.play();
    }
    _isPlaying = !_isPlaying;
    notifyListeners();
  }

  void stop() {
    _audioPlayer.stop();
    _isPlaying = false;
    notifyListeners();
  }
}
