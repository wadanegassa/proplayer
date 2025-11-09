import 'package:flutter/material.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:proplayer/screens/player_screen.dart';
import 'package:proplayer/widgets/mini_player_bar.dart';
import '../services/media_service.dart';
import '../services/audio_player_service.dart';
class MusicListScreen extends StatefulWidget {
  const MusicListScreen({super.key});

  @override
  State<MusicListScreen> createState() => _MusicListScreenState();
}

class _MusicListScreenState extends State<MusicListScreen> {
  final MediaService _mediaService = MediaService();
  final AudioPlayerService _audioService = AudioPlayerService();

  List<AssetEntity> _songs = [];
  bool _isLoading = true;
  bool _isMiniPlayerVisible = false;

  @override
  void initState() {
    super.initState();
    _loadSongs();
  }

  Future<void> _loadSongs() async {
    final songs = await _mediaService.loadMedia();
    setState(() {
      _songs = songs;
      _isLoading = false;
    });
  }

  Future<void> _onSongTap(int index) async {
    await _audioService.setPlaylist(_songs, startIndex: index);
    setState(() => _isMiniPlayerVisible = true);
  }

  void _openFullPlayer() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => PlayMusicScreen(audioService: _audioService),
    );
  }

  @override
  void dispose() {
    _audioService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      backgroundColor: const Color(0xFF0D0122),
      appBar: AppBar(
        title: const Text('🎶 Music Library'),
        backgroundColor: Colors.deepPurple.shade800,
        elevation: 0,
        centerTitle: true,
      ),
      body: Stack(
        children: [
          // Gradient background
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF1E053A), Color(0xFF0D0122)],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),

          // Song List
          _isLoading
              ? const Center(child: CircularProgressIndicator(color: Colors.deepPurpleAccent))
              : ListView.builder(
                  padding: const EdgeInsets.only(bottom: 120),
                  itemCount: _songs.length,
                  itemBuilder: (context, index) {
                    final song = _songs[index];
                    final isPlaying = _audioService.currentSong == song;

                    return InkWell(
                      onTap: () => _onSongTap(index),
                      child: Container(
                        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          gradient: isPlaying
                              ? LinearGradient(
                                  colors: [Colors.deepPurpleAccent.shade200, Colors.deepPurple.shade900],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                )
                              : LinearGradient(
                                  colors: [Colors.deepPurple.shade900.withOpacity(0.4), Colors.deepPurple.shade800.withOpacity(0.4)],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: isPlaying
                              ? [
                                  BoxShadow(
                                    color: Colors.deepPurpleAccent.withOpacity(0.4),
                                    blurRadius: 10,
                                    spreadRadius: 2,
                                  )
                                ]
                              : [],
                        ),
                        child: Row(
                          children: [
                            Container(
                              height: 50,
                              width: 50,
                              decoration: BoxDecoration(
                                color: Colors.deepPurpleAccent,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(Icons.music_note, color: Colors.white),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Text(
                                song.title ?? 'Unknown Song',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            Icon(
                              isPlaying && _audioService.player.playing
                                  ? Icons.equalizer
                                  : Icons.play_arrow,
                              color: Colors.white,
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),

          // Mini Player
          AnimatedPositioned(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            bottom: _isMiniPlayerVisible ? 0 : -120,
            left: 0,
            right: 0,
            child: MiniPlayer(
              audioService: _audioService,
              onTap: _openFullPlayer,
            ),
          ),
        ],
      ),
    );
  }
}
