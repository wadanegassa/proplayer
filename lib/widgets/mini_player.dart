import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import '../providers/audio_player_provider.dart';
import '../screens/local_player_screen.dart';

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

  final theme = Theme.of(context);

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
              // When returning from full player, set to minimized
              playerProvider.setMinimized(true);
            });
          },
          child: Container(
            height: 70,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  theme.colorScheme.primary.withAlpha(300),
                  theme.colorScheme.secondary.withAlpha(300),
                ],
              ),
              boxShadow: [
                BoxShadow(
                  color: theme.shadowColor.withAlpha(77),
                  blurRadius: 10,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: Column(
              children: [
        // Progress bar
        LinearProgressIndicator(
          value: playerProvider.duration.inSeconds > 0
            ? playerProvider.position.inSeconds /
              playerProvider.duration.inSeconds
            : 0,
          backgroundColor: theme.colorScheme.onSurface.withAlpha(51),
          valueColor:
            AlwaysStoppedAnimation<Color>(theme.colorScheme.onSurface),
          minHeight: 2,
        ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      children: [
                        // Thumbnail
                        Container(
                          width: 45,
                          height: 45,
                            decoration: BoxDecoration(
                            color: theme.colorScheme.onSurface.withAlpha(51),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: track.thumbnailBytes != null
                              ? ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: Image.memory(
                                    track.thumbnailBytes!,
                                    fit: BoxFit.cover,
                                  ),
                                )
                              : Icon(
                                  CupertinoIcons.music_note,
                                  color: theme.colorScheme.onSurface,
                                  size: 24,
                                ),
                        ),
                        const SizedBox(width: 12),
                        // Track info
                        Expanded(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                track.title,
                                style: TextStyle(
                                  color: theme.colorScheme.onSurface,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              Text(
                                track.subtitle,
                                style: TextStyle(
                                  color: theme.colorScheme.onSurface.withAlpha(204),
                                  fontSize: 12,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                        // Controls
                        IconButton(
                          icon: Icon(
                            playerProvider.isPlaying
                                ? CupertinoIcons.pause_fill
                                : CupertinoIcons.play_fill,
                            color: theme.colorScheme.onSurface,
                          ),
                          onPressed: () {
                            if (playerProvider.isPlaying) {
                              playerProvider.pause();
                            } else {
                              playerProvider.play();
                            }
                          },
                        ),
                        IconButton(
                          icon: Icon(
                            CupertinoIcons.forward_fill,
                            color: theme.colorScheme.onSurface,
                          ),
                          onPressed: playerProvider.currentIndex <
                                  playerProvider.playlist.length - 1
                              ? () => playerProvider.playNext()
                              : null,
                        ),
                        IconButton(
                          icon: Icon(
                            CupertinoIcons.xmark,
                            color: theme.colorScheme.onSurface,
                          ),
                          onPressed: () => playerProvider.stop(),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
