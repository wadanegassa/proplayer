import 'dart:typed_data';
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import 'neumorphic_widgets.dart';

class MediaCard extends StatelessWidget {
  const MediaCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.duration,
    this.imageUrl,
    this.thumbnailBytes,
    this.isVideo = false,
    this.showYouTubeIcon = false,
    this.width,
  });

  final String title;
  final String subtitle;
  final String? duration;
  final String? imageUrl;
  final Uint8List? thumbnailBytes;
  final VoidCallback onTap;
  final bool isVideo;
  final bool showYouTubeIcon;
  final double? width;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cardWidth = width ?? 160.0;
    
    ImageProvider? imageProvider;
    if (thumbnailBytes != null) {
      imageProvider = MemoryImage(thumbnailBytes!);
    } else if (imageUrl != null) {
      imageProvider = NetworkImage(imageUrl!);
    }

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: cardWidth,
        margin: const EdgeInsets.only(right: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            NeumorphicContainer(
              width: cardWidth,
              height: cardWidth,
              padding: const EdgeInsets.all(12),
              borderRadius: 24,
              depth: 8,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: imageProvider != null
                        ? Image(image: imageProvider, fit: BoxFit.cover)
                        : Container(
                            color: AppTheme.darkShadow,
                            child: Icon(
                              isVideo ? Icons.movie_rounded : Icons.music_note_rounded,
                              color: Colors.white10,
                              size: 40,
                            ),
                          ),
                  ),
                  if (duration != null)
                    Positioned(
                      top: 8,
                      right: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.black54,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          duration!,
                          style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: theme.textTheme.bodySmall?.copyWith(
                      fontSize: 13,
                      color: Colors.white38,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
