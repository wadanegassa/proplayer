import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:google_fonts/google_fonts.dart';
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

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              theme.colorScheme.surface,
              theme.scaffoldBackgroundColor,
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
        ),
        child: Column(
          children: [
            // Drag handle
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(2),
              ),
            ),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Column(
                  children: [
                    const SizedBox(height: 20),
                    // Music artwork with glow
                    Center(
                      child: Container(
                        height: 300,
                        width: 300,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(32),
                          boxShadow: [
                            BoxShadow(
                              color: theme.colorScheme.primary.withValues(alpha: 0.3),
                              blurRadius: 40,
                              spreadRadius: 5,
                            ),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(32),
                          child: Container(
                            color: theme.colorScheme.surface,
                            child: Icon(
                              Icons.music_note_rounded,
                              size: 140,
                              color: theme.colorScheme.primary,
                            ),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 40),

                    // Song title & Artist
                    Text(
                      song.title ?? 'Unknown Song',
                      style: GoogleFonts.outfit(
                        color: Colors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "Unknown Artist",
                      style: GoogleFonts.outfit(
                        color: Colors.white.withValues(alpha: 0.6),
                        fontSize: 18,
                      ),
                    ),

                    const SizedBox(height: 40),

                    // Progress slider
                    Column(
                      children: [
                        SliderTheme(
                          data: SliderTheme.of(context).copyWith(
                            trackHeight: 4,
                            thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
                            overlayShape: const RoundSliderOverlayShape(overlayRadius: 14),
                            activeTrackColor: theme.colorScheme.primary,
                            inactiveTrackColor: Colors.white.withValues(alpha: 0.1),
                            thumbColor: Colors.white,
                          ),
                          child: Slider(
                            value: progress,
                            min: 0,
                            max: 1,
                            onChanged: (value) async {
                              final duration = widget.audioService.player.duration;
                              if (duration != null) {
                                final newPos = duration * value;
                                await widget.audioService.player.seek(newPos);
                              }
                            },
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                _formatDuration(widget.audioService.player.position),
                                style: TextStyle(
                                  color: Colors.white.withValues(alpha: 0.5),
                                  fontSize: 12,
                                ),
                              ),
                              Text(
                                _formatDuration(widget.audioService.player.duration ?? Duration.zero),
                                style: TextStyle(
                                  color: Colors.white.withValues(alpha: 0.5),
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 30),

                    // Control buttons
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.shuffle_rounded),
                          color: Colors.white.withValues(alpha: 0.5),
                          iconSize: 28,
                          onPressed: () {
                            // TODO: Implement shuffle logic in service
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text("Shuffle toggled"), duration: Duration(seconds: 1)),
                            );
                          },
                        ),
                        const Spacer(),
                        IconButton(
                          icon: const Icon(Icons.skip_previous_rounded),
                          color: Colors.white,
                          iconSize: 48,
                          onPressed: _prevSong,
                        ),
                        const SizedBox(width: 20),
                        GestureDetector(
                          onTap: _togglePlayPause,
                          child: Container(
                            height: 80,
                            width: 80,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: LinearGradient(
                                colors: [
                                  theme.colorScheme.primary,
                                  theme.colorScheme.secondary,
                                ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: theme.colorScheme.primary.withValues(alpha: 0.4),
                                  blurRadius: 20,
                                  offset: const Offset(0, 8),
                                ),
                              ],
                            ),
                            child: Icon(
                              isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
                              color: Colors.white,
                              size: 48,
                            ),
                          ),
                        ),
                        const SizedBox(width: 20),
                        IconButton(
                          icon: const Icon(Icons.skip_next_rounded),
                          color: Colors.white,
                          iconSize: 48,
                          onPressed: _nextSong,
                        ),
                        const Spacer(),
                        IconButton(
                          icon: const Icon(Icons.repeat_rounded),
                          color: Colors.white.withValues(alpha: 0.5),
                          iconSize: 28,
                          onPressed: () {
                            // TODO: Implement repeat logic in service
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text("Repeat toggled"), duration: Duration(seconds: 1)),
                            );
                          },
                        ),
                      ],
                    ),

                    const SizedBox(height: 40),

                    // Bottom row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildActionButton(Icons.favorite_border_rounded, "Favorite"),
                        _buildActionButton(Icons.playlist_add_rounded, "Add to Playlist"),
                        _buildActionButton(Icons.share_rounded, "Share"),
                        _buildActionButton(Icons.more_horiz_rounded, "More"),
                      ],
                    ),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton(IconData icon, String label) {
    return Column(
      children: [
        IconButton(
          icon: Icon(icon),
          color: Colors.white.withValues(alpha: 0.7),
          onPressed: () {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text("$label clicked"), duration: const Duration(seconds: 1)),
            );
          },
        ),
      ],
    );
  }
}
