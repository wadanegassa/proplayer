import 'package:flutter/material.dart';
import '../services/audio_player_service.dart';
import '../services/media_service.dart';
import '../widgets/mini_player_bar.dart';
import 'player_screen.dart';
import 'video_list_screen.dart';
import 'package:photo_manager/photo_manager.dart';

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
  int _currentIndex = 0;
  bool _hideMiniPlayer = false;

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
    setState(() {}); // rebuild to show mini player
  }

  void _openFullPlayer() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => PlayMusicScreen(audioService: _audioService),
    );
  }

  @override
  void dispose() {
    _audioService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> screens = [
      _buildMusicList(),
      VideoListScreen(
        onVideoOpen: () => setState(() => _hideMiniPlayer = true),
        onVideoClose: () => setState(() => _hideMiniPlayer = false),
      ),
    ];

    final showMiniPlayer =
        !_hideMiniPlayer && _audioService.currentSong != null;

    return Scaffold(
      extendBody: true,
      backgroundColor: const Color(0xFF0D0122),
      appBar: AppBar(
        title: Text(_currentIndex == 0 ? 'Music Library' : 'Video Library'),
        backgroundColor: const Color.fromARGB(255, 5, 0, 20),
        elevation: 0,
        actions: [IconButton(icon: const Icon(Icons.search), onPressed: () {})],
      ),
      body: Stack(
        children: [
          IndexedStack(index: _currentIndex, children: screens),
          if (showMiniPlayer)
            Positioned(
              bottom: 60,
              left: 5,
              right: 5,
              child: MiniPlayer(
                audioService: _audioService,
                onTap: _openFullPlayer,
              ),
            ),
        ],
      ),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  Widget _buildMusicList() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color.fromARGB(255, 0, 0, 0), Color(0xFF0D0122)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: _isLoading
          ? const Center(
              child: CircularProgressIndicator(
                color: Color.fromARGB(255, 69, 0, 0),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.only(bottom: 120),
              itemCount: _songs.length,
              itemBuilder: (context, index) {
                final song = _songs[index];
                final isPlaying =
                    _audioService.currentSong == song &&
                    _audioService.player.playing;

                return InkWell(
                  onTap: () => _onSongTap(index),
                  child: Container(
                    margin: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      gradient: isPlaying
                          ? const LinearGradient(
                              colors: [
                                Color.fromARGB(255, 117, 1, 1),
                                Color.fromARGB(255, 24, 0, 4),
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            )
                          : LinearGradient(
                              colors: [
                                Color.fromARGB(255, 35, 0, 0).withOpacity(0.4),
                                Color.fromARGB(255, 50, 0, 0).withOpacity(0.4),
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: isPlaying
                          ? [
                              BoxShadow(
                                color: const Color.fromARGB(
                                  255,
                                  255,
                                  77,
                                  77,
                                ).withOpacity(0.4),
                                blurRadius: 10,
                                spreadRadius: 2,
                              ),
                            ]
                          : [],
                    ),
                    child: Row(
                      children: [
                        Container(
                          height: 50,
                          width: 50,
                          decoration: BoxDecoration(
                            color: const Color.fromARGB(255, 155, 0, 0),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            Icons.music_note,
                            color: Colors.white,
                          ),
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
                          isPlaying ? Icons.equalizer : Icons.play_arrow,
                          color: Colors.white,
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }

  Widget _buildBottomNav() {
    return Container(
      decoration: BoxDecoration(
        color: const Color.fromARGB(255, 14, 0, 39),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
        boxShadow: const [
          BoxShadow(
            color: Color.fromARGB(80, 255, 99, 99),
            blurRadius: 10,
            offset: Offset(0, -3),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
        child: BottomNavigationBar(
          backgroundColor: const Color.fromARGB(255, 13, 1, 26),
          selectedItemColor: const Color.fromARGB(255, 255, 99, 99),
          unselectedItemColor: Colors.white70,
          currentIndex: _currentIndex,
          onTap: (index) {
            setState(() {
              _currentIndex = index;
              if (_currentIndex == 1) {
                // Video tab clicked: hide mini player and pause music
                _hideMiniPlayer = true;
                _audioService.player.pause();
              } else {
                // Music tab clicked: show mini player and optionally resume
                _hideMiniPlayer = false;
                _audioService.player.play();
              }
            });
          },
          type: BottomNavigationBarType.fixed,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.music_note),
              label: 'Music',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.video_library),
              label: 'Videos',
            ),
          ],
        ),
      ),
    );
  }
}
