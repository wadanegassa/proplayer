import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// Layered gradient + soft accent orbs for main tab screens.
class AppShellBackground extends StatelessWidget {
  const AppShellBackground({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Stack(
      fit: StackFit.expand,
      children: [
        DecoratedBox(
          decoration: BoxDecoration(
            gradient: isDark ? AppTheme.pageDark : AppTheme.pageLight,
          ),
        ),
        Positioned(
          top: -120,
          right: -80,
          child: _GlowOrb(
            diameter: 280,
            colors: [
              theme.colorScheme.primary.withValues(alpha: isDark ? 0.22 : 0.14),
              Colors.transparent,
            ],
          ),
        ),
        Positioned(
          top: MediaQuery.sizeOf(context).height * 0.35,
          left: -100,
          child: _GlowOrb(
            diameter: 220,
            colors: [
              theme.colorScheme.secondary.withValues(alpha: isDark ? 0.12 : 0.10),
              Colors.transparent,
            ],
          ),
        ),
        Positioned(
          bottom: 80,
          right: -60,
          child: _GlowOrb(
            diameter: 200,
            colors: [
              theme.colorScheme.tertiary.withValues(alpha: isDark ? 0.08 : 0.06),
              Colors.transparent,
            ],
          ),
        ),
        child,
      ],
    );
  }
}

class _GlowOrb extends StatelessWidget {
  const _GlowOrb({required this.diameter, required this.colors});

  final double diameter;
  final List<Color> colors;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Container(
        width: diameter,
        height: diameter,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(colors: colors, stops: const [0.0, 1.0]),
        ),
      ),
    );
  }
}
