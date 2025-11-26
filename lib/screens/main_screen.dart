import 'package:flutter/material.dart';
// custom bottom navigation implemented below
import '../widgets/mini_player.dart';
import 'home_screen.dart';
import 'browse_screen.dart';
import 'library_screen.dart';
import 'package:fluid_bottom_nav_bar/fluid_bottom_nav_bar.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;
  // using FluidNavBar from fluid_bottom_nav_bar

  final List<Widget> _screens = [
    const HomeScreen(),
    const BrowseScreen(),
    const LibraryScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    // no external controller needed for FluidNavBar
    return Scaffold(
      body: Stack(
        children: [
          IndexedStack(
            index: _currentIndex,
            children: _screens,
          ),
        ],
      ),
      bottomNavigationBar: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const MiniPlayer(),
          Builder(builder: (context) {
            // (colors chosen below for the gradient and selected pill)

            return SafeArea(
              child: FluidNavBar(
                icons: [
                  FluidNavBarIcon(
                    icon: Icons.home_rounded,
                    selectedForegroundColor: Colors.white,
                    unselectedForegroundColor: Colors.black,
                    backgroundColor: const Color(0xFF00C6FF),
                    extras: {"label": 'Home'},
                  ),
                  FluidNavBarIcon(
                    icon: Icons.explore_rounded,
                    selectedForegroundColor: Colors.white,
                    unselectedForegroundColor: Colors.black,
                    backgroundColor: const Color(0xFF00C6FF),
                    extras: {"label": 'Browse'},
                  ),
                  FluidNavBarIcon(
                    icon: Icons.library_music_rounded,
                    selectedForegroundColor: Colors.white,
                    unselectedForegroundColor: Colors.black,
                    backgroundColor: const Color(0xFF00C6FF),
                    extras: {"label": 'Library'},
                  ),
                ],
                onChange: (index) => setState(() => _currentIndex = index),
                defaultIndex: _currentIndex,
                animationFactor: 0.95,
                scaleFactor: 1.25,
                style: FluidNavBarStyle(
                  barBackgroundColor: const Color(0xFF00C6FF),
                  iconBackgroundColor: const Color(0xFF00E5FF),
                  iconSelectedForegroundColor: Colors.white,
                  iconUnselectedForegroundColor: Colors.white70,
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}
