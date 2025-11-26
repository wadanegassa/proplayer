import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'dart:async';
import 'package:photo_manager/photo_manager.dart';
import 'package:flutter/services.dart';

class VideoPlayerScreen extends StatefulWidget {
  final AssetEntity video;

  const VideoPlayerScreen({super.key, required this.video});

  @override
  State<VideoPlayerScreen> createState() => _VideoPlayerScreenState();
}

class _VideoPlayerScreenState extends State<VideoPlayerScreen> {
  VideoPlayerController? _controller;
  bool _isLoading = true;
  bool _showControls = true;
  Timer? _hideTimer;
  TapDownDetails? _lastTapDownDetails;

  @override
  void initState() {
    super.initState();
    _initializeVideo();
  }

  Future<void> _initializeVideo() async {
    final file = await widget.video.file;
    if (file == null) {
      return;
    }
    _controller = VideoPlayerController.file(file);
    await _controller!.initialize();
    _controller!.addListener(() {
      // update UI on controller changes (position/playback)
      if (mounted) setState(() {});
    });

    // Start playing immediately
    await _controller!.play();

    // Start hide-controls timer
    _startHideTimer();

    setState(() => _isLoading = false);
  }

  @override
  void dispose() {
    _hideTimer?.cancel();
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(widget.video.title ?? 'Video'),
        backgroundColor: theme.scaffoldBackgroundColor,
        elevation: 0,
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator(color: theme.colorScheme.primary))
          : LayoutBuilder(
              builder: (context, constraints) {
                final screenWidth = constraints.maxWidth;
                final videoHeight = screenWidth / (_controller!.value.aspectRatio);

                return Center(
                  child: Container(
                    width: screenWidth,
                    height: videoHeight,
                    decoration: BoxDecoration(
                      color: theme.canvasColor,
                      borderRadius: MediaQuery.of(context).orientation == Orientation.portrait
                          ? BorderRadius.circular(16)
                          : BorderRadius.zero,
                      boxShadow: [
                        BoxShadow(
                          color: theme.shadowColor.withAlpha(128),
                          blurRadius: 12,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    clipBehavior: Clip.hardEdge,
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        // Video
                        VideoPlayer(_controller!),

                        // Gesture layer for taps / double taps
                        GestureDetector(
                          behavior: HitTestBehavior.opaque,
                          onTapDown: (details) => _lastTapDownDetails = details,
                          onTap: _toggleControls,
                          onDoubleTap: () => _handleDoubleTap(constraints),
                        ),

                        // Controls overlay
                        if (_showControls) _buildControlsOverlay(context),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }

  void _toggleControls() {
    setState(() {
      _showControls = !_showControls;
    });
    if (_showControls) {
      _startHideTimer();
    } else {
      _hideTimer?.cancel();
    }
  }

  void _startHideTimer() {
    _hideTimer?.cancel();
    _hideTimer = Timer(const Duration(seconds: 3), () {
      if (mounted) {
        setState(() => _showControls = false);
      }
    });
  }

  void _handleDoubleTap(BoxConstraints constraints) {
    if (_lastTapDownDetails == null || _controller == null) {
      return;
    }
    final dx = _lastTapDownDetails!.localPosition.dx;
    final width = constraints.maxWidth;
    final isLeft = dx < width / 2;
    final current = _controller!.value.position;
    final seekBy = const Duration(seconds: 10);
    final target = isLeft ? current - seekBy : current + seekBy;
    _controller!.seekTo(target >= Duration.zero ? target : Duration.zero);
    // show controls when seeking
    setState(() => _showControls = true);
    _startHideTimer();
  }

  Widget _buildControlsOverlay(BuildContext context) {
    final duration = _controller!.value.duration;
    final position = _controller!.value.position;
    

    String fmt(Duration d) {
      String two(int n) => n.toString().padLeft(2, '0');
      final hours = d.inHours;
      final minutes = d.inMinutes.remainder(60);
      final seconds = d.inSeconds.remainder(60);
      return hours > 0
          ? '${two(hours)}:${two(minutes)}:${two(seconds)}'
          : '${two(minutes)}:${two(seconds)}';
    }

    return Column(
      children: [
        // Top gradient with title
        Expanded(
          child: Align(
            alignment: Alignment.topCenter,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.black54, Colors.transparent],
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      widget.video.title ?? 'Video',
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.white),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
            ),
          ),
        ),

        // Bottom controls
        Container(
          color: Colors.black45,
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // progress bar
              Row(
                children: [
                  Text(fmt(position), style: const TextStyle(color: Colors.white, fontSize: 12)),
                  Expanded(
                    child: SliderTheme(
                      data: SliderTheme.of(context).copyWith(
                        trackHeight: 4,
                        thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
                      ),
                      child: Slider(
                        min: 0,
                        max: duration.inMilliseconds.toDouble(),
                        value: position.inMilliseconds.clamp(0, duration.inMilliseconds).toDouble(),
                        onChanged: (value) {
                          _controller!.seekTo(Duration(milliseconds: value.toInt()));
                        },
                      ),
                    ),
                  ),
                  Text(fmt(duration), style: const TextStyle(color: Colors.white, fontSize: 12)),
                ],
              ),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    icon: const Icon(Icons.replay_10, color: Colors.white),
                    onPressed: () {
                      final current = _controller!.value.position;
                      final target = current - const Duration(seconds: 10);
                      _controller!.seekTo(target >= Duration.zero ? target : Duration.zero);
                      _startHideTimer();
                    },
                  ),
                  IconButton(
                    icon: Icon(_controller!.value.isPlaying ? Icons.pause_circle_filled : Icons.play_circle_filled, color: Colors.white, size: 36),
                    onPressed: () {
                      if (_controller!.value.isPlaying) {
                        _controller!.pause();
                      } else {
                        _controller!.play();
                      }
                      _startHideTimer();
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.forward_10, color: Colors.white),
                    onPressed: () {
                      final current = _controller!.value.position;
                      final target = current + const Duration(seconds: 10);
                      _controller!.seekTo(target <= _controller!.value.duration ? target : _controller!.value.duration);
                      _startHideTimer();
                    },
                  ),
                  const SizedBox(width: 12),
                  IconButton(
                    icon: const Icon(Icons.fullscreen, color: Colors.white),
                    onPressed: () async {
                      // push full screen route
                      await Navigator.of(context).push(MaterialPageRoute(builder: (ctx) => _FullScreenPlayer(controller: _controller!)));
                      // restore status/navigation bars
                      SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

}

class _FullScreenPlayer extends StatelessWidget {
  final VideoPlayerController controller;
  const _FullScreenPlayer({required this.controller});

  @override
  Widget build(BuildContext context) {
    // hide system UI
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: AspectRatio(
          aspectRatio: controller.value.aspectRatio,
          child: VideoPlayer(controller),
        ),
      ),
    );
  }
}
