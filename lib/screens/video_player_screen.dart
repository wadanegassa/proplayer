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
  bool _localWide = false;

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

  void _toggleControls() {
    setState(() => _showControls = !_showControls);
    if (_showControls) _startHideTimer();
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

  Future<void> _toggleLocalWide() async {
    if (_localWide) {
      await SystemChrome.setPreferredOrientations([
        DeviceOrientation.portraitUp,
        DeviceOrientation.portraitDown,
        DeviceOrientation.landscapeLeft,
        DeviceOrientation.landscapeRight,
      ]);
    } else {
      await SystemChrome.setPreferredOrientations([
        DeviceOrientation.landscapeLeft,
        DeviceOrientation.landscapeRight,
      ]);
    }
    if (mounted) setState(() => _localWide = !_localWide);
    _touchUi();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: _toggleControls,
        onDoubleTapDown: (details) {
          final width = MediaQuery.sizeOf(context).width;
          if (details.globalPosition.dx < width / 2) {
            _seekRelative(-10);
          } else {
            _seekRelative(10);
          }
        },
        child: Stack(
          fit: StackFit.expand,
          children: [
            ColoredBox(
              color: theme.scaffoldBackgroundColor,
              child: Center(
                child: _isLocalVideo
                    ? _buildLocalVideo(theme)
                    : _youtubeResolving
                        ? SizedBox(
                            width: 48,
                            height: 48,
                            child: CircularProgressIndicator(
                              strokeWidth: 3,
                              color: theme.colorScheme.primary,
                            ),
                          )
                        : (_youtubeStreamController != null)
                            ? _buildYoutubeStreamVideo(theme)
                            : _buildYouTubePlayer(theme),
              ),
            ),
            if (_seekFlashSeconds != null) _buildSeekFlash(theme),
            AnimatedOpacity(
              opacity: _showControls ? 1 : 0,
              duration: const Duration(milliseconds: 220),
              curve: Curves.easeOut,
              child: IgnorePointer(
                ignoring: !_showControls,
                child: _buildVideoOverlay(theme),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSeekFlash(ThemeData theme) {
    final forward = _seekFlashSeconds! > 0;
    return Positioned.fill(
      child: IgnorePointer(
        child: Align(
          alignment: forward ? Alignment.centerRight : Alignment.centerLeft,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: _seekFlashSide(forward, theme),
          ),
        ),
      ),
    );
  }

  Widget _seekFlashSide(bool forward, ThemeData theme) {
    final cs = theme.colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
      decoration: BoxDecoration(
        color: cs.surface.withValues(alpha: 0.92),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: cs.primary.withValues(alpha: 0.65)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            forward ? Icons.fast_forward_rounded : Icons.fast_rewind_rounded,
            color: cs.primary,
            size: 40,
          ),
          const SizedBox(height: 6),
          Text(
            forward ? '+10s' : '-10s',
            style: theme.textTheme.titleSmall?.copyWith(
              color: cs.onSurface,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildYouTubePlayer(ThemeData theme) {
    final c = _youtubeController;
    final cs = theme.colorScheme;
    if (c == null) {
      return SizedBox(
        width: 40,
        height: 40,
        child: CircularProgressIndicator(strokeWidth: 3, color: cs.primary),
      );
    }
    return LayoutBuilder(
      builder: (context, constraints) {
        const ar = 16 / 9;
        var w = constraints.maxWidth;
        var h = w / ar;
        if (h > constraints.maxHeight) {
          h = constraints.maxHeight;
          w = h * ar;
        }
        return SizedBox(
          width: w,
          height: h,
          child: YoutubePlayerBuilder(
            player: YoutubePlayer(
              controller: c,
              width: w,
              aspectRatio: ar,
              showVideoProgressIndicator: false,
              progressColors: ProgressBarColors(
                playedColor: cs.primary,
                handleColor: cs.primary,
                bufferedColor: cs.onSurface.withValues(alpha: 0.28),
                backgroundColor: cs.onSurface.withValues(alpha: 0.1),
              ),
            ),
            builder: (context, player) => player,
          ),
        );
      },
    );
  }

  Widget _buildLocalVideo(ThemeData theme) {
    final c = _localController;
    final cs = theme.colorScheme;
    if (c == null || !c.value.isInitialized) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 40,
            height: 40,
            child: CircularProgressIndicator(strokeWidth: 3, color: cs.primary),
          ),
          const SizedBox(height: 16),
          Text(
            'Loading…',
            style: theme.textTheme.bodyMedium?.copyWith(color: cs.onSurfaceVariant),
          ),
        ],
      );
    }
    return LayoutBuilder(
      builder: (context, constraints) {
        final ar = c.value.aspectRatio;
        var w = constraints.maxWidth;
        var h = w / ar;
        if (h > constraints.maxHeight) {
          h = constraints.maxHeight;
          w = h * ar;
        }
        return SizedBox(
          width: w,
          height: h,
          child: vp.VideoPlayer(c),
        );
      },
    );
  }

  Widget _buildYoutubeStreamVideo(ThemeData theme) {
    final c = _youtubeStreamController;
    final cs = theme.colorScheme;
    if (c == null || !c.value.isInitialized) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 40,
            height: 40,
            child: CircularProgressIndicator(strokeWidth: 3, color: cs.primary),
          ),
          const SizedBox(height: 16),
          Text(
            'Loading video…',
            style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant),
          ),
        ],
      );
    }
    return LayoutBuilder(
      builder: (context, constraints) {
        final ar = c.value.aspectRatio > 0 ? c.value.aspectRatio : 16 / 9;
        var w = constraints.maxWidth;
        var h = w / ar;
        if (h > constraints.maxHeight) {
          h = constraints.maxHeight;
          w = h * ar;
        }
        return SizedBox(
          width: w,
          height: h,
          child: vp.VideoPlayer(c),
        );
      },
    );
  }

  Widget _buildVideoOverlay(ThemeData theme) {
    final cs = theme.colorScheme;
    final on = cs.onSurface;
    final dim = cs.onSurfaceVariant;
    return Stack(
      fit: StackFit.expand,
      children: [
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  cs.surface.withValues(alpha: 0.94),
                  cs.surface.withValues(alpha: 0.55),
                  Colors.transparent,
                ],
              ),
            ),
            child: SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
                child: Row(
                  children: [
                    IconButton(
                      icon: Icon(Icons.arrow_back_ios_new_rounded, color: on, size: 22),
                      onPressed: () => Navigator.pop(context),
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.mediaItem.title,
                            style: theme.textTheme.titleMedium?.copyWith(
                              color: on,
                              fontWeight: FontWeight.w600,
                              height: 1.2,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 2),
                          Text(
                            _isLocalVideo ? 'Local · ${widget.mediaItem.subtitle}' : 'YouTube · ${widget.mediaItem.subtitle}',
                            style: theme.textTheme.bodySmall?.copyWith(color: dim),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.more_vert_rounded, color: on),
                      onPressed: _showVideoMenu,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        if (!_isPlaying)
          Center(
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: _togglePlayPause,
                customBorder: const CircleBorder(),
                child: Ink(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: cs.primary,
                  ),
                  child: Icon(Icons.play_arrow_rounded, color: cs.onPrimary, size: 52),
                ),
              ),
            ),
          ),
        Positioned(
          left: 0,
          right: 0,
          bottom: 0,
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.bottomCenter,
                end: Alignment.topCenter,
                colors: [
                  cs.surface.withValues(alpha: 0.96),
                  cs.surface.withValues(alpha: 0.6),
                  Colors.transparent,
                ],
              ),
            ),
            child: SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(8, 20, 8, 4),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (_isLocalVideo &&
                        _localController != null &&
                        _localController!.value.isInitialized)
                      _buildVideoPlayerScrubber(theme, _localController!)
                    else if (_youtubeStreamController != null &&
                        _youtubeStreamController!.value.isInitialized)
                      _buildVideoPlayerScrubber(theme, _youtubeStreamController!)
                    else if (!_isLocalVideo && _youtubeController != null)
                      _buildYoutubeScrubber(theme),
                    const SizedBox(height: 4),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        IconButton(
                          icon: Icon(Icons.replay_10_rounded, color: on, size: 32),
                          onPressed: () => _seekRelative(-10),
                        ),
                        IconButton(
                          icon: Icon(
                            _isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
                            color: on,
                            size: 40,
                          ),
                          onPressed: _togglePlayPause,
                        ),
                        IconButton(
                          icon: Icon(Icons.forward_10_rounded, color: on, size: 32),
                          onPressed: () => _seekRelative(10),
                        ),
                        if (_isLocalVideo)
                          IconButton(
                            icon: Icon(
                              _localWide ? Icons.stay_current_portrait_rounded : Icons.screen_rotation_rounded,
                              color: on,
                              size: 24,
                            ),
                            onPressed: _toggleLocalWide,
                          )
                        else
                          IconButton(
                            icon: Icon(Icons.fullscreen_rounded, color: on, size: 26),
                            onPressed: () {
                              _youtubeController?.toggleFullScreenMode();
                              _touchUi();
                            },
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildVideoPlayerScrubber(ThemeData theme, vp.VideoPlayerController c) {
    final cs = theme.colorScheme;
    return ValueListenableBuilder<vp.VideoPlayerValue>(
      valueListenable: c,
      builder: (context, value, _) {
        final d = value.duration.inMilliseconds <= 0 ? Duration.zero : value.duration;
        final maxS = d.inSeconds > 0 ? d.inSeconds.toDouble() : 1.0;
        final pos = value.position.inSeconds.toDouble().clamp(0.0, maxS);
        return Column(
          children: [
            SliderTheme(
              data: SliderTheme.of(context).copyWith(
                activeTrackColor: cs.primary,
                inactiveTrackColor: cs.outline.withValues(alpha: 0.45),
                secondaryActiveTrackColor: cs.onSurface.withValues(alpha: 0.22),
                thumbColor: cs.primary,
                trackHeight: 3,
                thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
                overlayShape: SliderComponentShape.noOverlay,
              ),
              child: Slider(
                value: pos,
                max: maxS,
                onChanged: (v) {
                  c.seekTo(Duration(seconds: v.toInt()));
                  _touchUi();
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    _formatDuration(value.position),
                    style: theme.textTheme.labelLarge?.copyWith(
                      color: cs.onSurface.withValues(alpha: 0.9),
                      fontFeatures: const [FontFeature.tabularFigures()],
                    ),
                  ),
                  Text(
                    '-${_formatDuration(Duration(seconds: (maxS - pos).round().clamp(0, maxS.toInt())))}',
                    style: theme.textTheme.labelLarge?.copyWith(
                      color: cs.onSurfaceVariant,
                      fontFeatures: const [FontFeature.tabularFigures()],
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildYoutubeScrubber(ThemeData theme) {
    final c = _youtubeController!;
    final cs = theme.colorScheme;
    return ValueListenableBuilder<YoutubePlayerValue>(
      valueListenable: c,
      builder: (context, value, _) {
        if (!value.isReady) {
          return Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              'Loading stream…',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(color: cs.onSurfaceVariant),
            ),
          );
        }
        final total = value.metaData.duration;
        final maxS = total.inSeconds > 0 ? total.inSeconds.toDouble() : 1.0;
        final pos = value.position.inSeconds.toDouble().clamp(0.0, maxS);
        return Column(
          children: [
            SliderTheme(
              data: SliderTheme.of(context).copyWith(
                activeTrackColor: cs.primary,
                inactiveTrackColor: cs.outline.withValues(alpha: 0.45),
                thumbColor: cs.primary,
                trackHeight: 3,
                thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
                overlayShape: SliderComponentShape.noOverlay,
              ),
              child: Slider(
                value: pos,
                max: maxS,
                onChanged: (v) {
                  c.seekTo(Duration(seconds: v.toInt()));
                  _touchUi();
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    _formatDuration(value.position),
                    style: theme.textTheme.labelLarge?.copyWith(
                      color: cs.onSurface.withValues(alpha: 0.9),
                      fontFeatures: const [FontFeature.tabularFigures()],
                    ),
                  ),
                  Text(
                    '-${_formatDuration(Duration(seconds: (maxS - pos).round().clamp(0, maxS.toInt())))}',
                    style: theme.textTheme.labelLarge?.copyWith(
                      color: cs.onSurfaceVariant,
                      fontFeatures: const [FontFeature.tabularFigures()],
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
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
