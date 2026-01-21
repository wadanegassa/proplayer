import 'package:flutter/material.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import 'package:video_player/video_player.dart' as vp;
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:io';
import 'dart:async';
import '../models/media_item.dart';
import '../providers/home_provider.dart';
// app_theme removed; use Theme.of(context)

class VideoPlayerScreen extends StatefulWidget {
  final MediaItem mediaItem;

  const VideoPlayerScreen({super.key, required this.mediaItem});

  @override
  State<VideoPlayerScreen> createState() => _VideoPlayerScreenState();
}

class _VideoPlayerScreenState extends State<VideoPlayerScreen> {
  YoutubePlayerController? _youtubeController;
  vp.VideoPlayerController? _localController;
  bool _isLocalVideo = false;
  bool _showControls = true;
  Timer? _hideTimer;

  @override
  void initState() {
    super.initState();
    _isLocalVideo = widget.mediaItem.isLocal;

    if (_isLocalVideo) {
      _localController = vp.VideoPlayerController.file(
        File(widget.mediaItem.id),
      )..initialize().then((_) {
          setState(() {});
          _localController!.play();
          _startHideTimer();
        });
    } else {
      _youtubeController = YoutubePlayerController(
        initialVideoId: widget.mediaItem.id,
        flags: const YoutubePlayerFlags(
          autoPlay: true,
          mute: false,
          enableCaption: false,
          forceHD: true,
        ),
      );
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<HomeProvider>(context, listen: false)
          .addToHistory(widget.mediaItem);
    });
  }

  void _startHideTimer() {
    _hideTimer?.cancel();
    _hideTimer = Timer(const Duration(seconds: 3), () {
      if (mounted) setState(() => _showControls = false);
    });
  }

  void _toggleControls() {
    setState(() {
      _showControls = !_showControls;
      if (_showControls) _startHideTimer();
    });
  }

  @override
  void dispose() {
    _youtubeController?.dispose();
    _localController?.dispose();
    _hideTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: GestureDetector(
        onTap: _toggleControls,
        onDoubleTapDown: (details) {
          final width = MediaQuery.of(context).size.width;
          if (details.globalPosition.dx < width / 2) {
            _seekRelative(-10);
          } else {
            _seekRelative(10);
          }
        },
        child: Stack(
          alignment: Alignment.center,
          children: [
            Center(
              child: _isLocalVideo
                  ? _buildLocalVideoPlayer()
                  : _buildYouTubePlayer(),
            ),
            if (_showControls) _buildOverlayControls(),
          ],
        ),
      ),
    );
  }

  void _seekRelative(int seconds) {
    if (_isLocalVideo && _localController != null) {
      final newPos = _localController!.value.position + Duration(seconds: seconds);
      _localController!.seekTo(newPos);
    } else if (_youtubeController != null) {
      final current = _youtubeController!.value.position;
      _youtubeController!.seekTo(current + Duration(seconds: seconds));
    }
    _showSeekFeedback(seconds > 0);
  }

  void _showSeekFeedback(bool forward) {
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(forward ? Icons.fast_forward_rounded : Icons.fast_rewind_rounded, color: Colors.white),
            const SizedBox(width: 8),
            Text(forward ? '+10s' : '-10s', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ],
        ),
        duration: const Duration(milliseconds: 500),
        backgroundColor: Colors.black.withValues(alpha: 0.6),
        behavior: SnackBarBehavior.floating,
        width: 120,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(32)),
      ),
    );
  }

  Widget _buildYouTubePlayer() {
    final theme = Theme.of(context);
    if (_youtubeController == null) {
      return const CircularProgressIndicator();
    }
    return YoutubePlayer(
      controller: _youtubeController!,
      showVideoProgressIndicator: true,
      progressIndicatorColor: theme.colorScheme.primary,
      bottomActions: [
        CurrentPosition(),
        ProgressBar(
          isExpanded: true,
          colors: ProgressBarColors(
            playedColor: theme.colorScheme.primary,
            handleColor: theme.colorScheme.primary,
            bufferedColor: Colors.white.withValues(alpha: 0.3),
            backgroundColor: Colors.white.withValues(alpha: 0.1),
          ),
        ),
        RemainingDuration(),
        const PlaybackSpeedButton(),
        FullScreenButton(),
      ],
    );
  }

  Widget _buildLocalVideoPlayer() {
    final theme = Theme.of(context);

    if (_localController == null || !_localController!.value.isInitialized) {
      return CircularProgressIndicator(color: theme.colorScheme.primary);
    }
    return AspectRatio(
      aspectRatio: _localController!.value.aspectRatio,
      child: vp.VideoPlayer(_localController!),
    );
  }

  Widget _buildOverlayControls() {
    final theme = Theme.of(context);

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.black.withValues(alpha: 0.7),
            Colors.transparent,
            Colors.black.withValues(alpha: 0.7),
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: SafeArea(
        child: Column(
          children: [
            // Top Bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.keyboard_arrow_down_rounded, color: Colors.white, size: 32),
                    onPressed: () => Navigator.pop(context),
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.mediaItem.title,
                          style: GoogleFonts.outfit(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          widget.mediaItem.subtitle,
                          style: GoogleFonts.outfit(
                            color: Colors.white.withValues(alpha: 0.6),
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.more_vert_rounded, color: Colors.white),
                    onPressed: () {},
                  ),
                ],
              ),
            ),
            const Spacer(),
            // Center Controls
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  icon: const Icon(Icons.replay_10_rounded, color: Colors.white, size: 40),
                  onPressed: () => _seekRelative(-10),
                ),
                const SizedBox(width: 32),
                GestureDetector(
                  onTap: () {
                    setState(() {
                      if (_isLocalVideo) {
                        _localController!.value.isPlaying
                            ? _localController!.pause()
                            : _localController!.play();
                      } else {
                        _youtubeController!.value.isPlaying
                            ? _youtubeController!.pause()
                            : _youtubeController!.play();
                      }
                      _startHideTimer();
                    });
                  },
                  child: Container(
                    height: 80,
                    width: 80,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: theme.colorScheme.primary.withValues(alpha: 0.9),
                      boxShadow: [
                        BoxShadow(
                          color: theme.colorScheme.primary.withValues(alpha: 0.4),
                          blurRadius: 20,
                        ),
                      ],
                    ),
                    child: Icon(
                      (_isLocalVideo ? _localController!.value.isPlaying : _youtubeController!.value.isPlaying)
                          ? Icons.pause_rounded
                          : Icons.play_arrow_rounded,
                      color: Colors.white,
                      size: 48,
                    ),
                  ),
                ),
                const SizedBox(width: 32),
                IconButton(
                  icon: const Icon(Icons.forward_10_rounded, color: Colors.white, size: 40),
                  onPressed: () => _seekRelative(10),
                ),
              ],
            ),
            const Spacer(),
            // Bottom Controls
            if (_isLocalVideo)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  children: [
                    vp.VideoProgressIndicator(
                      _localController!,
                      allowScrubbing: true,
                      colors: vp.VideoProgressColors(
                        playedColor: theme.colorScheme.primary,
                        bufferedColor: Colors.white.withValues(alpha: 0.3),
                        backgroundColor: Colors.white.withValues(alpha: 0.1),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        ValueListenableBuilder(
                          valueListenable: _localController!,
                          builder: (context, vp.VideoPlayerValue value, child) {
                            return Text(
                              _formatDuration(value.position),
                              style: const TextStyle(color: Colors.white70, fontSize: 12),
                            );
                          },
                        ),
                        Text(
                          _formatDuration(_localController!.value.duration),
                          style: const TextStyle(color: Colors.white70, fontSize: 12),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  IconButton(
                    icon: const Icon(Icons.shuffle_rounded, color: Colors.white70),
                    onPressed: () {},
                  ),
                  IconButton(
                    icon: const Icon(Icons.favorite_border_rounded, color: Colors.white70),
                    onPressed: () {},
                  ),
                  IconButton(
                    icon: const Icon(Icons.repeat_rounded, color: Colors.white70),
                    onPressed: () {},
                  ),
                  IconButton(
                    icon: const Icon(Icons.playlist_play_rounded, color: Colors.white70),
                    onPressed: () {},
                  ),
                ],
              ),
            ),
          ],
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
