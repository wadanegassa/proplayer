import 'dart:async';
import 'dart:io';

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
import '../widgets/neumorphic_widgets.dart';

class VideoPlayerScreen extends StatefulWidget {
  final MediaItem mediaItem;

  const VideoPlayerScreen({super.key, required this.mediaItem});

  @override
  State<VideoPlayerScreen> createState() => _VideoPlayerScreenState();
}

class _VideoPlayerScreenState extends State<VideoPlayerScreen> {
  YoutubePlayerController? _youtubeController;
  vp.VideoPlayerController? _localController;
  /// YouTube via [youtube_explode_dart] + [video_player] (avoids broken WebViews).
  vp.VideoPlayerController? _youtubeStreamController;
  bool _isLocalVideo = false;
  bool _showControls = true;
  Timer? _hideTimer;
  Timer? _seekFlashTimer;
  bool _youtubeReady = false;
  bool _ytPlaying = false;
  bool _localPlaying = false;
  bool _youtubeStreamPlaying = false;
  /// True while resolving direct stream or before iframe controller is ready to show.
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

    final useHybridComposition =
        kIsWeb || defaultTargetPlatform != TargetPlatform.android;
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

  String get _watchUrl {
    final raw = widget.mediaItem.id.trim();
    final id = YoutubePlayer.convertUrlToId(raw) ?? raw;
    return 'https://www.youtube.com/watch?v=$id';
  }

