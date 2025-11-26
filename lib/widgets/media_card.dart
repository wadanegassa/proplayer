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
                                color: AppTheme.primaryColor.withValues(alpha: 0.3),
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
                                  color: AppTheme.primaryColor.withValues(alpha: 0.3),
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
                              gradient: LinearGradient(
                                colors: [
                                  Colors.black.withValues(alpha: 0.8),
                                  Colors.black.withValues(alpha: 0.6),
                                ],
                              ),
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(
                                color: Colors.white.withValues(alpha: 0.1),
                                width: 1,
                              ),
                            ),
                            child: Text(
                              widget.duration!,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      // YouTube icon badge
                      if (widget.showYouTubeIcon)
                        Positioned(
                          bottom: 6,
                          right: 6,
                          child: Container(
                            padding: const EdgeInsets.all(5),
                            decoration: BoxDecoration(
                              color: Colors.red,
                              borderRadius: BorderRadius.circular(6),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.red.withValues(alpha: 0.5),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: const Icon(
                              Icons.play_arrow_rounded,
                              color: Colors.white,
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
                    style: const TextStyle(
                      color: Colors.white,
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
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.6),
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
    return Container(
      margin: const EdgeInsets.all(2),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        color: AppTheme.surfaceColor,
        image: imageProvider != null
            ? DecorationImage(
                image: imageProvider,
                fit: BoxFit.cover,
              )
            : null,
      ),
      child: imageProvider == null
          ? Center(
              child: ShaderMask(
                shaderCallback: (bounds) {
                  return AppTheme.primaryGradient.createShader(bounds);
                },
                child: Icon(
                  widget.isVideo ? Icons.movie_rounded : Icons.music_note_rounded,
                  size: 56,
                  color: Colors.white,
                ),
              ),
            )
          : null,
    );
  }
}
