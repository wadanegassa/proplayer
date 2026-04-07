import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:audio_video_progress_bar/audio_video_progress_bar.dart';
import '../theme/app_theme.dart';
import '../models/media_item.dart';
import '../providers/audio_player_provider.dart';
import '../widgets/beat_animation.dart';

class LocalPlayerScreen extends StatelessWidget {
  final MediaItem mediaItem;
  final List<MediaItem> playlist;
  final bool fromMiniPlayer;

  const LocalPlayerScreen({
    super.key,
    required this.mediaItem,
    required this.playlist,
    this.fromMiniPlayer = false,
  });

  @override
  Widget build(BuildContext context) {
    final audioProvider = context.watch<AudioPlayerProvider>();
    final currentSong = audioProvider.currentTrack ?? mediaItem;
    final theme = Theme.of(context);
    final size = MediaQuery.sizeOf(context);

    // Initial play if not from mini player
    if (!fromMiniPlayer && audioProvider.currentTrack?.id != mediaItem.id) {
       WidgetsBinding.instance.addPostFrameCallback((_) {
         audioProvider.playTrack(mediaItem, playlist);
       });
    }

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: Stack(
        children: [
          // —— BACKGROUND ARTWORK ——————————————————————————————————————
          Positioned.fill(
            child: currentSong.thumbnailBytes != null
              ? Image.memory(currentSong.thumbnailBytes!, fit: BoxFit.cover)
              : currentSong.thumbnail != null
                ? Image.network(currentSong.thumbnail!, fit: BoxFit.cover)
                : Container(color: theme.colorScheme.surface),
          ),
          // —— BLUR & GRADIENT OVERLAY —————————————————————————————————
          Positioned.fill(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 60, sigmaY: 60),
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.black.withValues(alpha: 0.4),
                      theme.scaffoldBackgroundColor.withValues(alpha: 0.7),
                      theme.scaffoldBackgroundColor.withValues(alpha: 0.95),
                    ],
                    stops: const [0.0, 0.4, 1.0],
                  ),
                ),
              ),
            ),
          ),
          // —— FOREGROUND UI ———————————————————————————————————————————
          SafeArea(
            child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          child: Column(
            children: [
              // —— HEADER ———————————————————————————————————————————————
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.arrow_back_ios_new_rounded),
                  ),
                  Text(
                    'Now Playing',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    onPressed: () {},
                    icon: const Icon(Icons.more_horiz_rounded),
                  ),
                ],
              ),

              const SizedBox(height: 40),

              // —— ARTWORK ——————————————————————————————————————————————
              Center(
                child: BeatAnimation(
                  isPlaying: audioProvider.isPlaying,
                  child: Container(
                    width: size.width * 0.75,
                    height: size.width * 0.75,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(40),
                      boxShadow: [
                        BoxShadow(
                          color: AppTheme.primary.withValues(alpha: audioProvider.isPlaying ? 0.3 : 0.05),
                          blurRadius: audioProvider.isPlaying ? 40 : 20,
                          spreadRadius: audioProvider.isPlaying ? 10 : 0,
                          offset: const Offset(0, 15),
                        ),
                      ],
                      image: currentSong.thumbnailBytes != null 
                        ? DecorationImage(image: MemoryImage(currentSong.thumbnailBytes!), fit: BoxFit.cover)
                        : currentSong.thumbnail != null
                          ? DecorationImage(image: NetworkImage(currentSong.thumbnail!), fit: BoxFit.cover)
                          : null,
                      color: theme.colorScheme.surface,
                    ),
                    child: (currentSong.thumbnailBytes == null && currentSong.thumbnail == null)
                      ? Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.graphic_eq_rounded, color: AppTheme.primary.withValues(alpha: 0.8), size: 120),
                          ],
                        )
                      : null,
                  ),
                ),
              ),

              const SizedBox(height: 50),

              // —— METADATA —————————————————————————————————————————————
              Text(
                currentSong.title,
                textAlign: TextAlign.center,
                style: theme.textTheme.displaySmall?.copyWith(
                  fontWeight: FontWeight.w900,
                  fontSize: 32,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 12),
              Text(
                currentSong.subtitle,
                textAlign: TextAlign.center,
                style: theme.textTheme.titleMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.w500,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),

              const Spacer(),

              // —— WAVEFORM PROGRESS BAR —————————————————————————————————
              StreamBuilder<Duration>(
                stream: audioProvider.audioPlayer.positionStream,
                builder: (context, snapshot) {
                  final position = snapshot.data ?? Duration.zero;
                  final duration = audioProvider.audioPlayer.duration ?? Duration.zero;

                  return ProgressBar(
                    progress: position,
                    total: duration,
                    onSeek: (duration) {
                      audioProvider.audioPlayer.seek(duration);
                    },
                    barHeight: 5,
                    baseBarColor: theme.colorScheme.onSurface.withValues(alpha: 0.1),
                    progressBarColor: AppTheme.primary,
                    thumbColor: AppTheme.primary,
                    thumbRadius: 6,
                    timeLabelTextStyle: theme.textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.onSurface,
                    ),
                  );
                }
              ),

              const SizedBox(height: 40),

              // —— CONTROLS —————————————————————————————————————————————
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                   IconButton(
                    onPressed: () => audioProvider.playPrevious(),
                    icon: const Icon(Icons.skip_previous_rounded, size: 40),
                  ),
                  GestureDetector(
                    onTap: () {
                      if (audioProvider.isPlaying) {
                        audioProvider.pause();
                      } else {
                        audioProvider.play();
                      }
                    },
                    child: Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: AppTheme.primary,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: AppTheme.primary.withValues(alpha: 0.3),
                            blurRadius: 20,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: Icon(
                        audioProvider.isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
                        size: 48,
                        color: Colors.black,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => audioProvider.playNext(),
                    icon: const Icon(Icons.skip_next_rounded, size: 40),
                  ),
                ],
              ),

              const Spacer(),
              
              // —— BOTTOM SONGS INDICATOR ————————————————————————————————
              Column(
                children: [
                  const Icon(Icons.keyboard_arrow_up_rounded, color: Colors.white24),
                  Text(
                    'QUEUE',
                    style: theme.textTheme.labelLarge?.copyWith(
                      letterSpacing: 2,
                      fontWeight: FontWeight.w900,
                      fontSize: 14,
                      color: Colors.white24,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
            ],
          ),
        ),
      ),
      ]
     ),
    );
  }
}
