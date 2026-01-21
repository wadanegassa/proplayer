import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:fluid_bottom_nav_bar/fluid_bottom_nav_bar.dart';

class CustomBottomNavBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const CustomBottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    return FluidNavBar(
      icons: [
        FluidNavBarIcon(
          icon: currentIndex == 0 ? Icons.home_rounded : Icons.home_outlined,
          backgroundColor: theme.colorScheme.primary,
          extras: {"label": "Home"},
        ),
        FluidNavBarIcon(
          icon: CupertinoIcons.search,
          backgroundColor: theme.colorScheme.secondary,
          extras: {"label": "Browse"},
        ),
        FluidNavBarIcon(
          icon: currentIndex == 2 ? Icons.library_music_rounded : Icons.library_music_outlined,
          backgroundColor: theme.colorScheme.tertiary,
          extras: {"label": "Library"},
        ),
      ],
      onChange: onTap,
      style: FluidNavBarStyle(
        barBackgroundColor: isDark ? const Color(0xFF0F172A) : Colors.white,
        iconUnselectedForegroundColor: isDark ? Colors.grey[400] : Colors.grey[600],
        iconSelectedForegroundColor: Colors.white,
      ),
      scaleFactor: 1.5,
      defaultIndex: currentIndex,
      itemBuilder: (icon, item) => Semantics(
        label: icon.extras!["label"],
        child: item,
      ),
    );
  }
}
