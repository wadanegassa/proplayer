import 'dart:typed_data';
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import 'beat_animation.dart';

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
    this.playCount = "243",
    this.downloadCount = "243",
    this.likeCount = "193",
    this.isPlaying = false,
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
  final String playCount;
  final String downloadCount;
  final String likeCount;
  final bool isPlaying;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cardWidth = width ?? 200.0;
    final cardHeight = cardWidth * 1.25;

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
        height: cardHeight,
        margin: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(28),
          image: imageProvider != null
              ? DecorationImage(image: imageProvider, fit: BoxFit.cover)
              : null,
          color: theme.colorScheme.surface,
          boxShadow: isPlaying ? [
            BoxShadow(
              color: AppTheme.primary.withValues(alpha: 0.2),
              blurRadius: 15,
              spreadRadius: 2,
            )
          ] : null,
        ),
        child: Stack(
          children: [
            if (imageProvider == null)
              Center(
                child: BeatAnimation(
                  isPlaying: isPlaying,
                  child: Icon(
                    isVideo ? Icons.movie_rounded : Icons.graphic_eq_rounded,
                    color: isPlaying ? AppTheme.primary.withValues(alpha: 0.5) : theme.colorScheme.onSurface.withValues(alpha: 0.1),
                    size: 64,
                  ),
                ),
              ),
            // Gradient Overlay for text readability
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(28),
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.black.withValues(alpha: 0.7),
                    ],
                    stops: const [0.6, 1.0],
                  ),
                ),
              ),
            ),
            // Title overlay
            Positioned(
              left: 16,
              bottom: 64,
              right: 16,
              child: Text(
                title,
                style: theme.textTheme.titleMedium?.copyWith(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            // Bottom bar with stats
            Positioned(
              left: 12,
              right: 12,
              bottom: 12,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    // Play Button
                    BeatAnimation(
                      isPlaying: isPlaying,
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: isPlaying ? AppTheme.primary : Colors.white,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded, color: Colors.black, size: 20),
                      ),
                    ),
                    const SizedBox(width: 8),
                    // Play Stats
                    _StatItem(icon: Icons.play_arrow_rounded, value: playCount),
                    const VerticalDivider(color: Colors.white24, width: 1, indent: 4, endIndent: 4),
                    _StatItem(icon: Icons.download_rounded, value: downloadCount),
                    const VerticalDivider(color: Colors.white24, width: 1, indent: 4, endIndent: 4),
                    _StatItem(icon: Icons.favorite_rounded, value: likeCount),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  const _StatItem({required this.icon, required this.value});
  final IconData icon;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white, size: 14),
          Text(
            value,
            style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}
