import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/media_item.dart';

class HistoryService {
  static const String _key = 'recently_played';

  Future<void> addToRecent(MediaItem item) async {
    final prefs = await SharedPreferences.getInstance();
    final List<String> currentList = prefs.getStringList(_key) ?? [];
    
    // Remove if exists to move to top
    currentList.removeWhere((jsonStr) {
      final existing = MediaItem.fromJson(jsonDecode(jsonStr));
      return existing.id == item.id;
    });

    // Add to top
    final newItem = MediaItem(
      id: item.id,
      title: item.title,
      subtitle: item.subtitle,
      thumbnail: item.thumbnail,
      duration: item.duration,
      isVideo: item.isVideo,
      isLocal: item.isLocal,
      lastPlayed: DateTime.now(),
    );

    currentList.insert(0, jsonEncode(newItem.toJson()));

    // Limit to 20
    if (currentList.length > 20) {
      currentList.removeRange(20, currentList.length);
    }

    await prefs.setStringList(_key, currentList);
  }

  Future<List<MediaItem>> getRecentList() async {
    final prefs = await SharedPreferences.getInstance();
    final List<String> currentList = prefs.getStringList(_key) ?? [];
    
    return currentList
        .map((jsonStr) => MediaItem.fromJson(jsonDecode(jsonStr)))
        .toList();
  }
}
