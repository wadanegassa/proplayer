import 'package:flutter/material.dart';

/// Shared breakpoints and padding for phones, large phones, and tablets.
abstract final class AppLayout {
  static const double phoneMax = 600;
  static const double tabletMax = 900;
  static const double contentMaxWidth = 720;
  static const double playerMaxWidth = 520;

  static bool isTabletWidth(double w) => w >= phoneMax;
  static bool isWideWidth(double w) => w >= tabletMax;

  /// Horizontal inset: scales slightly with width, clamped.
  static double horizontalPadding(BuildContext context) {
    final w = MediaQuery.sizeOf(context).width;
    return (w * 0.05).clamp(16.0, 32.0);
  }

  /// True when in landscape and short — use side-by-side layouts.
  static bool useCompactPlayerLayout(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    return size.width > size.height && size.height < 420;
  }

  /// True for tablet-sized width in any orientation.
  static bool useWidePlayerLayout(BuildContext context) {
    return MediaQuery.sizeOf(context).width >= phoneMax;
  }

  /// Centers [child] and caps width (main tabs, lists).
  static Widget constrainContent({required Widget child}) {
    return LayoutBuilder(
      builder: (context, c) {
        final w = c.maxWidth.isFinite ? c.maxWidth : MediaQuery.sizeOf(context).width;
        if (w <= contentMaxWidth) return child;
        return Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: contentMaxWidth),
            child: child,
          ),
        );
      },
    );
  }

  /// Player / modal-style max width.
  static Widget constrainPlayer({required Widget child}) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: playerMaxWidth),
        child: child,
      ),
    );
  }
}
