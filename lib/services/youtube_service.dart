import 'dart:math';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';
import '../models/media_item.dart';

class YouTubeService {
  final YoutubeExplode _yt = YoutubeExplode();
  final Random _random = Random();

  // Helper to convert Video to MediaItem
  MediaItem _toMediaItem(Video video) {
    return MediaItem(
      id: video.id.value,
      title: video.title,
      subtitle: video.author,
      thumbnail: video.thumbnails.highResUrl,
      duration: _formatDuration(video.duration),
      isVideo: true,
      isLocal: false,
    );
  }

  String _formatDuration(Duration? duration) {
    if (duration == null) return 'Live';
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return '$minutes:$seconds';
  }

  Future<List<MediaItem>> searchVideos(String query) async {
    try {
      final searchList = await _yt.search.search(query);
      return searchList.map(_toMediaItem).toList();
    } catch (e) {
      print('Error searching videos: $e');
      return [];
    }
  }

  Future<List<MediaItem>> fetchAmharicGospel() async {
    // Randomize query slightly to get fresh content
    final queries = [
      'Amharic Gospel Song 2024',
      'New Amharic Protestant Mezmur',
      'Ethiopian Gospel Song Live',
      'Amharic Worship Song',
    ];
    final query = queries[_random.nextInt(queries.length)];
    return await searchVideos(query);
  }

  Future<List<MediaItem>> fetchOromoGospel() async {
    final queries = [
      'Afaan Oromo Gospel Song 2024',
      'New Oromo Gospel Song',
      'Faarfannaa Afaan Oromoo',
      'Oromo Worship Song',
    ];
    final query = queries[_random.nextInt(queries.length)];
    return await searchVideos(query);
  }

  Future<List<MediaItem>> fetchEnglishGospel() async {
    final queries = [
      'English Gospel Song 2024',
      'Top Worship Songs 2024',
      'Hillsong Worship',
      'Bethel Music Worship',
    ];
    final query = queries[_random.nextInt(queries.length)];
    return await searchVideos(query);
  }

  Future<List<MediaItem>> fetchRandomMix() async {
    try {
      final amharic = await fetchAmharicGospel();
      final oromo = await fetchOromoGospel();
      final english = await fetchEnglishGospel();
      
      final all = [...amharic, ...oromo, ...english];
      all.shuffle(_random);
      return all.take(20).toList();
    } catch (e) {
      print('Error fetching random mix: $e');
      return [];
    }
  }

  void dispose() {
    _yt.close();
  }
}
