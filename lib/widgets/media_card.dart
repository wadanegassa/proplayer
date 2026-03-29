import 'dart:typed_data';
import 'package:flutter/material.dart';
class MediaCard extends StatefulWidget {
  final String title;
  final String subtitle;
  final String? duration;
  final String? imageUrl;
  final Uint8List? thumbnailBytes;
  final VoidCallback onTap;
  final bool isVideo;
  final bool showYouTubeIcon;

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
    this.height,
    this.useDynamicSizing = true,
  });

  final double? width;
  final double? height;
  final bool useDynamicSizing;

  @override
  State<MediaCard> createState() => _MediaCardState();
}

class _MediaCardState extends State<MediaCard> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 180),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.96).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.sizeOf(context).width;

    double? cardWidth;
    double? cardHeight;

    if (widget.useDynamicSizing) {
      cardWidth = widget.width ?? (screenWidth < 600 ? 158.0 : 196.0);
      cardHeight = widget.height ?? (screenWidth < 600 ? 142.0 : 172.0);
    } else {
      cardWidth = widget.width;
      cardHeight = widget.height;
    }

    ImageProvider? imageProvider;
    if (widget.thumbnailBytes != null) {
      imageProvider = MemoryImage(widget.thumbnailBytes!);
    } else if (widget.imageUrl != null) {
      imageProvider = NetworkImage(widget.imageUrl!);
    }

    final theme = Theme.of(context);
    final radius = 16.0;

    return GestureDetector(
      onTapDown: (_) {
        setState(() => _isPressed = true);
        _controller.forward();
      },
      onTapUp: (_) {
        setState(() => _isPressed = false);
        _controller.reverse();
        widget.onTap();
      },
      onTapCancel: () {
        setState(() => _isPressed = false);
        _controller.reverse();
      },
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: Container(
              width: cardWidth,
              margin: widget.useDynamicSizing ? const EdgeInsets.only(right: 16) : EdgeInsets.zero,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Stack(
                    children: [
                      if (cardWidth != null && cardHeight != null)
                        Container(
                          height: cardHeight,
                          width: cardWidth,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(radius),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(
                                  alpha: theme.brightness == Brightness.dark ? 0.2 : 0.06,
                                ),
                                blurRadius: 8,
                                offset: const Offset(0, 3),
                              ),
                            ],
                            border: Border.all(
                              color: theme.colorScheme.outline.withValues(alpha: 0.4),
                            ),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(radius - 1),
                            child: Stack(
                              fit: StackFit.expand,
                              children: [
                                _buildImageContent(imageProvider, theme, radius - 1),
                                if (_isPressed)
                                  DecoratedBox(
                                    decoration: BoxDecoration(
                                      color: theme.colorScheme.primary.withValues(alpha: 0.14),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        )
                      else
                        AspectRatio(
                          aspectRatio: 1.0,
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(radius),
                            child: _buildImageContent(imageProvider, theme, radius),
                          ),
                        ),
                      if (widget.duration != null)
                        Positioned(
                          top: 10,
                          right: 10,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.black.withValues(alpha: 0.72),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.white24),
                            ),
                            child: Text(
                              widget.duration!,
                              style: theme.textTheme.labelLarge?.copyWith(
                                color: Colors.white,
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ),
                      if (widget.showYouTubeIcon && widget.isVideo)
                        Positioned(
                          bottom: 10,
                          right: 10,
                          child: Container(
                            padding: const EdgeInsets.all(7),
                            decoration: BoxDecoration(
                              color: theme.colorScheme.primary,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Icon(
                              Icons.play_arrow_rounded,
                              color: theme.colorScheme.onPrimary,
                              size: 14,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(
                    widget.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                      letterSpacing: -0.2,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    widget.subtitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildImageContent(ImageProvider? imageProvider, ThemeData theme, double radius) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: ColoredBox(
        color: theme.colorScheme.surfaceContainerHighest,
        child: imageProvider != null
            ? Image(
                image: imageProvider,
                fit: BoxFit.cover,
                width: double.infinity,
                height: double.infinity,
              )
            : Center(
                child: Icon(
                  widget.isVideo ? Icons.movie_rounded : Icons.music_note_rounded,
                  size: 48,
                  color: theme.colorScheme.primary.withValues(alpha: 0.65),
                ),
              ),
      ),
    );
  }
}
