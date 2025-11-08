import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import '../models/media_model.dart';

class PlayerProvider extends ChangeNotifier {
  final _player = AudioPlayer();
  MediaModel? _currentTrack;
  bool _isPlaying = false;

  MediaModel? get currentTrack => _currentTrack;
  bool get isPlaying => _isPlaying;

  Future<void> play(MediaModel media) async {
    try {
      _currentTrack = media;
      await _player.setAudioSource(AudioSource.uri(Uri.parse(media.path!)));
      await _player.play();
      _isPlaying = true;
      notifyListeners();
    } catch (e) {
      debugPrint('Error playing: $e');
    }
  }

  void pause() async {
    await _player.pause();
    _isPlaying = false;
    notifyListeners();
  }

  void resume() async {
    await _player.play();
    _isPlaying = true;
    notifyListeners();
  }

  void stop() async {
    await _player.stop();
    _isPlaying = false;
    notifyListeners();
  }
}
