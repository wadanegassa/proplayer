import 'package:flutter/material.dart';
import 'package:proplayer/screens/video_player.dart';
import '../services/media_service.dart';
import 'package:photo_manager/photo_manager.dart';
import 'dart:typed_data';

class VideoListScreen extends StatefulWidget {
  final VoidCallback onVideoOpen;
  final VoidCallback onVideoClose;

  const VideoListScreen({
    super.key,
    required this.onVideoOpen,
    required this.onVideoClose,
  });

  @override
  State<VideoListScreen> createState() => _VideoListScreenState();
}

class _VideoListScreenState extends State<VideoListScreen> {
  final MediaService _mediaService = MediaService();
  List<AssetEntity> _videos = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadVideos();
  }

  Future<void> _loadVideos() async {
    try {
      final videos = await _mediaService.loadMedia(videos: true);
      setState(() {
        _videos = videos;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Permission denied or no videos found')),
        );
      }
    }
  }

  String _formatDuration(int durationSec) {
    final minutes = durationSec ~/ 60;
    final seconds = durationSec % 60;
    return '$minutes:${seconds.toString().padLeft(2, '0')}';
  }

  void _openVideo(AssetEntity video) async {
    // Notify parent to hide mini player
    widget.onVideoOpen();

    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => VideoPlayerScreen(video: video)),
    );

    // Notify parent to show mini player again
    widget.onVideoClose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) return const Center(child: CircularProgressIndicator());
    if (_videos.isEmpty) return const Center(child: Text('No videos found'));

    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: _videos.length,
      itemBuilder: (context, index) {
        final video = _videos[index];
        return ListTile(
          leading: FutureBuilder<Uint8List?>(
            future: video.thumbnailDataWithSize(const ThumbnailSize(64, 64)),
            builder: (context, snapshot) {
              if (snapshot.hasData && snapshot.data != null) {
                return Image.memory(
                  snapshot.data!,
                  width: 64,
                  height: 64,
                  fit: BoxFit.cover,
                );
              }
              return Container(
                width: 64,
                height: 64,
                color: Colors.grey,
                child: const Icon(Icons.videocam, color: Colors.white),
              );
            },
          ),
          title: Text(video.title ?? 'Unknown Video'),
          subtitle: Text(_formatDuration(video.duration ~/ 1000)),
          onTap: () => _openVideo(video),
        );
      },
    );
  }
}
