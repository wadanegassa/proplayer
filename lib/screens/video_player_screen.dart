import 'package:flutter/material.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import 'package:video_player/video_player.dart' as vp;
import 'package:provider/provider.dart';
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
    // Force a dark background for the video player so it remains black even in light theme
    const backgroundColor = Colors.black;

    return Scaffold(
      backgroundColor: backgroundColor,
      body: GestureDetector(
        onTap: _toggleControls,
        onDoubleTapDown: (details) {
          final width = MediaQuery.of(context).size.width;
          if (details.globalPosition.dx < width / 2) {
            // Seek backward 10s
            _seekRelative(-10);
          } else {
            // Seek forward 10s
            _seekRelative(10);
          }
        },
        onVerticalDragUpdate: (details) {
          // Simple volume/brightness simulation
          // In a real app, use system_setting or screen_brightness packages
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
    // Show temporary icon overlay
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(forward ? Icons.fast_forward : Icons.fast_rewind, color: Colors.white),
            const SizedBox(width: 8),
            Text(forward ? '+10s' : '-10s', style: TextStyle(color: Colors.white)),
          ],
        ),
        duration: const Duration(milliseconds: 500),
        backgroundColor: Colors.black.withAlpha(160),
        behavior: SnackBarBehavior.floating,
        width: 100,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
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
        ProgressBar(isExpanded: true, colors: ProgressBarColors(
          playedColor: theme.colorScheme.primary,
          handleColor: theme.colorScheme.primary,
        )),
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

    // Overlay dark gradient so controls are visible on top of the black video background
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.black.withAlpha(200), Colors.transparent, Colors.black.withAlpha(200)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: SafeArea(
        child: Column(
          children: [
            // Top Bar
            Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.white),
                  onPressed: () => Navigator.pop(context),
                ),
                Expanded(
                  child: Text(
                    widget.mediaItem.title,
                    style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.more_vert, color: Colors.white),
                  onPressed: () {},
                ),
              ],
            ),
            const Spacer(),
            // Center Play/Pause (only for local, YouTube has its own)
            if (_isLocalVideo)
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    icon: const Icon(Icons.replay_10, color: Colors.white, size: 32),
                    onPressed: () => _seekRelative(-10),
                  ),
                  const SizedBox(width: 20),
                  Container(
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary.withAlpha(204),
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      icon: Icon(
                        _localController!.value.isPlaying ? Icons.pause : Icons.play_arrow,
                        color: theme.colorScheme.onPrimary,
                        size: 40,
                      ),
                      onPressed: () {
                        setState(() {
                          _localController!.value.isPlaying
                              ? _localController!.pause()
                              : _localController!.play();
                          _startHideTimer();
                        });
                      },
                    ),
                  ),
                  const SizedBox(width: 20),
                  IconButton(
                    icon: const Icon(Icons.forward_10, color: Colors.white, size: 32),
                    onPressed: () => _seekRelative(10),
                  ),
                ],
              ),
            const Spacer(),
            // Bottom Bar (only for local)
            if (_isLocalVideo)
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: vp.VideoProgressIndicator(
                  _localController!,
                  allowScrubbing: true,
                  colors: vp.VideoProgressColors(
                    playedColor: theme.colorScheme.primary,
                    bufferedColor: Colors.white.withAlpha(90),
                    backgroundColor: Colors.white.withAlpha(24),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
