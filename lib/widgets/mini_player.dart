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
                  const Color(0xFF0284C7).withValues(alpha: 0.9), // Cool blue
                  const Color(0xFF0891B2).withValues(alpha: 0.9), // Cyan
                ],
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.3),
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
                  backgroundColor: Colors.white.withValues(alpha: 0.2),
                  valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
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
                            color: Colors.white.withValues(alpha: 0.2),
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
                              : const Icon(
                                  CupertinoIcons.music_note,
                                  color: Colors.white,
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
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              Text(
                                track.subtitle,
                                style: TextStyle(
                                  color: Colors.white.withValues(alpha: 0.8),
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
                            color: Colors.white,
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
                          icon: const Icon(
                            CupertinoIcons.forward_fill,
                            color: Colors.white,
                          ),
                          onPressed: playerProvider.currentIndex <
                                  playerProvider.playlist.length - 1
                              ? () => playerProvider.playNext()
                              : null,
                        ),
                        IconButton(
                          icon: const Icon(
                            CupertinoIcons.xmark,
                            color: Colors.white,
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
