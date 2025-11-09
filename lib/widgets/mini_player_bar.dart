import 'package:flutter/material.dart';
import '../services/audio_player_service.dart';

class MiniPlayer extends StatelessWidget {
  final AudioPlayerService audioService;
  final VoidCallback onTap;

  const MiniPlayer({
    super.key,
    required this.audioService,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final song = audioService.currentSong;
    if (song == null) return const SizedBox();

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        color: Colors.deepPurple.shade900,
        child: Row(
          children: [
            const Icon(Icons.music_note, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                song.title ?? 'Unknown',
                style: const TextStyle(color: Colors.white),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            StreamBuilder<bool>(
              stream: audioService.player.playingStream,
              builder: (context, snapshot) {
                final isPlaying = snapshot.data ?? true;
                return IconButton(
                  onPressed: () => audioService.togglePlayPause(),
                  icon: Icon(
                    isPlaying ? Icons.pause_circle : Icons.play_circle,
                    color: Colors.white,
                    size: 32,
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
