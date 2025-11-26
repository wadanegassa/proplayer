import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:just_audio/just_audio.dart';
import 'dart:async';
import 'package:provider/provider.dart';
import '../models/media_item.dart';
// removed app_theme import; using Theme.of(context)
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

class _LocalPlayerScreenState extends State<LocalPlayerScreen> {
  late AudioPlayer _audioPlayer;
  late int _currentIndex;
  bool _isPlaying = false;
  Duration _duration = Duration.zero;
  Duration _position = Duration.zero;
  double _playbackSpeed = 1.0;
  Timer? _sleepTimer;
  DateTime? _sleepTime;

  @override
  void initState() {
    super.initState();
    
    final audioProvider = Provider.of<AudioPlayerProvider>(context, listen: false);
    
    if (widget.fromMiniPlayer) {
      // Use existing player from provider
      _audioPlayer = audioProvider.audioPlayer;
      _currentIndex = audioProvider.currentIndex;
    } else {
      // Start new playback
      _audioPlayer = audioProvider.audioPlayer;
      _currentIndex = widget.playlist.indexOf(widget.mediaItem);
      
      // Tell provider to start playing
      WidgetsBinding.instance.addPostFrameCallback((_) {
        audioProvider.playTrack(widget.mediaItem, widget.playlist);
      });
    }

    _initPlayer();
  }

  Future<void> _initPlayer() async {
    try {
      _audioPlayer.durationStream.listen((duration) {
        if (mounted) {
          setState(() {
            _duration = duration ?? Duration.zero;
          });
        }
      });

      _audioPlayer.positionStream.listen((position) {
        if (mounted) {
          setState(() {
            _position = position;
          });
        }
      });

      _audioPlayer.playerStateStream.listen((state) {
        if (mounted) {
          setState(() {
            _isPlaying = state.playing;
          });
        }
      });
    } catch (e) {
      debugPrint('Error initializing player: $e');
    }
  }

  @override
  void dispose() {
    // Don't dispose the player as it's managed by AudioPlayerProvider
    _sleepTimer?.cancel();
    super.dispose();
  }

  Future<void> _playNext() async {
    final audioProvider = Provider.of<AudioPlayerProvider>(context, listen: false);
    await audioProvider.playNext();
    if (mounted) {
      setState(() {
        _currentIndex = audioProvider.currentIndex;
      });
    }
  }

  Future<void> _playPrevious() async {
    final audioProvider = Provider.of<AudioPlayerProvider>(context, listen: false);
    await audioProvider.playPrevious();
    if (mounted) {
      setState(() {
        _currentIndex = audioProvider.currentIndex;
      });
    }
  }

