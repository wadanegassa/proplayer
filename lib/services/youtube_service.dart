import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';
import '../models/media_item.dart';
import 'pro_youtube_http_client.dart';

/// Curated YouTube search for Ethiopian gospel (Amharic / Afaan Oromo) and English worship.
///
/// Uses [youtube_explode_dart] with timeouts, retries, pagination error handling,
/// unfiltered search fallback, parallel curated fetches, and deduplication.
class YouTubeService {
  YouTubeService() : _yt = YoutubeExplode(httpClient: ProYoutubeHttpClient());

  final YoutubeExplode _yt;
  final Random _random = Random();

  static const int _maxRetries = 5;
  static const SearchFilter _noSpFilter = SearchFilter('');

  /// If curated pools return nothing, use these broad queries (still gospel-focused).
  static const List<String> _fallbackQueries = [
    'gospel worship music',
    'Christian worship songs',
    'praise and worship gospel',
    'Ethiopian gospel mezmur',
    'Afaan Oromo gospel',
  ];

  /// Amharic / Ethiopian Protestant & worship (Latin + Ge’ez keywords).
  static const List<String> _amharicQueries = [
    'Amharic gospel mezmur 2024',
    'Amharic Protestant worship song',
    'Ethiopian gospel music worship',
    'አማርኛ መዝሙር ፕሮቴስታንት',
    'ኢትዮጵያ መዝሙር አዲስ',
    'Amharic Christian song live worship',
    'Ethiopian mezmur gospel',
    'አማርኛ ክርስቲያን መዝሙር',
    'Amharic praise and worship',
    'Ethiopian orthodox tewahedo mezmur gospel',
  ];

  /// Afaan Oromo gospel / faarfamaa (multiple spellings users search).
  static const List<String> _oromoQueries = [
    'Afaan Oromo gospel song',
    'Oromo gospel faarfamaa',
    'Faarfannaa Afaan Oromoo Waaqayyo',
    'gospel Afaan Oromoo 2024',
    'Oromo Christian worship song',
    'faarfamaa oromoo amantii',
    'Afaan Oromo mezmur gospel',
    'oromo protestant song gospel',
    'Waaqeffannaa gospel song oromo',
    'New Oromo gospel worship',
  ];

  /// English-language gospel & modern worship (recognizable global channels).
  static const List<String> _englishQueries = [
    'English gospel worship song 2024',
    'contemporary Christian worship music',
    'gospel praise and worship live',
    'Hillsong Worship acoustic',
    'Bethel Music worship',
    'Elevation Worship official',
    'Maverick City Music gospel',
    'Sinach gospel worship',
    'Nathaniel Bassey worship',
    'Tasha Cobbs Leonard gospel',
  ];

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

  MediaItem _fromSearchVideo(SearchVideo sv) {
    final thumbUrl = _bestThumbnailUrl(sv.thumbnails);
    return MediaItem(
      id: sv.id.value,
      title: sv.title,
      subtitle: sv.author,
      thumbnail: thumbUrl.isEmpty ? null : thumbUrl,
      duration: _formatDuration(_parseDurationFromSearch(sv.duration)),
      isVideo: true,
      isLocal: false,
    );
  }

  String _bestThumbnailUrl(List<Thumbnail> thumbs) {
    if (thumbs.isEmpty) return '';
    final best = thumbs.reduce((a, b) => a.width >= b.width ? a : b);
    return best.url.toString();
  }

  Duration? _parseDurationFromSearch(String raw) {
    final parts = raw.trim().split(':');
    if (parts.isEmpty) return null;
    final nums = <int>[];
    for (final p in parts) {
      final n = int.tryParse(p.trim());
      if (n == null) return null;
      nums.add(n);
    }
    if (nums.length == 3) {
      return Duration(hours: nums[0], minutes: nums[1], seconds: nums[2]);
    }
    if (nums.length == 2) {
      return Duration(minutes: nums[0], seconds: nums[1]);
    }
    return null;
  }

