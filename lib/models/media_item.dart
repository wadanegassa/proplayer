import 'dart:typed_data';

class MediaItem {
  final String id; // videoId for YouTube, path for local
  final String title;
  final String subtitle; // Artist or Channel
  final String? thumbnail;
  final Uint8List? thumbnailBytes; // For local media
  final String duration;
  final bool isVideo;
  final bool isLocal;
  final DateTime? lastPlayed;

  MediaItem({
    required this.id,
    required this.title,
    required this.subtitle,
    this.thumbnail,
    this.thumbnailBytes,
    required this.duration,
    this.isVideo = false,
    this.isLocal = false,
    this.lastPlayed,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'subtitle': subtitle,
      'thumbnail': thumbnail,
      'duration': duration,
      'isVideo': isVideo,
      'isLocal': isLocal,
      'lastPlayed': lastPlayed?.toIso8601String(),
    };
  }

  factory MediaItem.fromJson(Map<String, dynamic> json) {
    return MediaItem(
      id: json['id'],
      title: json['title'],
      subtitle: json['subtitle'],
      thumbnail: json['thumbnail'],
      duration: json['duration'],
      isVideo: json['isVideo'] ?? false,
      isLocal: json['isLocal'] ?? false,
      lastPlayed: json['lastPlayed'] != null
          ? DateTime.parse(json['lastPlayed'])
          : null,
    );
  }
}
