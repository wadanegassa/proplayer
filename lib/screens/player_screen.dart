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

    // Listen to position updates to update the slider
    _positionSub = widget.audioService.player.positionStream.listen((pos) {
      final duration =
          widget.audioService.player.duration ?? Duration(seconds: 1);
      setState(() {
        progress = (pos.inMilliseconds / duration.inMilliseconds).clamp(
          0.0,
          1.0,
        );
      });
    });

    // Listen to player state (to auto play next song when finished)
    _playerStateSub = widget.audioService.player.playerStateStream.listen((
      state,
    ) {
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

    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.9,
      minChildSize: 0.5,
      maxChildSize: 1.0,
      builder: (_, controller) => Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF3E0A70), Color(0xFF180041)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
          borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
        ),
        child: Column(
          children: [
            // Drag handle
            Container(
              width: 50,
              height: 5,
              margin: const EdgeInsets.symmetric(vertical: 10),
              decoration: BoxDecoration(
                color: Colors.white30,
                borderRadius: BorderRadius.circular(10),
              ),
            ),

            const SizedBox(height: 15),

            // Music artwork placeholder
            Container(
              height: 250,
              width: 250,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                gradient: const LinearGradient(
                  colors: [Color(0xFF7C4DFF), Color(0xFF9575CD)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: const Icon(
                Icons.music_note_rounded,
                size: 120,
                color: Colors.white,
              ),
            ),

            const SizedBox(height: 25),

            // Song title
            Text(
              song.title ?? 'Unknown Song',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 8),
            const Text(
              "Unknown Artist",
              style: TextStyle(color: Colors.white70),
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
                    activeColor: Colors.deepPurpleAccent,
                    inactiveColor: Colors.white24,
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
                        _formatDuration(widget.audioService.player.position),
                        style: const TextStyle(color: Colors.white70),
                      ),
                      Text(
                        _formatDuration(
                          widget.audioService.player.duration ?? Duration.zero,
                        ),
                        style: const TextStyle(color: Colors.white70),
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
                  icon: const Icon(
                    Icons.skip_previous_rounded,
                    color: Colors.white,
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
                      color: Colors.deepPurpleAccent.withValues(alpha: 0.9),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.deepPurpleAccent.withValues(alpha: 0.6),
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
                      color: Colors.white,
                      size: 50,
                    ),
                  ),
                ),
                const SizedBox(width: 15),
                IconButton(
                  icon: const Icon(
                    Icons.skip_next_rounded,
                    color: Colors.white,
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
              children: const [
                Icon(Icons.shuffle, color: Colors.white70),
                Icon(Icons.favorite_border, color: Colors.white70),
                Icon(Icons.repeat, color: Colors.white70),
                Icon(Icons.queue_music, color: Colors.white70),
              ],
            ),

            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}
