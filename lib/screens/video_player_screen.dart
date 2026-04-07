import 'dart:async';
import 'dart:io';
import 'dart:ui';

import 'package:flutter/foundation.dart' show kIsWeb, defaultTargetPlatform, TargetPlatform;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:video_player/video_player.dart' as vp;
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

import '../models/media_item.dart';
import '../providers/home_provider.dart';
import '../services/youtube_service.dart';
import '../theme/app_theme.dart';

class VideoPlayerScreen extends StatefulWidget {
  final MediaItem mediaItem;

  const VideoPlayerScreen({super.key, required this.mediaItem});

  @override
  State<VideoPlayerScreen> createState() => _VideoPlayerScreenState();
}

class _VideoPlayerScreenState extends State<VideoPlayerScreen> {
  YoutubePlayerController? _youtubeController;
  vp.VideoPlayerController? _localController;
  vp.VideoPlayerController? _youtubeStreamController;
  bool _isLocalVideo = false;
  bool _showControls = true;
  Timer? _hideTimer;
  Timer? _seekFlashTimer;
  bool _youtubeReady = false;
  bool _ytPlaying = false;
  bool _localPlaying = false;
  bool _youtubeStreamPlaying = false;
  bool _youtubeResolving = false;
  int? _seekFlashSeconds;

