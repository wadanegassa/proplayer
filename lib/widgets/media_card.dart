import 'dart:typed_data';
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

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
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Responsive sizing based on screen width
    final screenWidth = MediaQuery.of(context).size.width;
    
    double? cardWidth;
    double? cardHeight;

    if (widget.useDynamicSizing) {
      cardWidth = widget.width ?? (screenWidth < 600 ? 160.0 : 200.0);
      cardHeight = widget.height ?? (screenWidth < 600 ? 140.0 : 180.0);
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
  final isLight = theme.brightness == Brightness.light;

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
                      // Card with gradient border effect
                      if (cardWidth != null && cardHeight != null)
                        Container(
                          height: cardHeight,
                          width: cardWidth,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16),
                            gradient: _isPressed
                                ? AppTheme.primaryGradient
                                : null,
                            boxShadow: [
                              BoxShadow(
                                color: theme.colorScheme.primary.withAlpha((0.14 * 255).round()),
                                blurRadius: 12,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: _buildImageContent(imageProvider),
                        )
                      else
                        AspectRatio(
                          aspectRatio: 1.0,
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(16),
                              gradient: _isPressed
                                  ? AppTheme.primaryGradient
                                  : null,
                              boxShadow: [
                                BoxShadow(
                                  color: theme.colorScheme.primary.withAlpha((0.14 * 255).round()),
                                  blurRadius: 12,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: _buildImageContent(imageProvider),
                          ),
                        ),
                      // Duration badge
                      if (widget.duration != null)
                        Positioned(
                          top: 6,
                          right: 6,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              // Force badge background: black in light mode, white in dark mode
                              color: isLight ? Colors.black : Colors.white,
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(
                                color: theme.colorScheme.onSurface.withAlpha((0.06 * 255).round()),
                                width: 1,
                              ),
                            ),
                            child: Text(
                              widget.duration!,
                              style: TextStyle(
                                // Ensure readable text: white on black, black on white
                                color: isLight ? Colors.white : Colors.black,
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      // YouTube / play icon badge (only for videos)
                      if (widget.showYouTubeIcon && widget.isVideo)
                        Positioned(
                          bottom: 6,
                          right: 6,
                          child: Container(
                            padding: const EdgeInsets.all(5),
                            decoration: BoxDecoration(
                              color: theme.colorScheme.secondary,
                              borderRadius: BorderRadius.circular(6),
                              boxShadow: [
                                BoxShadow(
                                  color: theme.colorScheme.secondary.withAlpha((0.28 * 255).round()),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Icon(
                              Icons.play_arrow_rounded,
                              color: theme.colorScheme.onSecondary,
                              size: 12,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  // Title
                  Text(
                    widget.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      height: 1.2,
                    ),
                  ),
                  const SizedBox(height: 2),
                  // Subtitle
                  Text(
                    widget.subtitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.textTheme.bodySmall?.color?.withAlpha((0.72 * 255).round()),
                      fontSize: 11,
                      fontWeight: FontWeight.w400,
                      height: 1.2,
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

  Widget _buildImageContent(ImageProvider? imageProvider) {
    final theme = Theme.of(context);
    // Use a ClipRRect + Image (with BoxFit.cover) so the image fully fills
    // the available area and is correctly clipped to the card radius.
    return ClipRRect(
      borderRadius: BorderRadius.circular(14),
      child: Container(
        // fill the parent area (parent container provides fixed height/width)
        color: theme.cardColor,
        child: imageProvider != null
            ? SizedBox.expand(
                child: Image(
                  image: imageProvider,
                  fit: BoxFit.cover,
                  width: double.infinity,
                  height: double.infinity,
                  alignment: Alignment.center,
                ),
              )
            : Center(
                child: ShaderMask(
                  shaderCallback: (bounds) {
                    return AppTheme.primaryGradient.createShader(bounds);
                  },
                  child: Icon(
                    widget.isVideo ? Icons.movie_rounded : Icons.music_note_rounded,
                    size: 56,
                    color: theme.colorScheme.onPrimary,
                  ),
                ),
              ),
      ),
    );
  }
}
