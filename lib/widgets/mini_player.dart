import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/audio_player_provider.dart';
import '../screens/local_player_screen.dart';
import '../theme/app_theme.dart';
import 'beat_animation.dart';

class MiniPlayer extends StatelessWidget {
  const MiniPlayer({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Consumer<AudioPlayerProvider>(
      builder: (context, playerProvider, _) {
        if (playerProvider.currentTrack == null || !playerProvider.isMinimized) {
          return const SizedBox.shrink();
        }

        final track = playerProvider.currentTrack!;

        return GestureDetector(
          onTap: () {
            playerProvider.setMinimized(false);
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context, ) => LocalPlayerScreen(
                  mediaItem: track,
                  playlist: playerProvider.playlist,
                  fromMiniPlayer: true,
                ),
              ),
            ).then((_) {
              playerProvider.setMinimized(true);
            });
          },
          child: Container(
            margin: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: theme.brightness == Brightness.dark ? AppTheme.surfaceDark : Colors.black,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: theme.brightness == Brightness.dark ? 0.5 : 0.2),
                  blurRadius: 15,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Row(
              children: [
                Hero(
                  tag: 'mini_player_thumb',
                  child: BeatAnimation(
                    isPlaying: playerProvider.isPlaying,
                    child: Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        image: track.thumbnailBytes != null
                            ? DecorationImage(image: MemoryImage(track.thumbnailBytes!), fit: BoxFit.cover)
                            : track.thumbnail != null
                                ? DecorationImage(image: NetworkImage(track.thumbnail!), fit: BoxFit.cover)
                                : null,
                        color: AppTheme.primary.withValues(alpha: 0.1),
                      ),
                      child: (track.thumbnailBytes == null && track.thumbnail == null)
                          ? const Icon(Icons.graphic_eq_rounded, color: AppTheme.primary, size: 24)
                          : null,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        track.title,
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.white),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        track.subtitle,
                        style: const TextStyle(color: Colors.white54, fontSize: 12),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () {
                    if (playerProvider.isPlaying) {
                      playerProvider.pause();
                    } else {
                      playerProvider.play();
                    }
                  },
                  icon: Icon(
                    playerProvider.isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
                    size: 28,
                    color: Colors.white,
                  ),
                ),
                IconButton(
                  onPressed: playerProvider.canPlayNext ? () => playerProvider.playNext() : null,
                  icon: const Icon(Icons.skip_next_rounded, size: 28, color: Colors.white),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
