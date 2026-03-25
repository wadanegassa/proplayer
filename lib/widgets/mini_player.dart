import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import '../providers/audio_player_provider.dart';
import '../screens/local_player_screen.dart';
import '../theme/app_theme.dart';

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
              playerProvider.setMinimized(true);
            });
          },
          child: Container(
            margin: const EdgeInsets.fromLTRB(16, 0, 16, 10),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(26),
              boxShadow: [
                BoxShadow(
                  color: theme.colorScheme.primary.withValues(alpha: isDark ? 0.25 : 0.18),
                  blurRadius: 24,
                  offset: const Offset(0, 10),
                ),
                BoxShadow(
                  color: Colors.black.withValues(alpha: isDark ? 0.35 : 0.08),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(26),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: theme.colorScheme.outline.withValues(alpha: 0.22),
                    ),
                    gradient: LinearGradient(
                      colors: isDark
                          ? [
                              theme.colorScheme.surface.withValues(alpha: 0.88),
                              theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.72),
                            ]
                          : [
                              Colors.white.withValues(alpha: 0.94),
                              Colors.white.withValues(alpha: 0.82),
                            ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(14, 12, 10, 4),
                        child: Row(
                          children: [
                            Hero(
                              tag: 'mini_player_thumb',
                              child: Container(
                                width: 52,
                                height: 52,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(16),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withValues(alpha: 0.2),
                                      blurRadius: 10,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(16),
                                  child: track.thumbnailBytes != null
                                      ? Image.memory(
                                          track.thumbnailBytes!,
                                          fit: BoxFit.cover,
                                        )
                                      : DecoratedBox(
                                          decoration: BoxDecoration(
                                            gradient: AppTheme.accentGradient,
                                          ),
                                          child: Icon(
                                            CupertinoIcons.music_note_2,
                                            color: theme.colorScheme.onPrimary,
                                            size: 26,
                                          ),
                                        ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    track.title,
                                    style: theme.textTheme.titleMedium?.copyWith(
                                      fontWeight: FontWeight.w700,
                                      letterSpacing: -0.2,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    track.subtitle,
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      color: theme.colorScheme.onSurface.withValues(alpha: 0.52),
                                      fontWeight: FontWeight.w500,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                            _RoundMiniButton(
                              icon: playerProvider.isPlaying
                                  ? CupertinoIcons.pause_fill
                                  : CupertinoIcons.play_fill,
                              onTap: () {
                                if (playerProvider.isPlaying) {
                                  playerProvider.pause();
                                } else {
                                  playerProvider.play();
                                }
                              },
                            ),
                            _RoundMiniButton(
                              icon: CupertinoIcons.forward_fill,
                              enabled: playerProvider.canPlayNext,
                              onTap: playerProvider.canPlayNext
                                  ? () => playerProvider.playNext()
                                  : null,
                            ),
                            _RoundMiniButton(
                              icon: CupertinoIcons.xmark,
                              subtle: true,
                              onTap: () => playerProvider.stop(),
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(14, 0, 14, 10),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: LinearProgressIndicator(
                            value: playerProvider.duration.inSeconds > 0
                                ? playerProvider.position.inSeconds /
                                    playerProvider.duration.inSeconds
                                : 0,
                            minHeight: 4,
                            backgroundColor: theme.colorScheme.outline.withValues(alpha: 0.15),
                            valueColor: AlwaysStoppedAnimation<Color>(theme.colorScheme.primary),
                          ),
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

class _RoundMiniButton extends StatelessWidget {
  const _RoundMiniButton({
    required this.icon,
    required this.onTap,
    this.enabled = true,
    this.subtle = false,
  });

  final IconData icon;
  final VoidCallback? onTap;
  final bool enabled;
  final bool subtle;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final active = enabled && onTap != null;
    final color = !active
        ? theme.colorScheme.onSurface.withValues(alpha: 0.22)
        : subtle
            ? theme.colorScheme.onSurface.withValues(alpha: 0.45)
            : theme.colorScheme.primary;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        customBorder: const CircleBorder(),
        child: Padding(
          padding: const EdgeInsets.all(6),
          child: Icon(icon, color: color, size: subtle ? 18 : 22),
        ),
      ),
    );
  }
}
