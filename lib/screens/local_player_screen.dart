import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/app_theme.dart';
import '../widgets/neumorphic_widgets.dart';
import '../models/media_item.dart';
import '../providers/audio_player_provider.dart';

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
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          child: Column(
            children: [
              // —— HEADER ———————————————————————————————————————————————
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  NeumorphicButton(
                    size: 44,
                    onPressed: () => Navigator.pop(context),
                    child: const Icon(Icons.arrow_back_rounded, color: Colors.white70),
                  ),
                  Text(
                    'PLAYING NOW',
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: Colors.white38,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 2,
                    ),
                  ),
                  NeumorphicButton(
                    size: 44,
                    onPressed: () {},
                    child: const Icon(Icons.menu_rounded, color: Colors.white70),
                  ),
                ],
              ),

              const Spacer(flex: 2),

              // —— ARTWORK ——————————————————————————————————————————————
              NeumorphicContainer(
                width: size.width * 0.72,
                height: size.width * 0.72,
                shape: BoxShape.circle,
                padding: const EdgeInsets.all(12),
                depth: 20,
                child: Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    image: currentSong.thumbnailBytes != null 
                      ? DecorationImage(image: MemoryImage(currentSong.thumbnailBytes!), fit: BoxFit.cover)
                      : null,
                    color: currentSong.thumbnailBytes == null ? AppTheme.darkShadow : null,
                  ),
                  child: currentSong.thumbnailBytes == null 
                    ? const Icon(Icons.music_note_rounded, color: Colors.white10, size: 80)
                    : null,
                ),
              ),

              const Spacer(flex: 2),

              // —— METADATA —————————————————————————————————————————————
              Text(
                currentSong.title,
                textAlign: TextAlign.center,
                style: theme.textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                  fontSize: 28,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                currentSong.subtitle,
                textAlign: TextAlign.center,
                style: theme.textTheme.titleMedium?.copyWith(
                  color: Colors.white38,
                  fontWeight: FontWeight.w500,
                ),
              ),

              const Spacer(flex: 2),

              // —— SLIDER ———————————————————————————————————————————————
              StreamBuilder<Duration>(
                stream: audioProvider.audioPlayer.positionStream,
                builder: (context, snapshot) {
                  final position = snapshot.data ?? Duration.zero;
                  final duration = audioProvider.audioPlayer.duration ?? Duration.zero;
                  final progress = duration.inSeconds > 0 
                      ? (position.inSeconds / duration.inSeconds).clamp(0.0, 1.0)
                      : 0.0;

                  return Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              _formatDuration(position),
                              style: const TextStyle(color: Colors.white38, fontSize: 12, fontWeight: FontWeight.bold),
                            ),
                            Text(
                              _formatDuration(duration),
                              style: const TextStyle(color: Colors.white38, fontSize: 12, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 8),
                      // Custom Neumorphic Slider
                      Stack(
                        children: [
                          Container(
                            height: 6,
                            decoration: BoxDecoration(
                              color: AppTheme.darkShadow,
                              borderRadius: BorderRadius.circular(3),
                            ),
                          ),
                          FractionallySizedBox(
                            widthFactor: progress,
                            child: Container(
                              height: 6,
                              decoration: BoxDecoration(
                                gradient: AppTheme.accentGradient,
                                borderRadius: BorderRadius.circular(3),
                                boxShadow: [
                                  BoxShadow(
                                    color: AppTheme.brand.withValues(alpha: 0.5),
                                    blurRadius: 10,
                                    spreadRadius: 1,
                                  )
                                ],
                              ),
                            ),
                          ),
                          // Thumb (invisible slider to handle input)
                          Positioned.fill(
                            child: SliderTheme(
                              data: SliderTheme.of(context).copyWith(
                                trackHeight: 6,
                                activeTrackColor: Colors.transparent,
                                inactiveTrackColor: Colors.transparent,
                                thumbColor: AppTheme.brand,
                                thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
                                overlayShape: SliderComponentShape.noOverlay,
                              ),
                              child: Slider(
                                value: progress,
                                onChanged: (v) {
                                  final newPos = Duration(seconds: (v * duration.inSeconds).toInt());
                                  audioProvider.audioPlayer.seek(newPos);
                                },
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  );
                }
              ),

              const Spacer(flex: 2),

              // —— CONTROLS —————————————————————————————————————————————
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  NeumorphicButton(
                    size: 64,
                    onPressed: () => audioProvider.playPrevious(),
                    child: const Icon(Icons.fast_rewind_rounded, size: 28, color: Colors.white70),
                  ),
                  NeumorphicButton(
                    size: 80,
                    isAccent: true,
                    onPressed: () {
                      if (audioProvider.isPlaying) {
                        audioProvider.pause();
                      } else {
                        audioProvider.play();
                      }
                    },
                    child: Icon(
                      audioProvider.isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
                      size: 40,
                      color: Colors.white,
                    ),
                  ),
                  NeumorphicButton(
                    size: 64,
                    onPressed: () => audioProvider.playNext(),
                    child: const Icon(Icons.fast_forward_rounded, size: 28, color: Colors.white70),
                  ),
                ],
              ),

              const Spacer(flex: 1),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return '$minutes:$seconds';
  }
}
