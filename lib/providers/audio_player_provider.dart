import 'dart:async';

import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:just_audio_background/just_audio_background.dart' as bg;
import '../models/media_item.dart';

/// Repeat: off (stop at end), all (loop queue), one (loop current track).
enum PlayerRepeatMode { off, all, one }

class AudioPlayerProvider extends ChangeNotifier {
  static final AudioPlayerProvider _instance = AudioPlayerProvider._internal();
  factory AudioPlayerProvider() => _instance;
  AudioPlayerProvider._internal();

  final AudioPlayer _audioPlayer = AudioPlayer();

  MediaItem? _currentTrack;
  List<MediaItem> _playlist = [];
  List<int> _playOrder = [];
  int _playOrderPos = 0;
  bool _shuffleEnabled = false;
  PlayerRepeatMode _repeatMode = PlayerRepeatMode.off;

  bool _isPlaying = false;
  Duration _duration = Duration.zero;
  Duration _position = Duration.zero;
  bool _isMinimized = true;

  MediaItem? get currentTrack => _currentTrack;
  List<MediaItem> get playlist => _playlist;
  int get currentIndex =>
      _playOrder.isEmpty ? 0 : _playOrder[_playOrderPos.clamp(0, _playOrder.length - 1)];
  bool get isPlaying => _isPlaying;
  Duration get duration => _duration;
  Duration get position => _position;
  bool get isMinimized => _isMinimized;
  AudioPlayer get audioPlayer => _audioPlayer;
  bool get shuffleEnabled => _shuffleEnabled;
  PlayerRepeatMode get repeatMode => _repeatMode;

  bool get canPlayNext {
    if (_playlist.isEmpty) return false;
    if (_playlist.length == 1) return _repeatMode == PlayerRepeatMode.all;
    if (_playOrderPos < _playOrder.length - 1) return true;
    return _repeatMode == PlayerRepeatMode.all;
  }

  bool get canPlayPrevious {
    if (_playlist.isEmpty) return false;
    if (_playlist.length == 1) return _repeatMode == PlayerRepeatMode.all;
    if (_playOrderPos > 0) return true;
    return _repeatMode == PlayerRepeatMode.all;
  }

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

