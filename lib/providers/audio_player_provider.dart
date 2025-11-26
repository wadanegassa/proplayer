import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import '../models/media_item.dart';

class AudioPlayerProvider extends ChangeNotifier {
  static final AudioPlayerProvider _instance = AudioPlayerProvider._internal();
  factory AudioPlayerProvider() => _instance;
  AudioPlayerProvider._internal();

  final AudioPlayer _audioPlayer = AudioPlayer();
  
  MediaItem? _currentTrack;
  List<MediaItem> _playlist = [];
  int _currentIndex = 0;
  bool _isPlaying = false;
  Duration _duration = Duration.zero;
  Duration _position = Duration.zero;
  bool _isMinimized = true;

  MediaItem? get currentTrack => _currentTrack;
  List<MediaItem> get playlist => _playlist;
  int get currentIndex => _currentIndex;
  bool get isPlaying => _isPlaying;
  Duration get duration => _duration;
  Duration get position => _position;
  bool get isMinimized => _isMinimized;
  AudioPlayer get audioPlayer => _audioPlayer;

  void initialize() {
    _audioPlayer.durationStream.listen((duration) {
      _duration = duration ?? Duration.zero;
      notifyListeners();
    });

    _audioPlayer.positionStream.listen((position) {
      _position = position;
      notifyListeners();
    });

    _audioPlayer.playerStateStream.listen((state) {
      _isPlaying = state.playing;
      notifyListeners();
      
      // Auto-play next when current track completes
      if (state.processingState == ProcessingState.completed) {
        playNext();
      }
    });
  }

  Future<void> playTrack(MediaItem track, List<MediaItem> playlist) async {
    _currentTrack = track;
    _playlist = playlist;
    _currentIndex = playlist.indexOf(track);
    _isMinimized = true;

    try {
      await _audioPlayer.setFilePath(track.id);
      await _audioPlayer.play();
      notifyListeners();
    } catch (e) {
      debugPrint('Error playing track: $e');
    }
  }

  Future<void> play() async {
    await _audioPlayer.play();
  }

  Future<void> pause() async {
    await _audioPlayer.pause();
  }

  Future<void> seek(Duration position) async {
    await _audioPlayer.seek(position);
  }

  Future<void> playNext() async {
    if (_currentIndex < _playlist.length - 1) {
      _currentIndex++;
      _currentTrack = _playlist[_currentIndex];
      await _audioPlayer.setFilePath(_currentTrack!.id);
      await _audioPlayer.play();
      notifyListeners();
    }
  }

  Future<void> playPrevious() async {
    if (_currentIndex > 0) {
      _currentIndex--;
      _currentTrack = _playlist[_currentIndex];
      await _audioPlayer.setFilePath(_currentTrack!.id);
      await _audioPlayer.play();
      notifyListeners();
    }
  }

  void setMinimized(bool minimized) {
    _isMinimized = minimized;
    notifyListeners();
  }

  Future<void> stop() async {
    await _audioPlayer.stop();
    _currentTrack = null;
    _playlist = [];
    _currentIndex = 0;
    notifyListeners();
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }
}
