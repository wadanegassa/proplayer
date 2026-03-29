import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:just_audio/just_audio.dart';
import 'package:provider/provider.dart';
import '../layout/app_layout.dart';
import '../models/media_item.dart';
import '../providers/audio_player_provider.dart';

class LocalPlayerScreen extends StatefulWidget {
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
  State<LocalPlayerScreen> createState() => _LocalPlayerScreenState();
}

class _LocalPlayerScreenState extends State<LocalPlayerScreen>
    with SingleTickerProviderStateMixin {
  late AudioPlayer _audioPlayer;
  bool _isPlaying = false;
  Duration _duration = Duration.zero;
  Duration _position = Duration.zero;
  double _playbackSpeed = 1.0;
  Timer? _sleepTimer;
  DateTime? _sleepTime;

  late AnimationController _fabPopController;
  late Animation<double> _fabScaleAnim;

  @override
  void initState() {
    super.initState();

    _fabPopController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 260),
    );
    _fabScaleAnim = Tween<double>(begin: 1.0, end: 1.12).animate(
      CurvedAnimation(parent: _fabPopController, curve: Curves.easeOutBack, reverseCurve: Curves.easeIn),
    );
    _fabPopController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _fabPopController.reverse();
      }
    });

    final audioProvider = Provider.of<AudioPlayerProvider>(context, listen: false);
    _audioPlayer = audioProvider.audioPlayer;
    if (!widget.fromMiniPlayer) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        audioProvider.playTrack(widget.mediaItem, widget.playlist);
      });
    }

    _playbackSpeed = _audioPlayer.speed;
    _initPlayer();
  }

  Future<void> _initPlayer() async {
    try {
      _audioPlayer.durationStream.listen((duration) {
        if (mounted) {
          setState(() => _duration = duration ?? Duration.zero);
        }
      });

      _audioPlayer.positionStream.listen((position) {
        if (mounted) setState(() => _position = position);
      });

      _audioPlayer.playerStateStream.listen((state) {
        if (mounted) setState(() => _isPlaying = state.playing);
      });

      _audioPlayer.speedStream.listen((speed) {
        if (mounted) setState(() => _playbackSpeed = speed);
      });
    } catch (e) {
      debugPrint('Error initializing player: $e');
    }
  }

  @override
  void dispose() {
    _sleepTimer?.cancel();
    _fabPopController.dispose();
    super.dispose();
  }

  Future<void> _playNext() async {
    final audioProvider = Provider.of<AudioPlayerProvider>(context, listen: false);
    await audioProvider.playNext();
  }

  Future<void> _playPrevious() async {
    final audioProvider = Provider.of<AudioPlayerProvider>(context, listen: false);
    await audioProvider.playPrevious();
  }

  void _togglePlayPause() {
    _fabPopController.forward(from: 0);
    final audioProvider = Provider.of<AudioPlayerProvider>(context, listen: false);
    if (_isPlaying) {
      audioProvider.pause();
    } else {
      audioProvider.play();
    }
  }

  void _setSleepTimer(int minutes) {
    _sleepTimer?.cancel();
    if (minutes > 0) {
      _sleepTime = DateTime.now().add(Duration(minutes: minutes));
      _sleepTimer = Timer(Duration(minutes: minutes), () {
        _audioPlayer.pause();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Sleep timer ended — playback paused')),
          );
          setState(() => _sleepTime = null);
        }
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Sleep timer: $minutes min')),
      );
    } else {
      _sleepTime = null;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Sleep timer off')),
      );
    }
    setState(() {});
  }

  Future<void> _setSpeed(double speed) async {
    await _audioPlayer.setSpeed(speed);
    if (mounted) setState(() => _playbackSpeed = speed);
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final h = duration.inHours;
    final m = duration.inMinutes.remainder(60);
    final s = duration.inSeconds.remainder(60);
    if (h > 0) return '${twoDigits(h)}:${twoDigits(m)}:${twoDigits(s)}';
    return '${twoDigits(m)}:${twoDigits(s)}';
  }

  void _copyNowPlaying(AudioPlayerProvider audioProvider) {
    final t = audioProvider.currentTrack ?? widget.mediaItem;
    final text = '${t.title} — ${t.subtitle}';
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Track info copied')),
    );
  }

  void _showQueueSheet(AudioPlayerProvider p) {
    final list = p.playlist;
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        final theme = Theme.of(ctx);
        return DraggableScrollableSheet(
          initialChildSize: 0.55,
          minChildSize: 0.35,
          maxChildSize: 0.92,
          expand: false,
          builder: (_, scrollController) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Center(
                  child: Container(
                    margin: const EdgeInsets.only(top: 12, bottom: 8),
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 8, 24, 16),
                  child: Row(
                    children: [
                      Icon(Icons.queue_music_rounded, color: theme.colorScheme.primary),
                      const SizedBox(width: 12),
                      Text(
                        'Queue',
                        style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
                      ),
                      const Spacer(),
                      Text(
                        '${list.length} tracks',
                        style: theme.textTheme.labelLarge?.copyWith(
                          color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    controller: scrollController,
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
                    itemCount: list.length,
                    itemBuilder: (context, i) {
                      final item = list[i];
                      final current = p.currentTrack?.id == item.id;
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Material(
                          color: current
                              ? theme.colorScheme.primary.withValues(alpha: 0.12)
                              : theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.55),
                          borderRadius: BorderRadius.circular(16),
                          child: InkWell(
                            borderRadius: BorderRadius.circular(16),
                            onTap: () async {
                              Navigator.pop(ctx);
                              await p.playTrack(item, list);
                            },
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                              child: Row(
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(12),
                                    child: SizedBox(
                                      width: 48,
                                      height: 48,
                                      child: item.thumbnailBytes != null
                                          ? Image.memory(item.thumbnailBytes!, fit: BoxFit.cover)
                                          : DecoratedBox(
                                              decoration: BoxDecoration(
                                                color: theme.colorScheme.primaryContainer.withValues(alpha: 0.5),
                                              ),
                                              child: Icon(
                                                Icons.music_note_rounded,
                                                color: theme.colorScheme.primary,
                                              ),
                                            ),
                                    ),
                                  ),
                                  const SizedBox(width: 14),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          item.title,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: theme.textTheme.titleSmall?.copyWith(
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                        Text(
                                          item.subtitle,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: theme.textTheme.bodySmall?.copyWith(
                                            color: theme.colorScheme.onSurface.withValues(alpha: 0.55),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  if (current)
                                    Icon(Icons.play_circle_fill_rounded,
                                        color: theme.colorScheme.primary, size: 28),
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showSpeedSheet() {
    const speeds = [0.5, 0.75, 1.0, 1.25, 1.5, 1.75, 2.0];
    final theme = Theme.of(context);
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: theme.colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        final t = Theme.of(ctx);
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(8, 8, 8, 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 8, 4),
                  child: Row(
                    children: [
                      Text(
                        'Playback speed',
                        style: t.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
                      ),
                      const Spacer(),
                      IconButton(
                        onPressed: () => Navigator.pop(ctx),
                        icon: const Icon(Icons.close_rounded),
                      ),
                    ],
                  ),
                ),
                ...speeds.map((s) {
                  final sel = (_playbackSpeed - s).abs() < 0.01;
                  final label = s % 1 == 0 ? '${s.toInt()}x' : '${s}x';
                  return ListTile(
                    title: Text(label),
                    trailing: sel ? Icon(Icons.check_circle_rounded, color: t.colorScheme.primary) : null,
                    onTap: () {
                      _setSpeed(s);
                      Navigator.pop(ctx);
                    },
                  );
                }),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showSleepTimerSheet() {
    final theme = Theme.of(context);
    final options = <(int, String)>[(0, 'Off'), (15, '15 min'), (30, '30 min'), (45, '45 min'), (60, '1 hr')];
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: theme.colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        final t = Theme.of(ctx);
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(CupertinoIcons.moon_zzz_fill, color: t.colorScheme.primary),
                    const SizedBox(width: 10),
                    Text(
                      'Sleep timer',
                      style: t.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
                    ),
                  ],
                ),
                if (_sleepTime != null) ...[
                  const SizedBox(height: 8),
                  Text(
                    'Stops at ${_sleepTime!.hour.toString().padLeft(2, '0')}:${_sleepTime!.minute.toString().padLeft(2, '0')}',
                    style: t.textTheme.bodySmall?.copyWith(
                      color: t.colorScheme.onSurface.withValues(alpha: 0.55),
                    ),
                  ),
                ],
                const SizedBox(height: 20),
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: options.map((o) {
                    final m = o.$1;
                    final active = m == 0
                        ? _sleepTime == null
                        : _sleepTime != null &&
                            _sleepTime!.difference(DateTime.now()).inMinutes >= m - 2 &&
                            _sleepTime!.difference(DateTime.now()).inMinutes <= m + 2;
                    return FilterChip(
                      selected: active,
                      showCheckmark: false,
                      label: Text(o.$2),
                      selectedColor: t.colorScheme.primary,
                      labelStyle: TextStyle(
                        color: active ? t.colorScheme.onPrimary : t.colorScheme.onSurface,
                        fontWeight: FontWeight.w600,
                      ),
                      onSelected: (_) {
                        _setSleepTimer(m);
                        Navigator.pop(ctx);
                      },
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showMoreSheet(AudioPlayerProvider audioProvider) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(Icons.queue_music_rounded, color: Theme.of(ctx).colorScheme.primary),
              title: const Text('Queue'),
              onTap: () {
                Navigator.pop(ctx);
                _showQueueSheet(audioProvider);
              },
            ),
            ListTile(
              leading: Icon(CupertinoIcons.timer, color: Theme.of(ctx).colorScheme.primary),
              title: const Text('Sleep timer'),
              onTap: () {
                Navigator.pop(ctx);
                _showSleepTimerSheet();
              },
            ),
            ListTile(
              leading: Icon(Icons.copy_rounded, color: Theme.of(ctx).colorScheme.primary),
              title: const Text('Copy track info'),
              onTap: () {
                Navigator.pop(ctx);
                _copyNowPlaying(audioProvider);
              },
            ),
          ],
        ),
      ),
    );
  }

  bool _sideBySideLayout(Size size) {
    if (size.width >= AppLayout.phoneMax) return true;
    if (size.width > size.height && size.height < 480) return true;
    return false;
  }

  Widget _animatedCircleArtwork(ThemeData theme, MediaItem song, double maxSide) {
    final side = maxSide.clamp(200.0, AppLayout.playerMaxWidth * 0.92);
    return Hero(
      tag: 'mini_player_thumb',
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 380),
        switchInCurve: Curves.easeOutCubic,
        switchOutCurve: Curves.easeInCubic,
        transitionBuilder: (child, animation) {
          final curved = CurvedAnimation(parent: animation, curve: Curves.easeOutCubic);
          return FadeTransition(
            opacity: curved,
            child: ScaleTransition(
              scale: Tween<double>(begin: 0.82, end: 1.0).animate(curved),
              child: child,
            ),
          );
        },
        child: _CircleAlbumArt(
          key: ValueKey<String>(song.id),
          theme: theme,
          side: side,
          bytes: song.thumbnailBytes,
        ),
      ),
    );
  }

  Widget _trackMeta(ThemeData theme, MediaItem currentSong) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      switchInCurve: Curves.easeOutCubic,
      switchOutCurve: Curves.easeInCubic,
      transitionBuilder: (child, animation) {
        return FadeTransition(
          opacity: animation,
          child: SlideTransition(
            position: Tween<Offset>(begin: const Offset(0, 0.06), end: Offset.zero).animate(
              CurvedAnimation(parent: animation, curve: Curves.easeOutCubic),
            ),
            child: child,
          ),
        );
      },
      child: Column(
        key: ValueKey<String>(currentSong.id),
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            currentSong.title,
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w700,
              height: 1.2,
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 6),
          Text(
            currentSong.subtitle,
            style: theme.textTheme.titleSmall?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _sliderSection(ThemeData theme) {
    final maxSlider = _duration.inSeconds <= 0 ? 1.0 : _duration.inSeconds.toDouble();
    final posSlider = _position.inSeconds.toDouble().clamp(0.0, maxSlider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              _formatDuration(_position),
              style: theme.textTheme.labelLarge?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.55),
                fontFeatures: const [FontFeature.tabularFigures()],
              ),
            ),
            Text(
              _formatDuration(_duration),
              style: theme.textTheme.labelLarge?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.55),
                fontFeatures: const [FontFeature.tabularFigures()],
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            trackHeight: 4,
            thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 7),
            overlayShape: const RoundSliderOverlayShape(overlayRadius: 18),
            activeTrackColor: theme.colorScheme.primary,
            inactiveTrackColor: theme.colorScheme.onSurface.withValues(alpha: 0.12),
            thumbColor: theme.colorScheme.primary,
            overlayColor: theme.colorScheme.primary.withValues(alpha: 0.12),
          ),
          child: Slider(
            value: posSlider,
            max: maxSlider,
            onChanged: (v) async {
              await _audioPlayer.seek(Duration(seconds: v.toInt()));
            },
          ),
        ),
      ],
    );
  }

  Widget _secondaryControls(ThemeData theme, AudioPlayerProvider audioProvider) {
    return Wrap(
      alignment: WrapAlignment.center,
      spacing: 8,
      runSpacing: 8,
      children: [
        _ControlPill(
          icon: CupertinoIcons.shuffle,
          active: audioProvider.shuffleEnabled,
          onTap: audioProvider.playlist.isEmpty ? null : () => audioProvider.toggleShuffle(),
        ),
        _ControlPill(
          icon: audioProvider.repeatMode == PlayerRepeatMode.one
              ? CupertinoIcons.repeat_1
              : CupertinoIcons.repeat,
          active: audioProvider.repeatMode != PlayerRepeatMode.off,
          onTap: () => audioProvider.cycleRepeatMode(),
        ),
        _ControlPill(
          icon: CupertinoIcons.timer,
          active: _sleepTime != null,
          onTap: _showSleepTimerSheet,
        ),
        _ControlPill(
          icon: Icons.speed_rounded,
          active: _playbackSpeed != 1.0,
          onTap: _showSpeedSheet,
        ),
      ],
    );
  }

  Widget _mainTransport(ThemeData theme, AudioPlayerProvider audioProvider) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        IconButton(
          iconSize: 34,
          icon: Icon(
            CupertinoIcons.backward_fill,
            color: audioProvider.canPlayPrevious
                ? theme.colorScheme.onSurface
                : theme.colorScheme.onSurface.withValues(alpha: 0.25),
          ),
          onPressed: audioProvider.canPlayPrevious ? _playPrevious : null,
        ),
        const SizedBox(width: 16),
        ScaleTransition(
          scale: _fabScaleAnim,
          child: FilledButton(
            onPressed: _togglePlayPause,
            style: FilledButton.styleFrom(
              backgroundColor: theme.colorScheme.primary,
              foregroundColor: theme.colorScheme.onPrimary,
              padding: const EdgeInsets.all(24),
              shape: const CircleBorder(),
            ),
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 220),
              switchInCurve: Curves.easeOut,
              switchOutCurve: Curves.easeIn,
              transitionBuilder: (child, anim) =>
                  ScaleTransition(scale: anim, child: FadeTransition(opacity: anim, child: child)),
              child: Icon(
                _isPlaying ? CupertinoIcons.pause_fill : CupertinoIcons.play_fill,
                key: ValueKey<bool>(_isPlaying),
                size: 36,
              ),
            ),
          ),
        ),
        const SizedBox(width: 16),
        IconButton(
          iconSize: 34,
          icon: Icon(
            CupertinoIcons.forward_fill,
            color: audioProvider.canPlayNext
                ? theme.colorScheme.onSurface
                : theme.colorScheme.onSurface.withValues(alpha: 0.25),
          ),
          onPressed: audioProvider.canPlayNext ? _playNext : null,
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final audioProvider = context.watch<AudioPlayerProvider>();
    final currentSong = audioProvider.currentTrack ?? widget.mediaItem;
    final theme = Theme.of(context);
    final pad = AppLayout.horizontalPadding(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final size = MediaQuery.sizeOf(context);
            final wide = _sideBySideLayout(size);
            final artMax = wide
                ? (constraints.maxHeight * 0.72).clamp(160.0, 340.0)
                : (constraints.maxWidth * 0.72).clamp(200.0, 320.0);

            final controls = Padding(
              padding: EdgeInsets.symmetric(horizontal: wide ? 12 : pad),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (!wide) ...[
                    _trackMeta(theme, currentSong),
                    const SizedBox(height: 20),
                  ],
                  _sliderSection(theme),
                  const SizedBox(height: 12),
                  _secondaryControls(theme, audioProvider),
                  const SizedBox(height: 16),
                  _mainTransport(theme, audioProvider),
                  const SizedBox(height: 8),
                  TextButton.icon(
                    onPressed: () => _showQueueSheet(audioProvider),
                    icon: const Icon(Icons.queue_music_rounded, size: 20),
                    label: const Text('View queue'),
                    style: TextButton.styleFrom(foregroundColor: theme.colorScheme.primary),
                  ),
                ],
              ),
            );

            return AppLayout.constrainPlayer(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Padding(
                    padding: EdgeInsets.fromLTRB(8, 4, 8, 0),
                    child: Row(
                      children: [
                        IconButton(
                          onPressed: () => Navigator.pop(context),
                          icon: const Icon(CupertinoIcons.chevron_down),
                          style: IconButton.styleFrom(
                            backgroundColor: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.65),
                          ),
                        ),
                        Expanded(
                          child: Column(
                            children: [
                              Text(
                                'Now playing',
                                style: theme.textTheme.labelLarge?.copyWith(
                                  fontWeight: FontWeight.w700,
                                  color: theme.colorScheme.primary,
                                ),
                              ),
                              Text(
                                'Local library',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: theme.colorScheme.onSurface.withValues(alpha: 0.45),
                                ),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          onPressed: () => _showMoreSheet(audioProvider),
                          icon: const Icon(Icons.more_horiz_rounded),
                          style: IconButton.styleFrom(
                            backgroundColor: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.65),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: wide
                        ? Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Expanded(
                                flex: 5,
                                child: Center(
                                  child: SingleChildScrollView(
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        _animatedCircleArtwork(theme, currentSong, artMax),
                                        const SizedBox(height: 16),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                              Expanded(
                                flex: 6,
                                child: SingleChildScrollView(
                                  padding: const EdgeInsets.only(bottom: 16),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.stretch,
                                    children: [
                                      _trackMeta(theme, currentSong),
                                      const SizedBox(height: 16),
                                      controls,
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          )
                        : SingleChildScrollView(
                            padding: EdgeInsets.fromLTRB(pad, 8, pad, 24),
                            physics: const BouncingScrollPhysics(),
                            child: Column(
                              children: [
                                Center(child: _animatedCircleArtwork(theme, currentSong, artMax)),
                                const SizedBox(height: 24),
                                controls,
                              ],
                            ),
                          ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class _CircleAlbumArt extends StatelessWidget {
  const _CircleAlbumArt({
    super.key,
    required this.theme,
    required this.side,
    required this.bytes,
  });

  final ThemeData theme;
  final double side;
  final Uint8List? bytes;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: side,
      height: side,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: theme.colorScheme.surfaceContainerHighest,
        border: Border.all(
          color: theme.colorScheme.outline.withValues(alpha: 0.35),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.shadow.withValues(alpha: 0.08),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: bytes != null
          ? Image.memory(bytes!, fit: BoxFit.cover)
          : Center(
              child: Icon(
                CupertinoIcons.music_note_2,
                size: (side * 0.28).clamp(40.0, 72.0),
                color: theme.colorScheme.primary.withValues(alpha: 0.5),
              ),
            ),
    );
  }
}

class _ControlPill extends StatelessWidget {
  const _ControlPill({
    required this.icon,
    required this.active,
    required this.onTap,
  });

  final IconData icon;
  final bool active;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Material(
      color: active
          ? theme.colorScheme.primary.withValues(alpha: 0.18)
          : theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.65),
      shape: const CircleBorder(),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Icon(
            icon,
            size: 22,
            color: active ? theme.colorScheme.primary : theme.colorScheme.onSurface.withValues(alpha: 0.55),
          ),
        ),
      ),
    );
  }
}