  String _formatDuration(Duration? duration) {
    if (duration == null) return '—';
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final h = duration.inHours;
    final m = duration.inMinutes.remainder(60);
    final s = duration.inSeconds.remainder(60);
    if (h > 0) {
      return '${twoDigits(h)}:${twoDigits(m)}:${twoDigits(s)}';
    }
    return '${twoDigits(m)}:${twoDigits(s)}';
  }

  /// Replace year tokens like 2024 / 2025 with the current year.
  String _withCurrentYear(String q) {
    final y = DateTime.now().year;
    return q.replaceAllMapped(RegExp(r'\b20\d{2}\b'), (_) => '$y');
  }

  List<String> _pickDistinct(List<String> pool, int count) {
    final copy = pool.map(_withCurrentYear).toList()..shuffle(_random);
    return copy.take(count).toList();
  }

  bool _isLikelyNoise(Video video) {
    final t = video.title.toLowerCase();
    if (t.contains('#shorts') && (video.duration?.inSeconds ?? 0) < 90) {
      return true;
    }
    return false;
  }

  /// Video-only search with safe pagination.
  Future<List<MediaItem>> _searchVideosPaged(
    String query, {
    int maxResults = 24,
  }) async {
    final trimmed = query.trim();
    if (trimmed.isEmpty) return [];

    final out = <MediaItem>[];
    final seen = <String>{};

    VideoSearchList? batch =
        await _yt.search.search(trimmed, filter: TypeFilters.video);

    while (batch != null && out.length < maxResults) {
      for (final video in batch) {
        if (!_isLikelyNoise(video)) {
          if (seen.add(video.id.value)) {
            out.add(_toMediaItem(video));
          }
        }
        if (out.length >= maxResults) break;
      }
      if (out.length >= maxResults) break;
      try {
        batch = await batch.nextPage();
      } catch (e, st) {
        debugPrint('YouTube nextPage (video filter): $e\n$st');
        break;
      }
    }

    return out;
  }

  /// Mixed search (no `sp` filter); keeps [SearchVideo] rows only. Helps when video-only filter breaks.
  Future<List<MediaItem>> _searchMixedPaged(
    String query, {
    int maxResults = 24,
  }) async {
    final trimmed = query.trim();
    if (trimmed.isEmpty) return [];

    final out = <MediaItem>[];
    final seen = <String>{};

    SearchList? batch = await _yt.search.searchContent(trimmed, filter: _noSpFilter);

    while (batch != null && out.length < maxResults) {
      for (final result in batch) {
        if (result is SearchVideo) {
          if (seen.add(result.id.value)) {
            out.add(_fromSearchVideo(result));
          }
        }
        if (out.length >= maxResults) break;
      }
      if (out.length >= maxResults) break;
      try {
        batch = await batch.nextPage();
      } catch (e, st) {
        debugPrint('YouTube nextPage (mixed): $e\n$st');
        break;
      }
    }

    return out;
  }

  Future<List<MediaItem>> _searchWithRetry(
    String query, {
    int maxResults = 20,
  }) async {
    for (var attempt = 0; attempt < _maxRetries; attempt++) {
      try {
        final r = await _searchVideosPaged(query, maxResults: maxResults);
        if (r.isNotEmpty) return r;
      } catch (e, st) {
        debugPrint('YouTube video search retry ${attempt + 1}/$_maxRetries for "$query": $e');
        debugPrint('$st');
      }
      await Future<void>.delayed(Duration(milliseconds: 400 * (1 << attempt).clamp(1, 8)));
    }
    return [];
  }

  Future<List<MediaItem>> _searchMixedWithRetry(
    String query, {
    int maxResults = 20,
  }) async {
    for (var attempt = 0; attempt < _maxRetries; attempt++) {
      try {
        final r = await _searchMixedPaged(query, maxResults: maxResults);
        if (r.isNotEmpty) return r;
      } catch (e, st) {
        debugPrint('YouTube mixed search retry ${attempt + 1}/$_maxRetries for "$query": $e');
        debugPrint('$st');
      }
      await Future<void>.delayed(Duration(milliseconds: 400 * (1 << attempt).clamp(1, 8)));
    }
    return [];
  }