  @override
  void initState() {
    super.initState();
    _isLocalVideo = widget.mediaItem.isLocal;

    WidgetsBinding.instance.addPostFrameCallback((_) => _syncSystemChrome());

    if (_isLocalVideo) {
      _localController = vp.VideoPlayerController.file(File(widget.mediaItem.id))
        ..initialize().then((_) {
          if (mounted) {
            setState(() {});
            _localController!.play();
            _startHideTimer();
          }
        });
      _localController!.addListener(_onLocalTick);
    } else {
      _youtubeResolving = true;
      _initYoutubePlayback();
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<HomeProvider>(context, listen: false).addToHistory(widget.mediaItem);
    });
  }

  Future<void> _initYoutubePlayback() async {
    final raw = widget.mediaItem.id.trim();
    final videoId = YoutubePlayer.convertUrlToId(raw) ?? raw;

    final yt = YouTubeService();
    Uri? direct;
    try {
      direct = await yt.resolveDirectPlayableUri(videoId);
    } catch (e) {
      debugPrint('YouTube resolveDirectPlayableUri: $e');
    } finally {
      yt.dispose();
    }

    if (!mounted) return;

    if (direct != null) {
      final c = vp.VideoPlayerController.networkUrl(
        direct,
        httpHeaders: YouTubeService.directPlaybackHttpHeaders,
      );
      try {
        await c.initialize();
        if (!mounted) {
          await c.dispose();
          return;
        }
        _youtubeStreamController = c;
        _youtubeStreamController!.addListener(_onYoutubeStreamTick);
        await c.play();
        setState(() {
          _youtubeResolving = false;
          _youtubeStreamPlaying = true;
        });
        _startHideTimer();
        return;
      } catch (e) {
        debugPrint('YouTube VideoPlayer failed, falling back to iframe: $e');
        await c.dispose();
        _youtubeStreamController = null;
      }
    }

    if (!mounted) return;

    final useHybridComposition = kIsWeb || defaultTargetPlatform != TargetPlatform.android;
    _youtubeController = YoutubePlayerController(
      initialVideoId: videoId,
      flags: YoutubePlayerFlags(
        autoPlay: true,
        mute: false,
        enableCaption: false,
        forceHD: false,
        hideControls: true,
        controlsVisibleAtStart: false,
        useHybridComposition: useHybridComposition,
      ),
    )..addListener(_onYoutubeTick);

    setState(() => _youtubeResolving = false);
  }

  void _syncSystemChrome() {
    if (!mounted) return;
    final theme = Theme.of(context);
    final dark = theme.brightness == Brightness.dark;
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: dark ? Brightness.light : Brightness.dark,
      systemNavigationBarColor: theme.scaffoldBackgroundColor,
      systemNavigationBarIconBrightness: dark ? Brightness.light : Brightness.dark,
    ));
  }

  void _onLocalTick() {
    if (!mounted || _localController == null) return;
    final playing = _localController!.value.isPlaying;
    if (playing != _localPlaying) {
      _localPlaying = playing;
      setState(() {});
    }
  }

  void _onYoutubeTick() {
    if (!mounted) return;
    final c = _youtubeController;
    if (c == null) return;
    final v = c.value;
    final ready = v.isReady;
    final playing = v.isPlaying;
    if (ready != _youtubeReady || playing != _ytPlaying) {
      _youtubeReady = ready;
      _ytPlaying = playing;
      setState(() {});
    }
  }

  void _onYoutubeStreamTick() {
    if (!mounted || _youtubeStreamController == null) return;
    final playing = _youtubeStreamController!.value.isPlaying;
    if (playing != _youtubeStreamPlaying) {
      _youtubeStreamPlaying = playing;
      setState(() {});
    }
  }

  void _startHideTimer() {
    _hideTimer?.cancel();
    _hideTimer = Timer(const Duration(seconds: 4), () {
      if (mounted) setState(() => _showControls = false);
    });
  }

  void _touchUi() {
    setState(() => _showControls = true);
    _startHideTimer();
  }

  @override
  void dispose() {
    _youtubeController?.removeListener(_onYoutubeTick);
    _youtubeStreamController?.removeListener(_onYoutubeStreamTick);
    _localController?.removeListener(_onLocalTick);
    _youtubeController?.dispose();
    _youtubeStreamController?.dispose();
    _localController?.dispose();
    _hideTimer?.cancel();
    _seekFlashTimer?.cancel();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    super.dispose();
  }

  void _showVideoMenu() {
    final theme = Theme.of(context);
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: theme.colorScheme.surface,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.copy_rounded),
                title: Text(_isLocalVideo ? 'Copy path' : 'Copy link'),
                onTap: () {
                   Navigator.pop(ctx);
                   final text = _isLocalVideo ? widget.mediaItem.id : 'https://youtube.com/watch?v=${widget.mediaItem.id}';
                   Clipboard.setData(ClipboardData(text: text));
                },
              ),
              ListTile(
                leading: const Icon(Icons.share_rounded),
                title: const Text('Share'),
                onTap: () => Navigator.pop(ctx),
              ),
            ],
          ),
        );
      },
    );
  }

  void _seekRelative(int seconds) {
    if (_isLocalVideo && _localController != null) {
      _localController!.seekTo(_localController!.value.position + Duration(seconds: seconds));
    } else if (_youtubeStreamController != null) {
      _youtubeStreamController!.seekTo(_youtubeStreamController!.value.position + Duration(seconds: seconds));
    } else if (_youtubeController != null) {
      _youtubeController!.seekTo(_youtubeController!.value.position + Duration(seconds: seconds));
    }
    _flashSeek(seconds);
    _touchUi();
  }

  void _flashSeek(int delta) {
    _seekFlashTimer?.cancel();
    setState(() => _seekFlashSeconds = delta);
    _seekFlashTimer = Timer(const Duration(milliseconds: 700), () {
      if (mounted) setState(() => _seekFlashSeconds = null);
    });
  }

  bool get _isPlaying {
    if (_isLocalVideo) return _localPlaying;
    if (_youtubeStreamController != null) return _youtubeStreamPlaying;
    return _ytPlaying;
  }

  void _togglePlayPause() {
    if (_isLocalVideo && _localController != null) {
      _localController!.value.isPlaying ? _localController!.pause() : _localController!.play();
    } else if (_youtubeStreamController != null) {
      _youtubeStreamController!.value.isPlaying ? _youtubeStreamController!.pause() : _youtubeStreamController!.play();
    } else if (_youtubeController != null) {
      _youtubeController!.value.isPlaying ? _youtubeController!.pause() : _youtubeController!.play();
    }
    _touchUi();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final size = MediaQuery.sizeOf(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            // —— HEADER ———————————————————————————————————————————————
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.arrow_back_ios_new_rounded),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'VIDEO',
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: AppTheme.primary,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 4,
                          ),
                        ),
                        Text(
                          widget.mediaItem.title,
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: _showVideoMenu,
                    icon: const Icon(Icons.more_horiz_rounded),
                  ),
                ],
              ),
            ),

            const Spacer(),

            // —— VIDEO PLAYER AREA —————————————————————————————————————
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 24),
              width: double.infinity,
              height: size.width * 0.56,
              decoration: BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.circular(32),
                boxShadow: [
                   BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 30, offset: const Offset(0, 10)),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(32),
                child: GestureDetector(
                  onTap: _touchUi,
                  onDoubleTapDown: (details) {
                    final tapX = details.localPosition.dx;
                    final width = size.width - 48; // Total width is size.width - 24 left margin - 24 right margin
                    if (tapX < width / 2) {
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
                            ? _buildLocalVideo(theme)
                            : _youtubeResolving
                                ? _buildBlurredThumbnail()
                                : (_youtubeStreamController != null)
                                    ? _buildYoutubeStreamVideo(theme)
                                    : _buildYouTubePlayer(theme),
                      ),
                      if (_seekFlashSeconds != null)
                        Positioned(
                          left: _seekFlashSeconds! < 0 ? 0 : null,
                          right: _seekFlashSeconds! > 0 ? 0 : null,
                          top: 0,
                          bottom: 0,
                          width: (size.width - 48) / 2,
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.horizontal(
                                left: Radius.circular(_seekFlashSeconds! > 0 ? 0 : 32),
                                right: Radius.circular(_seekFlashSeconds! > 0 ? 32 : 0),
                              ),
                            ),
                            child: Center(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    _seekFlashSeconds! > 0 ? Icons.fast_forward_rounded : Icons.fast_rewind_rounded,
                                    color: Colors.white,
                                    size: 48,
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    '${_seekFlashSeconds!.abs()}s',
                                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),

            const Spacer(),

            // —— METADATA —————————————————————————————————————————————
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40),
              child: Column(
                children: [
                  Text(
                    widget.mediaItem.title,
                    textAlign: TextAlign.center,
                    style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w900),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    widget.mediaItem.subtitle,
                    textAlign: TextAlign.center,
                    style: theme.textTheme.titleMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                  ),
                ],
              ),
            ),

            const Spacer(),

            // —— CONTROLS & SLIDER —————————————————————————————————————
            AnimatedOpacity(
              opacity: _showControls ? 1.0 : 0.0,
              duration: const Duration(milliseconds: 300),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Column(
                  children: [
                    _buildScrubber(theme),
                    const SizedBox(height: 40),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        IconButton(
                          onPressed: () => _seekRelative(-10),
                          icon: const Icon(Icons.replay_10_rounded, size: 32),
                        ),
                        GestureDetector(
                          onTap: _togglePlayPause,
                          child: Container(
                            width: 72,
                            height: 72,
                            decoration: BoxDecoration(color: theme.colorScheme.onSurface, shape: BoxShape.circle),
                            child: Icon(
                              _isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
                              size: 40,
                              color: theme.colorScheme.surface,
                            ),
                          ),
                        ),
                        IconButton(
                          onPressed: () => _seekRelative(10),
                          icon: const Icon(Icons.forward_10_rounded, size: 32),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const Spacer(flex: 2),
          ],
        ),
      ),
    );
  }

  Widget _buildBlurredThumbnail() {
    return Stack(
      fit: StackFit.expand,
      children: [
        if (widget.mediaItem.thumbnail != null)
          Image.network(widget.mediaItem.thumbnail!, fit: BoxFit.cover),
        if (widget.mediaItem.thumbnailBytes != null)
          Image.memory(widget.mediaItem.thumbnailBytes!, fit: BoxFit.cover),
        BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(color: Colors.black.withValues(alpha: 0.3)),
        ),
        const Center(child: CircularProgressIndicator(color: AppTheme.primary)),
      ],
    );
  }

  Widget _buildLocalVideo(ThemeData theme) {
    if (_localController == null || !_localController!.value.isInitialized) return Container();
    return AspectRatio(aspectRatio: _localController!.value.aspectRatio, child: vp.VideoPlayer(_localController!));
  }

  Widget _buildYoutubeStreamVideo(ThemeData theme) {
    if (_youtubeStreamController == null || !_youtubeStreamController!.value.isInitialized) return Container();
    return AspectRatio(aspectRatio: _youtubeStreamController!.value.aspectRatio, child: vp.VideoPlayer(_youtubeStreamController!));
  }

  Widget _buildYouTubePlayer(ThemeData theme) {
    if (_youtubeController == null) return Container();
    return YoutubePlayer(controller: _youtubeController!, showVideoProgressIndicator: true, progressIndicatorColor: AppTheme.primary);
  }

  Widget _buildScrubber(ThemeData theme) {
    Duration position = Duration.zero;
    Duration duration = Duration.zero;
    if (_isLocalVideo && _localController != null) {
      position = _localController!.value.position;
      duration = _localController!.value.duration;
    } else if (_youtubeStreamController != null) {
      position = _youtubeStreamController!.value.position;
      duration = _youtubeStreamController!.value.duration;
    } else if (_youtubeController != null) {
      position = _youtubeController!.value.position;
      duration = _youtubeController!.metadata.duration;
    }

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(_formatDuration(position), style: theme.textTheme.bodySmall?.copyWith(fontWeight: FontWeight.bold)),
            Text(_formatDuration(duration), style: theme.textTheme.bodySmall?.copyWith(fontWeight: FontWeight.bold)),
          ],
        ),
        const SizedBox(height: 12),
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            trackHeight: 4,
            thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
            overlayShape: SliderComponentShape.noOverlay,
            activeTrackColor: theme.colorScheme.onSurface,
            inactiveTrackColor: theme.colorScheme.onSurface.withValues(alpha: 0.15),
            thumbColor: theme.colorScheme.onSurface,
          ),
          child: Slider(
            value: duration.inSeconds > 0 ? (position.inSeconds / duration.inSeconds).clamp(0.0, 1.0) : 0.0,
            onChanged: (v) {
              final newPos = Duration(seconds: (v * duration.inSeconds).toInt());
              if (_isLocalVideo) {
                _localController?.seekTo(newPos);
              } else if (_youtubeStreamController != null) {
                _youtubeStreamController?.seekTo(newPos);
              } else {
                _youtubeController?.seekTo(newPos);
              }
            },
          ),
        ),
      ],
    );
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final m = duration.inMinutes.remainder(60);
    final s = duration.inSeconds.remainder(60);
    return '${twoDigits(m)}:${twoDigits(s)}';
  }
}
