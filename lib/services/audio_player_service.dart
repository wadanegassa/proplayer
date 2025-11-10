import 'package:just_audio/just_audio.dart';
import 'package:photo_manager/photo_manager.dart';
import 'dart:developer';

class AudioPlayerService {
  final AudioPlayer _player = AudioPlayer();
  AudioPlayer get player => _player;

  AssetEntity? currentSong;
  int currentIndex = 0;
  List<AssetEntity> playlist = [];

  /// Set playlist and start playing at startIndex
  Future<void> setPlaylist(List<AssetEntity> songs, {int startIndex = 0}) async {
    if (songs.isEmpty) return;

    playlist = songs;
    currentIndex = startIndex.clamp(0, songs.length - 1);

    await playCurrentSong();
  }

  /// Play the current song
  Future<void> playCurrentSong() async {
    if (playlist.isEmpty) return;

    currentSong = playlist[currentIndex];

    try {
      final file = await currentSong!.file;
      if (file == null) {
        log("File is null for ${currentSong!.title}");
        return;
      }

      await _player.setFilePath(file.path);
      await _player.play();
    } catch (e) {
      log("Error playing song: $e");
    }
  }

  /// Toggle play/pause
  Future<void> togglePlayPause() async {
    try {
      if (_player.playing) {
        await _player.pause();
      } else {
        await _player.play();
      }
    } catch (e) {
      log("Error toggling play/pause: $e");
    }
  }

  /// Play next song
  Future<void> nextSong() async {
    if (playlist.isEmpty) return;

    currentIndex = (currentIndex + 1) % playlist.length;
    await playCurrentSong();
  }

  /// Play previous song
  Future<void> previousSong() async {
    if (playlist.isEmpty) return;

    currentIndex = (currentIndex - 1 + playlist.length) % playlist.length;
    await playCurrentSong();
  }

  /// Dispose player
  void dispose() {
    _player.dispose();
  }
}
