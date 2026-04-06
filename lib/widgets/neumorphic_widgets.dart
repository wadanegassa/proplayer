import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class NeumorphicContainer extends StatelessWidget {
  const NeumorphicContainer({
    super.key,
    required this.child,
    this.borderRadius = 20,
    this.padding = const EdgeInsets.all(16),
    this.depth = 10,
    this.isRecessed = false,
    this.color,
    this.shape = BoxShape.rectangle,
    this.width,
    this.height,
  });

  final Widget child;
  final double borderRadius;
  final EdgeInsets padding;
  final double depth;
  final bool isRecessed;
  final Color? color;
  final BoxShape shape;
  final double? width;
  final double? height;

  @override
  Widget build(BuildContext context) {
    if (isRecessed) {
      return Container(
        width: width,
        height: height,
        padding: padding,
        decoration: BoxDecoration(
          color: color ?? AppTheme.background,
          borderRadius: shape == BoxShape.circle ? null : BorderRadius.circular(borderRadius),
          shape: shape,
          // Simulating recessed with gradients
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppTheme.darkShadow.withValues(alpha: 0.5),
              AppTheme.lightShadow.withValues(alpha: 0.3),
            ],
          ),
        ),
        child: child,
      );
    }

    return Container(
      width: width,
      height: height,
      padding: padding,
      decoration: BoxDecoration(
        color: color ?? AppTheme.background,
        borderRadius: shape == BoxShape.circle ? null : BorderRadius.circular(borderRadius),
        shape: shape,
        boxShadow: AppTheme.elevated(distance: depth / 2, blur: depth),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppTheme.lightShadow.withValues(alpha: 0.2),
            AppTheme.background,
            AppTheme.darkShadow.withValues(alpha: 0.2),
          ],
        ),
      ),
      child: child,
    );
  }
}

class NeumorphicButton extends StatelessWidget {
  const NeumorphicButton({
    super.key,
    required this.child,
    required this.onPressed,
    this.size = 56,
    this.borderRadius = 16,
    this.isCircular = true,
    this.isAccent = false,
  });

  final Widget child;
  final VoidCallback? onPressed;
  final double size;
  final double borderRadius;
  final bool isCircular;
  final bool isAccent;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: NeumorphicContainer(
        width: size,
        height: size,
        padding: EdgeInsets.zero,
        borderRadius: borderRadius,
        shape: isCircular ? BoxShape.circle : BoxShape.rectangle,
        depth: onPressed == null ? 0 : 12,
        color: isAccent ? (onPressed == null ? Colors.grey.withValues(alpha: 0.3) : null) : AppTheme.background,
        child: Container(
          decoration: isAccent && onPressed != null ? const BoxDecoration(
            shape: BoxShape.circle,
            gradient: AppTheme.accentGradient,
            boxShadow: [
              BoxShadow(
                color: AppTheme.brand,
                blurRadius: 20,
                spreadRadius: 1,
              )
            ],
          ) : null,
          child: Center(
            child: Opacity(
              opacity: onPressed == null ? 0.3 : 1.0,
              child: child,
            ),
          ),
        ),
      ),
    );
  }
}

class NeumorphicListTile extends StatelessWidget {
  const NeumorphicListTile({
    super.key,
    required this.title,
    required this.subtitle,
    this.onTap,
    this.trailing,
    this.isSelected = false,
  });

  final String title;
  final String subtitle;
  final VoidCallback? onTap;
  final Widget? trailing;
  final bool isSelected;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: isSelected ? BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: AppTheme.playingItemGradient,
          boxShadow: [
             BoxShadow(
               color: Colors.black.withValues(alpha: 0.3),
               offset: const Offset(0, 10),
               blurRadius: 20,
             )
          ],
        ) : null,
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: isSelected ? Colors.white : Colors.white.withValues(alpha: 0.9),
                      fontSize: 16,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: isSelected ? Colors.white70 : Colors.white38,
                      fontSize: 14,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            if (trailing != null) trailing!,
          ],
        ),
      ),
    );
  }
}
