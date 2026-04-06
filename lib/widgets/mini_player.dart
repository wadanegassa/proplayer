import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/audio_player_provider.dart';
import '../screens/local_player_screen.dart';
import '../theme/app_theme.dart';
import 'neumorphic_widgets.dart';

class MiniPlayer extends StatelessWidget {
  const MiniPlayer({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AudioPlayerProvider>(
      builder: (context, playerProvider, _) {
        if (playerProvider.currentTrack == null) {
          return const SizedBox.shrink();
        }

        final track = playerProvider.currentTrack!;

        return GestureDetector(
          onTap: () {
            playerProvider.setMinimized(false);
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => LocalPlayerScreen(
                  mediaItem: track,
                  playlist: playerProvider.playlist,
                  fromMiniPlayer: true,
                ),
              ),
            ).then((_) {
              playerProvider.setMinimized(true);
            });
          },
          child: Padding(
            padding: const EdgeInsets.fromLTRB(12, 0, 12, 10),
            child: NeumorphicContainer(
              height: 72,
              borderRadius: 20,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              depth: 10,
              child: Row(
                children: [
                  Hero(
                    tag: 'mini_player_thumb',
                    child: Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        image: track.thumbnailBytes != null
                            ? DecorationImage(image: MemoryImage(track.thumbnailBytes!), fit: BoxFit.cover)
                            : null,
                        color: AppTheme.darkShadow,
                      ),
                      child: track.thumbnailBytes == null
                          ? const Icon(Icons.music_note_rounded, color: Colors.white10, size: 24)
                          : null,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          track.title,
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          track.subtitle,
                          style: const TextStyle(color: Colors.white38, fontSize: 12),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  NeumorphicButton(
                    size: 40,
                    onPressed: () {
                      if (playerProvider.isPlaying) {
                        playerProvider.pause();
                      } else {
                        playerProvider.play();
                      }
                    },
                    child: Icon(
                      playerProvider.isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
                      size: 20,
                      color: Colors.white70,
                    ),
                  ),
                  const SizedBox(width: 8),
                  NeumorphicButton(
                    size: 40,
                    onPressed: playerProvider.canPlayNext ? () => playerProvider.playNext() : null,
                    child: const Icon(Icons.fast_forward_rounded, size: 20, color: Colors.white70),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
