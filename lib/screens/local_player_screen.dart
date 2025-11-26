import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:just_audio/just_audio.dart';
import 'dart:async';
import 'package:provider/provider.dart';
import '../models/media_item.dart';
import '../theme/app_theme.dart';
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
        SnackBar(content: Text('Sleep timer set for $minutes minutes')),
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

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(CupertinoIcons.chevron_down),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Now Playing'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(
              _sleepTime != null ? CupertinoIcons.timer_fill : CupertinoIcons.timer,
              color: _sleepTime != null ? AppTheme.primaryColor : Colors.white,
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
                  color: AppTheme.surfaceColor,
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.primaryColor.withValues(alpha: 0.3),
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
                    : const Icon(
                        CupertinoIcons.music_note_2,
                        size: 100,
                        color: Colors.white24,
                      ),
              ),
              const SizedBox(height: 40),

              // Song Info
              Text(
                currentSong.title,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
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
                  color: Colors.white.withValues(alpha: 0.6),
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
                      activeColor: AppTheme.primaryColor,
                      inactiveColor: Colors.white24,
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
                            color: Colors.white.withValues(alpha: 0.6),
                          ),
                        ),
                        Text(
                          _formatDuration(_duration),
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.6),
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
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(CupertinoIcons.backward_fill),
                    iconSize: 32,
                    color: _currentIndex > 0 ? Colors.white : Colors.white24,
                    onPressed: _currentIndex > 0 ? _playPrevious : null,
                  ),
                  Container(
                    width: 70,
                    height: 70,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: const LinearGradient(
                        colors: [AppTheme.primaryColor, AppTheme.secondaryColor],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: AppTheme.primaryColor.withValues(alpha: 0.4),
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
                      color: Colors.white,
                      onPressed: _togglePlayPause,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(CupertinoIcons.forward_fill),
                    iconSize: 32,
                    color: _currentIndex < widget.playlist.length - 1
                        ? Colors.white
                        : Colors.white24,
                    onPressed: _currentIndex < widget.playlist.length - 1
                        ? _playNext
                        : null,
                  ),
                  IconButton(
                    icon: const Icon(CupertinoIcons.heart),
                    color: Colors.white,
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
      backgroundColor: AppTheme.surfaceColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Sleep Timer',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 20),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: [
                  _buildTimerOption(0, 'Off'),
                  _buildTimerOption(15, '15 min'),
                  _buildTimerOption(30, '30 min'),
                  _buildTimerOption(45, '45 min'),
                  _buildTimerOption(60, '1 hour'),
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
      label: Text(label),
      backgroundColor: isSelected ? AppTheme.primaryColor : Colors.white10,
      labelStyle: TextStyle(
        color: isSelected ? Colors.white : Colors.white70,
      ),
      onPressed: () {
        _setSleepTimer(minutes);
        Navigator.pop(context);
      },
    );
  }
}