  void _togglePlayPause() {
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
            const SnackBar(content: Text('Sleep timer ended. Playback paused.')),
          );
          setState(() => _sleepTime = null);
        }
      });
      ScaffoldMessenger.of(context).showSnackBar(
        // show number only (no 'minutes' suffix)
        SnackBar(content: Text('Sleep timer set for $minutes')),
      );
    } else {
      _sleepTime = null;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Sleep timer cancelled')),
      );
    }
    setState(() {});
  }

  void _changeSpeed() {
    double newSpeed = _playbackSpeed + 0.25;
    if (newSpeed > 2.0) newSpeed = 0.5;
    setState(() => _playbackSpeed = newSpeed);
    _audioPlayer.setSpeed(newSpeed);
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return '$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    final currentSong = widget.playlist[_currentIndex];

    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(CupertinoIcons.chevron_down),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text('Now Playing', style: TextStyle(color: theme.colorScheme.onSurface)),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(
              _sleepTime != null ? CupertinoIcons.timer_fill : CupertinoIcons.timer,
              color: _sleepTime != null ? theme.colorScheme.primary : theme.colorScheme.onSurface,
            ),
            onPressed: () => _showSleepTimerDialog(),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              const SizedBox(height: 20),

              // Album Art
              Container(
                width: 280,
                height: 280,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(24),
                  color: theme.cardColor,
                  boxShadow: [
                    BoxShadow(
                      color: theme.colorScheme.primary.withAlpha(77),
                      blurRadius: 30,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: currentSong.thumbnailBytes != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(24),
                        child: Image.memory(
                          currentSong.thumbnailBytes!,
                          fit: BoxFit.cover,
                        ),
                      )
                    : Icon(
                        CupertinoIcons.music_note_2,
                        size: 100,
                        color: theme.colorScheme.onSurface.withAlpha(61),
                      ),
              ),
              const SizedBox(height: 40),

              // Song Info
              Text(
                currentSong.title,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.onSurface,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 8),
              Text(
                currentSong.subtitle,
                style: TextStyle(
                  fontSize: 16,
                  color: theme.colorScheme.onSurface.withAlpha(153),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 40),

              // Progress Bar
              Column(
                children: [
                  SliderTheme(
                    data: SliderTheme.of(context).copyWith(
                      trackHeight: 4,
                      thumbShape: const RoundSliderThumbShape(
                        enabledThumbRadius: 6,
                      ),
                      overlayShape: const RoundSliderOverlayShape(
                        overlayRadius: 12,
                      ),
                    ),
                      child: Slider(
                      value: _position.inSeconds.toDouble().clamp(0, _duration.inSeconds.toDouble()),
                      max: _duration.inSeconds.toDouble(),
                      activeColor: theme.colorScheme.primary,
                      inactiveColor: theme.colorScheme.onSurface.withAlpha(61),
                      onChanged: (value) async {
                        await _audioPlayer.seek(Duration(seconds: value.toInt()));
                      },
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          _formatDuration(_position),
                          style: TextStyle(
                            color: theme.colorScheme.onSurface.withAlpha(153),
                          ),
                        ),
                        Text(
                          _formatDuration(_duration),
                          style: TextStyle(
                            color: theme.colorScheme.onSurface.withAlpha(153),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Controls
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  // Speed Control
                  TextButton(
                    onPressed: _changeSpeed,
                    child: Text(
                      '${_playbackSpeed}x',
                      style: TextStyle(
                        color: theme.colorScheme.onSurface,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(CupertinoIcons.backward_fill),
                    iconSize: 32,
                    color: _currentIndex > 0 ? theme.colorScheme.onSurface : theme.colorScheme.onSurface.withAlpha(61),
                    onPressed: _currentIndex > 0 ? _playPrevious : null,
                  ),
                  Container(
                    width: 70,
                    height: 70,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        colors: [theme.colorScheme.primary, theme.colorScheme.secondary],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: theme.colorScheme.primary.withAlpha(102),
                          blurRadius: 20,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: IconButton(
                      icon: Icon(
                        _isPlaying
                            ? CupertinoIcons.pause_fill
                            : CupertinoIcons.play_fill,
                      ),
                      iconSize: 32,
                      color: theme.colorScheme.onPrimary,
                      onPressed: _togglePlayPause,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(CupertinoIcons.forward_fill),
                    iconSize: 32,
                    color: _currentIndex < widget.playlist.length - 1
                        ? theme.colorScheme.onSurface
                        : theme.colorScheme.onSurface.withAlpha(61),
                    onPressed: _currentIndex < widget.playlist.length - 1
                        ? _playNext
                        : null,
                  ),
                  IconButton(
                    icon: const Icon(CupertinoIcons.heart),
                    color: theme.colorScheme.onSurface,
                    onPressed: () {
                      // Favorite logic
                    },
                  ),
                ],
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  void _showSleepTimerDialog() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Theme.of(context).cardColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Sleep Timer',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 20),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: [
                  _buildTimerOption(0, 'Off'),
                  _buildTimerOption(15, '15'),
                  _buildTimerOption(30, '30'),
                  _buildTimerOption(45, '45'),
                  _buildTimerOption(60, '60'),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTimerOption(int minutes, String label) {
    final isSelected = (minutes == 0 && _sleepTime == null) ||
        (_sleepTime != null &&
            _sleepTime!.difference(DateTime.now()).inMinutes >= minutes - 1 &&
            _sleepTime!.difference(DateTime.now()).inMinutes <= minutes + 1);

    return ActionChip(
      label: Text(label, style: TextStyle(color: isSelected ? Theme.of(context).colorScheme.onPrimary : Theme.of(context).colorScheme.onSurface.withAlpha(179))),
      backgroundColor: isSelected ? Theme.of(context).colorScheme.primary : Theme.of(context).colorScheme.onSurface.withAlpha(26),
      onPressed: () {
        _setSleepTimer(minutes);
        Navigator.pop(context);
      },
    );
  }
}
