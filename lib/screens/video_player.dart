import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:chewie/chewie.dart';
import 'package:photo_manager/photo_manager.dart';

class VideoPlayerScreen extends StatefulWidget {
  final AssetEntity video;

  const VideoPlayerScreen({super.key, required this.video});

  @override
  State<VideoPlayerScreen> createState() => _VideoPlayerScreenState();
}

class _VideoPlayerScreenState extends State<VideoPlayerScreen> {
  VideoPlayerController? _controller;
  ChewieController? _chewieController;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _initializeVideo();
  }

  Future<void> _initializeVideo() async {
    final file = await widget.video.file;
    if (file == null) return;

    _controller = VideoPlayerController.file(file);
    await _controller!.initialize();

    _chewieController = ChewieController(
      videoPlayerController: _controller!,
      autoPlay: true,
      looping: false,
      allowFullScreen: true,
      allowMuting: true,
      materialProgressColors: ChewieProgressColors(
        playedColor: Colors.redAccent,
        handleColor: Colors.white,
        backgroundColor: Colors.grey.shade700,
        bufferedColor: Colors.grey.shade500,
      ),
      placeholder: Container(
        color: Colors.black,
      ),
      // Make video fill the width in all orientations
      aspectRatio: _controller!.value.aspectRatio,
    );

    setState(() => _isLoading = false);
  }

  @override
  void dispose() {
    _chewieController?.dispose();
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text(widget.video.title ?? 'Video'),
        backgroundColor: Colors.black,
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.redAccent))
          : LayoutBuilder(
              builder: (context, constraints) {
                final screenWidth = constraints.maxWidth;
                final videoHeight =
                    screenWidth / (_controller!.value.aspectRatio); // maintain aspect ratio

                return Center(
                  child: Container(
                    width: screenWidth,
                    height: videoHeight,
                    decoration: BoxDecoration(
                      color: Colors.black,
                      borderRadius: MediaQuery.of(context).orientation == Orientation.portrait
                          ? BorderRadius.circular(16)
                          : BorderRadius.zero,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.5),
                          blurRadius: 12,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    clipBehavior: Clip.hardEdge,
                    child: Chewie(controller: _chewieController!),
                  ),
                );
              },
            ),
    );
  }
}