  Future<void> _copyLink() async {
    final text = _isLocalVideo ? widget.mediaItem.id : _watchUrl;
    await Clipboard.setData(ClipboardData(text: text));
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(_isLocalVideo ? 'File path copied' : 'Link copied')),
      );
    }
  }

  void _showVideoMenu() {
    final theme = Theme.of(context);
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: theme.bottomSheetTheme.backgroundColor ?? theme.colorScheme.surface,
      shape: theme.bottomSheetTheme.shape ??
          const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
      builder: (ctx) {
        final t = Theme.of(ctx);
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: Icon(Icons.link_rounded, color: t.colorScheme.primary),
                title: Text(_isLocalVideo ? 'Copy file path' : 'Copy video link'),
                onTap: () {
                  Navigator.pop(ctx);
                  _copyLink();
                },
              ),
              if (!_isLocalVideo)
                ListTile(
                  leading: Icon(Icons.info_outline_rounded, color: t.colorScheme.onSurfaceVariant),
                  title: Text(
                    'ID: ${widget.mediaItem.id}',
                    style: t.textTheme.bodySmall?.copyWith(color: t.colorScheme.onSurfaceVariant),
                  ),
                ),
              ListTile(
                leading: Icon(Icons.title_rounded, color: t.colorScheme.primary),
                title: const Text('Copy title'),
                onTap: () async {
                  Navigator.pop(ctx);
                  await Clipboard.setData(ClipboardData(text: widget.mediaItem.title));
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Title copied')),
                    );
                  }
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _seekRelative(int seconds) {
    if (_isLocalVideo && _localController != null && _localController!.value.isInitialized) {
      final newPos = _localController!.value.position + Duration(seconds: seconds);
      _localController!.seekTo(newPos);
    } else if (_youtubeStreamController != null &&
        _youtubeStreamController!.value.isInitialized) {
      final newPos =
          _youtubeStreamController!.value.position + Duration(seconds: seconds);
      _youtubeStreamController!.seekTo(newPos);
    } else if (_youtubeController != null && _youtubeController!.value.isReady) {
      final current = _youtubeController!.value.position;
      _youtubeController!.seekTo(current + Duration(seconds: seconds));
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
      if (_localController!.value.isPlaying) {
        _localController!.pause();
        _localPlaying = false;
      } else {
        _localController!.play();
        _localPlaying = true;
      }
    } else if (_youtubeStreamController != null) {
      if (_youtubeStreamController!.value.isPlaying) {
        _youtubeStreamController!.pause();
        _youtubeStreamPlaying = false;
      } else {
        _youtubeStreamController!.play();
        _youtubeStreamPlaying = true;
      }
    } else if (_youtubeController != null) {
      if (_youtubeController!.value.isPlaying) {
        _youtubeController!.pause();
        _ytPlaying = false;
      } else {
        _youtubeController!.play();
        _ytPlaying = true;
      }
    }
    setState(() {});
    _touchUi();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: Column(
          children: [
            // —— HEADER ———————————————————————————————————————————————
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  NeumorphicButton(
                    size: 44,
                    onPressed: () => Navigator.pop(context),
                    child: const Icon(Icons.arrow_back_rounded, color: Colors.white70),
                  ),
                  Expanded(
                    child: Column(
                      children: [
                        Text(
                          'VIDEO PLAYER',
                          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                            color: Colors.white38,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 2,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          widget.mediaItem.title,
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                  NeumorphicButton(
                    size: 44,
                    onPressed: _showVideoMenu,
                    child: const Icon(Icons.menu_rounded, color: Colors.white70),
                  ),
                ],
              ),
            ),

            const Spacer(),

            // —— VIDEO PLAYER AREA —————————————————————————————————————
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: NeumorphicContainer(
                width: double.infinity,
                height: 220,
                borderRadius: 24,
                padding: const EdgeInsets.all(8),
                depth: 12,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: GestureDetector(
                    onTap: _touchUi,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        Center(
                          child: _isLocalVideo
                              ? _buildLocalVideo(theme)
                              : _youtubeResolving
                                  ? const CircularProgressIndicator(color: AppTheme.brand)
                                  : (_youtubeStreamController != null)
                                      ? _buildYoutubeStreamVideo(theme)
                                      : _buildYouTubePlayer(theme),
                        ),
                        if (_seekFlashSeconds != null)
                          Container(
                            color: Colors.black26,
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
                      ],
                    ),
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
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w800,
                      fontSize: 22,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    widget.mediaItem.subtitle,
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: Colors.white38,
                    ),
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
                    const SizedBox(height: 32),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        NeumorphicButton(
                          size: 56,
                          onPressed: () => _seekRelative(-10),
                          child: const Icon(Icons.replay_10_rounded, color: Colors.white70),
                        ),
                        NeumorphicButton(
                          size: 72,
                          isAccent: true,
                          onPressed: _togglePlayPause,
                          child: Icon(
                            _isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
                            size: 34,
                            color: Colors.white,
                          ),
                        ),
                        NeumorphicButton(
                          size: 56,
                          onPressed: () => _seekRelative(10),
                          child: const Icon(Icons.forward_10_rounded, color: Colors.white70),
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

  Widget _buildLocalVideo(ThemeData theme) {
    if (_localController == null || !_localController!.value.isInitialized) {
      return const CircularProgressIndicator(color: AppTheme.brand);
    }
    return AspectRatio(
      aspectRatio: _localController!.value.aspectRatio,
      child: vp.VideoPlayer(_localController!),
    );
  }

  Widget _buildYoutubeStreamVideo(ThemeData theme) {
    if (_youtubeStreamController == null || !_youtubeStreamController!.value.isInitialized) {
      return const CircularProgressIndicator(color: AppTheme.brand);
    }
    return AspectRatio(
      aspectRatio: _youtubeStreamController!.value.aspectRatio,
      child: vp.VideoPlayer(_youtubeStreamController!),
    );
  }

  Widget _buildYouTubePlayer(ThemeData theme) {
    if (_youtubeController == null) {
      return const Text('YouTube initialization failed', style: TextStyle(color: Colors.white24));
    }
    return YoutubePlayer(
      controller: _youtubeController!,
      showVideoProgressIndicator: true,
      progressIndicatorColor: AppTheme.brand,
    );
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

    final progress = duration.inSeconds > 0 
        ? (position.inSeconds / duration.inSeconds).clamp(0.0, 1.0)
        : 0.0;

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(_formatDuration(position), style: const TextStyle(color: Colors.white38, fontSize: 11)),
            Text(_formatDuration(duration), style: const TextStyle(color: Colors.white38, fontSize: 11)),
          ],
        ),
        const SizedBox(height: 8),
        Stack(
          children: [
            Container(
              height: 4,
              decoration: BoxDecoration(color: AppTheme.darkShadow, borderRadius: BorderRadius.circular(2)),
            ),
            FractionallySizedBox(
              widthFactor: progress,
              child: Container(
                height: 4,
                decoration: BoxDecoration(
                  gradient: AppTheme.accentGradient,
                  borderRadius: BorderRadius.circular(2),
                  boxShadow: [
                    BoxShadow(color: AppTheme.brand.withValues(alpha: 0.4), blurRadius: 6),
                  ],
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final h = duration.inHours;
    final m = duration.inMinutes.remainder(60);
    final s = duration.inSeconds.remainder(60);
    if (h > 0) return '${twoDigits(h)}:${twoDigits(m)}:${twoDigits(s)}';
    return '${twoDigits(m)}:${twoDigits(s)}';
  }
}
