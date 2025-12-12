import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final backgroundColor = isDark ? const Color(0xFF1E1E1E) : Colors.white;
    final iconColor = isDark ? Colors.white : const Color(0xFF1E1E1E);
    final selectedIconColor = isDark ? Colors.blue : Colors.blue;

    return Container(
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        child: SizedBox(
          height: 60,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(
                icon: Icons.home_outlined,
                selectedIcon: Icons.home_rounded,
                index: 0,
                iconColor: iconColor,
                selectedIconColor: selectedIconColor,
              ),
              _buildNavItem(
                icon: CupertinoIcons.globe,
                selectedIcon: CupertinoIcons.globe,
                index: 1,
                iconColor: iconColor,
                selectedIconColor: selectedIconColor,
              ),
              _buildNavItem(
                icon: Icons.library_music_outlined,
                selectedIcon: Icons.library_music_rounded,
                index: 2,
                iconColor: iconColor,
                selectedIconColor: selectedIconColor,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required IconData icon,
    required IconData selectedIcon,
    required int index,
    required Color iconColor,
    required Color selectedIconColor,
  }) {
    final isSelected = currentIndex == index;

    return GestureDetector(
      onTap: () => onTap(index),
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 200),
          child: Icon(
            isSelected ? selectedIcon : icon,
            key: ValueKey<bool>(isSelected),
            color: isSelected ? selectedIconColor : iconColor.withValues(alpha: 0.6),
            size: 28,
          ),
        ),
      ),
    );
  }
}
