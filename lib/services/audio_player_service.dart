import 'package:just_audio/just_audio.dart';
import 'package:photo_manager/photo_manager.dart';

class AudioPlayerService {
  final AudioPlayer _player = AudioPlayer();
  AudioPlayer get player => _player;

  AssetEntity? currentSong;
  int currentIndex = 0;
  List<AssetEntity> playlist = [];

  Future<void> setPlaylist(List<AssetEntity> songs, {int startIndex = 0}) async {
    playlist = songs;
    currentIndex = startIndex;
    await playCurrentSong();
  }

  Future<void> playCurrentSong() async {
    if (playlist.isEmpty) return;
    currentSong = playlist[currentIndex];
    final file = await currentSong!.file;
    if (file == null) return;
    await _player.setFilePath(file.path);
    await _player.play();
  }

  Future<void> playSongAtIndex(int index) async {
    currentIndex = index;
    await playCurrentSong();
  }

  Future<void> togglePlayPause() async {
    if (_player.playing) {
      await _player.pause();
    } else {
      await _player.play();
    }
  }

  Future<void> nextSong() async {
    if (playlist.isEmpty) return;
    currentIndex = (currentIndex + 1) % playlist.length;
    await playCurrentSong();
  }

  Future<void> previousSong() async {
    if (playlist.isEmpty) return;
    currentIndex = (currentIndex - 1 + playlist.length) % playlist.length;
    await playCurrentSong();
  }

  void dispose() => _player.dispose();
}
