import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
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
        final isDark = theme.brightness == Brightness.dark;

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
            margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            height: 72,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.2),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
                child: Container(
                  decoration: BoxDecoration(
                    color: isDark 
                        ? const Color(0xFF1E1B4B).withValues(alpha: 0.85) 
                        : Colors.white.withValues(alpha: 0.9),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.1),
                      width: 1,
                    ),
                  ),
                  child: Column(
                    children: [
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          child: Row(
                            children: [
                              // Thumbnail
                              Hero(
                                tag: 'mini_player_thumb',
                                child: Container(
                                  width: 48,
                                  height: 48,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(12),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withValues(alpha: 0.2),
                                        blurRadius: 8,
                                        offset: const Offset(0, 4),
                                      ),
                                    ],
                                  ),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(12),
                                    child: track.thumbnailBytes != null
                                        ? Image.memory(
                                            track.thumbnailBytes!,
                                            fit: BoxFit.cover,
                                          )
                                        : Container(
                                            color: theme.colorScheme.primary.withValues(alpha: 0.2),
                                            child: Icon(
                                              CupertinoIcons.music_note_2,
                                              color: theme.colorScheme.primary,
                                              size: 24,
                                            ),
                                          ),
                                  ),
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
                                      style: GoogleFonts.outfit(
                                        color: theme.colorScheme.onSurface,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 15,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    Text(
                                      track.subtitle,
                                      style: GoogleFonts.outfit(
                                        color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                                        fontSize: 12,
                                        fontWeight: FontWeight.w500,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ),
                              ),
                              // Controls
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    icon: Icon(
                                      playerProvider.isPlaying
                                          ? CupertinoIcons.pause_fill
                                          : CupertinoIcons.play_fill,
                                      color: theme.colorScheme.primary,
                                      size: 28,
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
                                      color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                                      size: 24,
                                    ),
                                    onPressed: playerProvider.currentIndex <
                                            playerProvider.playlist.length - 1
                                        ? () => playerProvider.playNext()
                                        : null,
                                  ),
                                  IconButton(
                                    icon: Icon(
                                      CupertinoIcons.xmark,
                                      color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                                      size: 20,
                                    ),
                                    onPressed: () => playerProvider.stop(),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                      // Progress bar
                      ClipRRect(
                        borderRadius: const BorderRadius.only(
                          bottomLeft: Radius.circular(20),
                          bottomRight: Radius.circular(20),
                        ),
                        child: LinearProgressIndicator(
                          value: playerProvider.duration.inSeconds > 0
                              ? playerProvider.position.inSeconds /
                                  playerProvider.duration.inSeconds
                              : 0,
                          backgroundColor: Colors.transparent,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            theme.colorScheme.primary.withValues(alpha: 0.8),
                          ),
                          minHeight: 2,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
