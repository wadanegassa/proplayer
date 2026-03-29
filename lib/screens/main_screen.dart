import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../widgets/mini_player.dart';
import '../widgets/custom_bottom_nav_bar.dart';
import '../providers/main_nav_provider.dart';
import 'home_screen.dart';
import 'browse_screen.dart';
import 'library_screen.dart';

class MainScreen extends StatelessWidget {
  const MainScreen({super.key});

  static const List<Widget> _screens = [
    HomeScreen(),
    BrowseScreen(),
    LibraryScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Consumer<MainNavProvider>(
      builder: (context, nav, _) {
        return Scaffold(
          extendBody: true,
          body: IndexedStack(
            index: nav.currentIndex,
            children: _screens,
          ),
          bottomNavigationBar: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const MiniPlayer(),
              CustomBottomNavBar(
                currentIndex: nav.currentIndex,
                onTap: nav.setIndex,
              ),
            ],
          ),
        );
      },
    );
  }
}
