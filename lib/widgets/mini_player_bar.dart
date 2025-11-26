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
    final theme = Theme.of(context);
    final song = audioService.currentSong;
    if (song == null) return const SizedBox();

    return GestureDetector(
      onTap: onTap,
        child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          color: theme.cardColor,
          boxShadow: [
            BoxShadow(
              color: theme.shadowColor.withAlpha((0.14 * 255).round()),
              blurRadius: 10,
              offset: const Offset(0, -3),
            ),
          ],
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),

        child: Row(
          children: [
            Icon(Icons.music_note, color: theme.colorScheme.onSurface),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                song.title ?? 'Unknown',
                style: TextStyle(color: theme.colorScheme.onSurface),
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
                    color: theme.colorScheme.onSurface,
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
