import 'dart:convert';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:youtube_explode_dart/youtube_explode_dart.dart' hide Video, SearchVideo, Thumbnail;
import 'package:youtube_explode_dart/youtube_explode_dart.dart' as yte;

import '../models/media_item.dart';
import 'pro_youtube_http_client.dart';

/// Curated YouTube search for Ethiopian gospel and English worship.
///
/// Uses official YouTube Data API v3 for metadata and [youtube_explode_dart]
/// for direct stream resolution (direct playback).
class YouTubeService {
  YouTubeService() : _yt = YoutubeExplode(httpClient: ProYoutubeHttpClient());

  final YoutubeExplode _yt;
  final Random _random = Random();

  static const String _apiKey = 'AIzaSyDRTSbMjMDzWzZK2NTBv4NuI8_gU_bRQhY';
  static const String _baseUrl = 'https://www.googleapis.com/youtube/v3';

  /// Amharic / Ethiopian Protestant & worship.
  static const List<String> _amharicQueries = [
    'Amharic gospel mezmur',
    'Amharic Protestant worship',
    'አማርኛ መዝሙር ፕሮቴስታንት',
    'አዲስ መዝሙር',
    'Amharic Christian worship',
  ];

  /// Afaan Oromo gospel / faarfamaa.
  static const List<String> _oromoQueries = [
    'Afaan Oromo gospel',
    'Oromo gospel faarfamaa',
    'Faarfannaa Afaan Oromoo',
    'New Oromo gospel worship',
  ];

  /// English-language gospel & modern worship.
  static const List<String> _englishQueries = [
    'Contemporary Christian worship',
    'Gospel praise and worship',
    'Hillsong Worship',
    'Bethel Music',
    'Elevation Worship',
  ];

  MediaItem _snippetToMediaItem(Map<String, dynamic> item) {
    final id = item['id']['videoId'] ?? item['id']['playlistId'] ?? item['id'].toString();
    final snippet = item['snippet'];
    final thumbnails = snippet['thumbnails'];
    final thumbUrl = thumbnails['high']?['url'] ?? thumbnails['medium']?['url'] ?? thumbnails['default']?['url'];

    return MediaItem(
      id: id,
      title: snippet['title'] ?? 'Unknown Title',
      subtitle: snippet['channelTitle'] ?? 'Unknown Author',
      thumbnail: thumbUrl,
      duration: '—', // Search API doesn't return duration directly; fetched if needed.
      isVideo: true,
      isLocal: false,
    );
  }

  Future<List<MediaItem>> _apiSearch(String q, {int maxResults = 25}) async {
    try {
      final url = Uri.parse('$_baseUrl/search').replace(queryParameters: {
        'part': 'snippet',
        'q': q,
        'type': 'video',
        'maxResults': maxResults.toString(),
        'key': _apiKey,
      });

      final resp = await http.get(url);
      if (resp.statusCode == 200) {
        final data = json.decode(resp.body);
        final items = data['items'] as List? ?? [];
        return items.map((i) => _snippetToMediaItem(i)).toList();
      } else {
        debugPrint('YouTube API error: ${resp.body}');
      }
    } catch (e) {
      debugPrint('YouTube API exception: $e');
    }
    return [];
  }

  /// Mixed search (v3)
  Future<List<MediaItem>> searchVideos(String query) async {
    return _apiSearch(query.trim(), maxResults: 40);
  }

  Future<List<MediaItem>> fetchAmharicGospel() async {
    final q = _amharicQueries[_random.nextInt(_amharicQueries.length)];
    return _apiSearch(q, maxResults: 30);
  }

  Future<List<MediaItem>> fetchOromoGospel() async {
    final q = _oromoQueries[_random.nextInt(_oromoQueries.length)];
    return _apiSearch(q, maxResults: 30);
  }

  Future<List<MediaItem>> fetchEnglishGospel() async {
    final q = _englishQueries[_random.nextInt(_englishQueries.length)];
    return _apiSearch(q, maxResults: 30);
  }

  /// Home “Explore” rail: balanced mix.
  Future<List<MediaItem>> fetchRandomMix() async {
    final queries = [..._amharicQueries, ..._oromoQueries, ..._englishQueries];
    queries.shuffle(_random);
    final results = <MediaItem>[];
    final seen = <String>{};

    for (var i = 0; i < 3; i++) {
        final batch = await _apiSearch(queries[i], maxResults: 12);
        for (final item in batch) {
            if (seen.add(item.id)) results.add(item);
        }
    }
    results.shuffle(_random);
    return results.take(36).toList();
  }

  /// Muxed progressive MP4 (≤360p) or muxed HLS (.m3u8) for [VideoPlayerController.networkUrl].
  Future<Uri?> resolveDirectPlayableUri(String videoIdOrUrl) async {
    try {
      final vid = yte.VideoId.fromString(videoIdOrUrl);
      final manifest = await _yt.videos.streamsClient.getManifest(vid);
      
      if (manifest.muxed.isNotEmpty) {
        return manifest.muxed.withHighestBitrate().url;
      }
      
      final hlsMuxed = manifest.streams.whereType<yte.HlsMuxedStreamInfo>().toList()
        ..sort((a, b) => b.bitrate.compareTo(a.bitrate));
      if (hlsMuxed.isNotEmpty) return hlsMuxed.first.url;
      
      return null;
    } catch (e) {
      debugPrint('resolveDirectPlayableUri failed: $e');
    }
    return null;
  }

  void dispose() {
    _yt.close();
  }

  static Map<String, String> get directPlaybackHttpHeaders => {
        'User-Agent':
            'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.124 Safari/537.36',
        'Referer': 'https://www.youtube.com/',
      };
}
