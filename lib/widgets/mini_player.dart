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
            margin: const EdgeInsets.only(bottom: 8),
            decoration: BoxDecoration(
              color: isDark ? theme.colorScheme.surfaceContainerHighest : theme.colorScheme.surface,
              border: Border(
                top: BorderSide(color: theme.colorScheme.outline.withValues(alpha: isDark ? 0.35 : 0.5)),
                bottom: BorderSide(color: theme.colorScheme.outline.withValues(alpha: isDark ? 0.35 : 0.5)),
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(height: 2, color: AppTheme.brand),
                Padding(
                  padding: const EdgeInsets.fromLTRB(12, 10, 8, 4),
                  child: Row(
                    children: [
                      Hero(
                        tag: 'mini_player_thumb',
                        child: Container(
                          width: 52,
                          height: 52,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: theme.colorScheme.outline.withValues(alpha: 0.35),
                              width: 1.5,
                            ),
                          ),
                          clipBehavior: Clip.antiAlias,
                          child: track.thumbnailBytes != null
                              ? Image.memory(
                                  track.thumbnailBytes!,
                                  fit: BoxFit.cover,
                                )
                              : ColoredBox(
                                  color: theme.colorScheme.primaryContainer.withValues(
                                    alpha: isDark ? 0.5 : 1,
                                  ),
                                  child: Icon(
                                    CupertinoIcons.music_note_2,
                                    color: theme.colorScheme.primary,
                                    size: 26,
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
                              style: theme.textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.w700,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 2),
                            Text(
                              track.subtitle,
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
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
                  padding: const EdgeInsets.fromLTRB(12, 0, 12, 10),
                  child: LinearProgressIndicator(
                      value: playerProvider.duration.inSeconds > 0
                          ? playerProvider.position.inSeconds /
                              playerProvider.duration.inSeconds
                          : 0,
                      minHeight: 3,
                      backgroundColor: theme.colorScheme.outline.withValues(alpha: 0.12),
                      valueColor: AlwaysStoppedAnimation<Color>(theme.colorScheme.primary),
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