  /// Try video filter first, then unfiltered mixed results (videos only).
  Future<List<MediaItem>> _searchDualStrategy(String query, {int maxResults = 36}) async {
    var list = await _searchWithRetry(query, maxResults: maxResults);
    if (list.isEmpty) {
      list = await _searchMixedWithRetry(query, maxResults: maxResults);
    }
    return list;
  }

  Future<List<MediaItem>> _fetchOneQuerySafe(String query, int perQueryMax) async {
    try {
      return await _searchDualStrategy(query, maxResults: perQueryMax);
    } catch (e, st) {
      debugPrint('YouTube query failed "$query": $e\n$st');
      return [];
    }
  }

  /// Merge several searches; runs queries in parallel for speed.
  Future<List<MediaItem>> _fetchFromQueryPool(
    List<String> pool, {
    int queriesToRun = 3,
    int perQueryMax = 18,
    int cap = 48,
  }) async {
    final picked = _pickDistinct(pool, queriesToRun);
    final futures = picked.map((q) => _fetchOneQuerySafe(q, perQueryMax));
    final batches = await Future.wait(futures);

    final byId = <String, MediaItem>{};
    for (final batch in batches) {
      for (final item in batch) {
        byId[item.id] = item;
      }
      if (byId.length >= cap) break;
    }

    if (byId.length < 8) {
      final extra = _pickDistinct(_fallbackQueries, 2);
      for (final q in extra) {
        final more = await _fetchOneQuerySafe(q, perQueryMax);
        for (final item in more) {
          byId[item.id] = item;
        }
        if (byId.length >= cap) break;
      }
    }

    final list = byId.values.toList()..shuffle(_random);
    if (list.length > cap) {
      return list.sublist(0, cap);
    }
    return list;
  }

  /// Public: user / home search bar.
  Future<List<MediaItem>> searchVideos(String query) async {
    try {
      return await _searchDualStrategy(query.trim(), maxResults: 40);
    } catch (e, st) {
      debugPrint('Error searching videos: $e\n$st');
      return [];
    }
  }

  Future<List<MediaItem>> fetchAmharicGospel() async {
    return _fetchFromQueryPool(
      _amharicQueries,
      queriesToRun: 4,
      perQueryMax: 20,
      cap: 50,
    );
  }

  Future<List<MediaItem>> fetchOromoGospel() async {
    return _fetchFromQueryPool(
      _oromoQueries,
      queriesToRun: 4,
      perQueryMax: 20,
      cap: 50,
    );
  }

  Future<List<MediaItem>> fetchEnglishGospel() async {
    return _fetchFromQueryPool(
      _englishQueries,
      queriesToRun: 4,
      perQueryMax: 20,
      cap: 50,
    );
  }

  /// Home “Explore” rail: balanced mix from all three languages.
  Future<List<MediaItem>> fetchRandomMix() async {
    try {
      const perLang = 14;
      final amharic = await _fetchFromQueryPool(
        _amharicQueries,
        queriesToRun: 2,
        perQueryMax: 14,
        cap: perLang,
      );
      final oromo = await _fetchFromQueryPool(
        _oromoQueries,
        queriesToRun: 2,
        perQueryMax: 14,
        cap: perLang,
      );
      final english = await _fetchFromQueryPool(
        _englishQueries,
        queriesToRun: 2,
        perQueryMax: 14,
        cap: perLang,
      );

      var merged = [...amharic, ...oromo, ...english];
      merged.shuffle(_random);

      if (merged.length < 12) {
        final boost = await _fetchFromQueryPool(
          _fallbackQueries,
          queriesToRun: 3,
          perQueryMax: 16,
          cap: 24,
        );
        final seen = merged.map((e) => e.id).toSet();
        for (final m in boost) {
          if (seen.add(m.id)) merged.add(m);
        }
        merged.shuffle(_random);
      }

      const target = 36;
      if (merged.length > target) {
        return merged.sublist(0, target);
      }
      return merged;
    } catch (e, st) {
      debugPrint('Error fetching random mix: $e\n$st');
      return [];
    }
  }

  void dispose() {
    _yt.close();
  }
}