      if (state.processingState == ProcessingState.completed) {
        if (_repeatMode == PlayerRepeatMode.one) return;
        scheduleMicrotask(() => _onTrackCompleted());
      }
    });
  }

  void _rebuildPlayOrder({required bool shuffleOn}) {
    final n = _playlist.length;
    if (n == 0) {
      _playOrder = [];
      _playOrderPos = 0;
      return;
    }
    if (shuffleOn) {
      final idx = List<int>.generate(n, (i) => i)..shuffle();
      final anchor =
          _currentTrack != null ? _playlist.indexOf(_currentTrack!) : 0;
      final cur = anchor < 0 ? 0 : anchor.clamp(0, n - 1);
      idx.remove(cur);
      idx.insert(0, cur);
      _playOrder = idx;
      _playOrderPos = 0;
    } else {
      _playOrder = List<int>.generate(n, (i) => i);
      _playOrderPos = _playlist.isEmpty
          ? 0
          : _currentTrack == null
              ? 0
              : _playlist.indexOf(_currentTrack!).clamp(0, n - 1);
      if (_playOrderPos < 0 || _playOrderPos >= _playOrder.length) {
        _playOrderPos = 0;
      }
    }
  }

  Future<void> _applyLoopMode() async {
    try {
      if (_repeatMode == PlayerRepeatMode.one) {
        await _audioPlayer.setLoopMode(LoopMode.one);
      } else {
        await _audioPlayer.setLoopMode(LoopMode.off);
      }
    } catch (e) {
      debugPrint('setLoopMode: $e');
    }
  }

  Future<void> _loadAndPlayCurrent() async {
    final track = _currentTrack;
    if (track == null) return;
    try {
      await _audioPlayer.setAudioSource(
        AudioSource.uri(
          Uri.file(track.id),
          tag: bg.MediaItem(
            id: track.id,
            title: track.title,
            artist: track.subtitle,
          ),
        ),
      );
      await _audioPlayer.play();
      notifyListeners();
    } catch (e) {
      debugPrint('Error playing track: $e');
    }
  }

  Future<void> _onTrackCompleted() async {
    if (_playlist.isEmpty) return;
    final n = _playlist.length;
    if (n == 1) {
      if (_repeatMode == PlayerRepeatMode.all) {
        try {
          await _audioPlayer.seek(Duration.zero);
          await _audioPlayer.play();
        } catch (e) {
          debugPrint('Replay single: $e');
        }
      }
      return;
    }
    if (_playOrderPos < _playOrder.length - 1) {
      _playOrderPos++;
    } else if (_repeatMode == PlayerRepeatMode.all) {
      _playOrderPos = 0;
    } else {
      return;
    }
    _currentIndexFromOrder();
    await _loadAndPlayCurrent();
  }

  void _currentIndexFromOrder() {
    if (_playOrder.isEmpty) return;
    final i = _playOrder[_playOrderPos.clamp(0, _playOrder.length - 1)];
    _currentTrack = _playlist[i];
  }

  Future<void> playTrack(MediaItem track, List<MediaItem> playlist) async {
    _currentTrack = track;
    _playlist = List<MediaItem>.from(playlist);
    if (_playlist.isEmpty) return;

    _rebuildPlayOrder(shuffleOn: _shuffleEnabled);
    _currentIndexFromOrder();

    _isMinimized = true;
    await _applyLoopMode();
    await _loadAndPlayCurrent();
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

  void toggleShuffle() {
    if (_playlist.isEmpty) return;
    _shuffleEnabled = !_shuffleEnabled;
    _rebuildPlayOrder(shuffleOn: _shuffleEnabled);
    notifyListeners();
  }

  void cycleRepeatMode() {
    switch (_repeatMode) {
      case PlayerRepeatMode.off:
        _repeatMode = PlayerRepeatMode.all;
        break;
      case PlayerRepeatMode.all:
        _repeatMode = PlayerRepeatMode.one;
        break;
      case PlayerRepeatMode.one:
        _repeatMode = PlayerRepeatMode.off;
        break;
    }
    notifyListeners();
    unawaited(_applyLoopMode());
  }

  Future<void> playNext() async {
    if (_playlist.isEmpty) return;
    final n = _playlist.length;
    if (n == 1) {
      if (_repeatMode == PlayerRepeatMode.all) {
        try {
          await _audioPlayer.seek(Duration.zero);
          await _audioPlayer.play();
        } catch (e) {
          debugPrint('playNext single: $e');
        }
      }
      return;
    }
    if (_playOrderPos < _playOrder.length - 1) {
      _playOrderPos++;
    } else if (_repeatMode == PlayerRepeatMode.all) {
      _playOrderPos = 0;
    } else {
      return;
    }
    _currentIndexFromOrder();
    await _applyLoopMode();
    await _loadAndPlayCurrent();
  }

  Future<void> playPrevious() async {
    if (_playlist.isEmpty) return;
    final n = _playlist.length;
    if (n == 1) {
      if (_repeatMode == PlayerRepeatMode.all) {
        try {
          await _audioPlayer.seek(Duration.zero);
          await _audioPlayer.play();
        } catch (e) {
          debugPrint('playPrevious single: $e');
        }
      }
      return;
    }
    if (_playOrderPos > 0) {
      _playOrderPos--;
    } else if (_repeatMode == PlayerRepeatMode.all) {
      _playOrderPos = _playOrder.length - 1;
    } else {
      return;
    }
    _currentIndexFromOrder();
    await _applyLoopMode();
    await _loadAndPlayCurrent();
  }

  void setMinimized(bool minimized) {
    _isMinimized = minimized;
    notifyListeners();
  }

  Future<void> stop() async {
    await _audioPlayer.stop();
    try {
      await _audioPlayer.setLoopMode(LoopMode.off);
    } catch (_) {}
    _currentTrack = null;
    _playlist = [];
    _playOrder = [];
    _playOrderPos = 0;
    notifyListeners();
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }
}
