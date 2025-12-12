import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import '../services/audio_player_service.dart';
import 'dart:async';

class PlayMusicScreen extends StatefulWidget {
  final AudioPlayerService audioService;

  const PlayMusicScreen({super.key, required this.audioService});

  @override
  State<PlayMusicScreen> createState() => _PlayMusicScreenState();
}

class _PlayMusicScreenState extends State<PlayMusicScreen> {
  double progress = 0.0;
  bool isPlaying = true;
  late StreamSubscription<Duration> _positionSub;
  late StreamSubscription<PlayerState> _playerStateSub;

  @override
  void initState() {
    super.initState();

    _positionSub = widget.audioService.player.positionStream.listen((pos) {
      final duration =
          widget.audioService.player.duration ?? Duration(seconds: 1);
      setState(() {
        progress = (pos.inMilliseconds / duration.inMilliseconds).clamp(0.0, 1.0);
      });
    });

    _playerStateSub =
        widget.audioService.player.playerStateStream.listen((state) {
      setState(() {
        isPlaying = widget.audioService.player.playing;
      });

      if (state.processingState == ProcessingState.completed) {
        widget.audioService.nextSong();
      }
    });
  }

  @override
  void dispose() {
    _positionSub.cancel();
    _playerStateSub.cancel();
    super.dispose();
  }

  Future<void> _togglePlayPause() async {
    await widget.audioService.togglePlayPause();
  }

  Future<void> _nextSong() async => await widget.audioService.nextSong();
  Future<void> _prevSong() async => await widget.audioService.previousSong();

  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds % 60;
    return '$minutes:${seconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final song = widget.audioService.currentSong;
    if (song == null) return const SizedBox();

    final theme = Theme.of(context);

    return DraggableScrollableSheet(
      expand: true,
      initialChildSize: 0.3,
      minChildSize: 0.3,
      maxChildSize: 1.0,
      builder: (_, __) => Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color.fromARGB(255, 122, 0, 0), Color(0xFF180041)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
          borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 25),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Drag handle
            Container(
              width: 50,
              height: 5,
              margin: const EdgeInsets.symmetric(vertical: 10),
              decoration: BoxDecoration(
                color: theme.colorScheme.onSurface.withAlpha(77),
                borderRadius: BorderRadius.circular(10),
              ),
            ),

            const SizedBox(height: 15),

            // Music artwork
            Container(
              height: 250,
              width: 250,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                gradient: const LinearGradient(
                  colors: [
                    Color.fromARGB(255, 8, 0, 0),
                    Color.fromARGB(255, 101, 1, 1),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Icon(
                Icons.music_note_rounded,
                size: 120,
                color: theme.colorScheme.onSurface,
              ),
            ),

            const SizedBox(height: 25),

            // Song title
            Text(
              song.title ?? 'Unknown Song',
              style: TextStyle(
                color: theme.colorScheme.onSurface,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 8),
            Text(
              "Unknown Artist",
              style:
                  TextStyle(color: theme.colorScheme.onSurface.withAlpha(179)),
            ),

            const SizedBox(height: 20),

            // Progress slider
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 25.0),
              child: Column(
                children: [
                  Slider(
                    value: progress,
                    min: 0,
                    max: 1,
                    activeColor: theme.colorScheme.primary,
                    inactiveColor:
                        theme.colorScheme.onSurface.withAlpha(61),
                    onChanged: (value) async {
                      final duration = widget.audioService.player.duration;
                      if (duration != null) {
                        final newPos = duration * value;
                        await widget.audioService.player.seek(newPos);
                      }
                    },
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        _formatDuration(
                            widget.audioService.player.position),
                        style: TextStyle(
                            color: theme.colorScheme.onSurface.withAlpha(179)),
                      ),
                      Text(
                        _formatDuration(widget.audioService.player.duration ??
                            Duration.zero),
                        style: TextStyle(
                            color: theme.colorScheme.onSurface.withAlpha(179)),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 15),

            // Control buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  icon: Icon(
                    Icons.skip_previous_rounded,
                    color: theme.colorScheme.onSurface,
                    size: 40,
                  ),
                  onPressed: _prevSong,
                ),
                const SizedBox(width: 15),
                GestureDetector(
                  onTap: _togglePlayPause,
                  child: Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: theme.colorScheme.primary.withAlpha(230),
                      boxShadow: [
                        BoxShadow(
                          color: theme.colorScheme.primary.withAlpha(153),
                          blurRadius: 15,
                          spreadRadius: 3,
                        ),
                      ],
                    ),
                    padding: const EdgeInsets.all(16),
                    child: Icon(
                      isPlaying
                          ? Icons.pause_rounded
                          : Icons.play_arrow_rounded,
                      color: theme.colorScheme.onSurface,
                      size: 50,
                    ),
                  ),
                ),
                const SizedBox(width: 15),
                IconButton(
                  icon: Icon(
                    Icons.skip_next_rounded,
                    color: theme.colorScheme.onSurface,
                    size: 40,
                  ),
                  onPressed: _nextSong,
                ),
              ],
            ),

            const SizedBox(height: 20),

            // Bottom row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Icon(Icons.shuffle,
                    color: theme.colorScheme.onSurface.withAlpha(179)),
                Icon(Icons.favorite_border,
                    color: theme.colorScheme.onSurface.withAlpha(179)),
                Icon(Icons.repeat,
                    color: theme.colorScheme.onSurface.withAlpha(179)),
                Icon(Icons.queue_music,
                    color: theme.colorScheme.onSurface.withAlpha(179)),
              ],
            ),

            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}
